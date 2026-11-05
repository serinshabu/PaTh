import crypto from 'node:crypto';
import fs from 'node:fs';
import http from 'node:http';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';
import {
  createPairingRateLimiter,
  MAX_REQUEST_BYTES,
  parseChangesQuery,
  parseJsonBody,
} from './http_security.mjs';

const { Pool } = pg;
const port = Number(process.env.LIFEOS_PORT ?? 8080);
const accountId = process.env.LIFEOS_ACCOUNT_ID;
const pairingCode = process.env.LIFEOS_PAIRING_CODE;
const databaseUrl = process.env.DATABASE_URL;
const kdfIterations = 310000;
const pairingWindowMs = 15 * 60 * 1000;
const pairingMaxAttempts = 10;
const pairingRateLimited = createPairingRateLimiter({
  windowMs: pairingWindowMs,
  maxAttempts: pairingMaxAttempts,
});
if (!accountId || !pairingCode || pairingCode.length < 32 || !databaseUrl) {
  throw new Error('Set LIFEOS_ACCOUNT_ID, a random LIFEOS_PAIRING_CODE of at least 32 characters, and DATABASE_URL.');
}
const pool = new Pool({ connectionString: databaseUrl, max: 10, ssl: process.env.PGSSLMODE === 'require' ? { rejectUnauthorized: true } : undefined });
const schema = fs.readFileSync(path.join(path.dirname(fileURLToPath(import.meta.url)), 'schema.sql'), 'utf8');
await pool.query(schema);
await pool.query(
  `INSERT INTO lifeos_account(id,encryption_salt,kdf_iterations)
   VALUES($1,$2,$3) ON CONFLICT(id) DO NOTHING`,
  [accountId, crypto.randomBytes(16), kdfIterations],
);

function json(res, status, value) {
  const body = JSON.stringify(value);
  res.writeHead(status, { 'content-type': 'application/json; charset=utf-8', 'content-length': Buffer.byteLength(body), 'cache-control': 'no-store', 'x-content-type-options': 'nosniff' });
  res.end(body);
}
async function body(req) {
  const chunks = [];
  let size = 0;
  for await (const chunk of req) {
    size += chunk.length;
    if (size > MAX_REQUEST_BYTES) {
      const error = new Error('Request too large');
      error.statusCode = 413;
      throw error;
    }
    chunks.push(chunk);
  }
  return parseJsonBody(Buffer.concat(chunks, size));
}
function bearer(req) {
  const match = /^Bearer ([A-Za-z0-9_-]{40,})$/.exec(req.headers.authorization ?? '');
  return match?.[1] ?? null;
}
async function authenticate(req) {
  const token = bearer(req);
  if (!token) return null;
  const digest = crypto.createHash('sha256').update(token).digest();
  const result = await pool.query(
    `UPDATE lifeos_devices SET last_seen_at=now()
     WHERE token_hash=$1 AND account_id=$2 AND revoked_at IS NULL
     RETURNING id, account_id`, [digest, accountId],
  );
  return result.rows[0] ?? null;
}
function safeEqual(a, b) {
  const aa = Buffer.from(a); const bb = Buffer.from(b);
  return aa.length === bb.length && crypto.timingSafeEqual(aa, bb);
}
const app = http.createServer(async (req, res) => {
  try {
    const url = new URL(req.url ?? '/', 'http://localhost');
    if (req.method === 'GET' && url.pathname === '/healthz') return json(res, 200, { status: 'ok' });
    if (req.method === 'POST' && url.pathname === '/v1/devices/pair') {
      const address = req.socket.remoteAddress ?? 'unknown';
      if (pairingRateLimited(address)) {
        res.setHeader('retry-after', String(Math.ceil(pairingWindowMs / 1000)));
        return json(res, 429, { error: 'Too many pairing attempts. Try again later.' });
      }
      const input = await body(req);
      if (typeof input.code !== 'string' || !safeEqual(input.code, pairingCode)) return json(res, 401, { error: 'Pairing code rejected' });
      const deviceName = String(input.name ?? '').trim().slice(0, 80);
      if (!deviceName) return json(res, 400, { error: 'Device name is required' });
      const token = crypto.randomBytes(32).toString('base64url');
      const deviceId = crypto.randomUUID();
      const db = await pool.connect();
      try {
        await db.query('BEGIN');
        const config = await db.query('SELECT encryption_salt,kdf_iterations FROM lifeos_account WHERE id=$1', [accountId]);
        await db.query('INSERT INTO lifeos_devices(id,account_id,name,token_hash) VALUES($1,$2,$3,$4)', [deviceId, accountId, deviceName, crypto.createHash('sha256').update(token).digest()]);
        await db.query('COMMIT');
        return json(res, 201, { deviceId, token, accountId, keySalt: config.rows[0].encryption_salt.toString('base64'), kdfIterations: config.rows[0].kdf_iterations });
      } catch (error) { await db.query('ROLLBACK'); throw error; } finally { db.release(); }
    }
    const device = await authenticate(req);
    if (!device) return json(res, 401, { error: 'Device authentication required' });
    if (req.method === 'GET' && url.pathname === '/v1/sync/config') {
      const result = await pool.query('SELECT encryption_salt,kdf_iterations FROM lifeos_account WHERE id=$1', [accountId]);
      return json(res, 200, { accountId, keySalt: result.rows[0].encryption_salt.toString('base64'), kdfIterations: result.rows[0].kdf_iterations });
    }
    if (req.method === 'GET' && url.pathname === '/v1/devices') {
      const result = await pool.query('SELECT id,name,created_at,last_seen_at,revoked_at FROM lifeos_devices WHERE account_id=$1 ORDER BY created_at', [accountId]);
      return json(res, 200, { devices: result.rows });
    }
    const revoke = /^\/v1\/devices\/([0-9a-f-]{36})$/.exec(url.pathname);
    if (req.method === 'DELETE' && revoke) {
      const result = await pool.query('UPDATE lifeos_devices SET revoked_at=now() WHERE id=$1 AND account_id=$2 AND revoked_at IS NULL RETURNING id', [revoke[1], accountId]);
      return json(res, result.rowCount ? 200 : 404, { revoked: Boolean(result.rowCount) });
    }
    if (req.method === 'POST' && url.pathname === '/v1/changes') {
      const input = await body(req);
      if (!Array.isArray(input.changes) || input.changes.length > 100) return json(res, 400, { error: 'Provide at most 100 changes' });
      const acknowledgements = []; const conflicts = [];
      for (const change of input.changes) {
        if (!change || !/^[A-Za-z][A-Za-z0-9]{0,39}$/.test(change.entityType) || typeof change.entityId !== 'string' || change.entityId.length > 128 || typeof change.changeId !== 'string' || change.changeId.length > 128 || !['upsert','delete'].includes(change.operation) || (change.operation === 'upsert' && (typeof change.payload !== 'string' || change.payload.length > 1_500_000))) return json(res, 400, { error: 'Invalid change' });
        const db = await pool.connect();
        try {
          await db.query('BEGIN');
          const duplicate = await db.query('SELECT revision,cursor FROM lifeos_changes WHERE account_id=$1 AND change_id=$2', [accountId, change.changeId]);
          if (duplicate.rowCount) {
            await db.query('COMMIT'); acknowledgements.push({ changeId: change.changeId, revision: String(duplicate.rows[0].revision), cursor: String(duplicate.rows[0].cursor) }); continue;
          }
          const existing = await db.query('SELECT revision,payload_envelope,deleted FROM lifeos_records WHERE account_id=$1 AND entity_type=$2 AND entity_id=$3 FOR UPDATE', [accountId, change.entityType, change.entityId]);
          const currentRevision = existing.rowCount ? Number(existing.rows[0].revision) : null;
          if (currentRevision !== (change.baseRevision ?? null)) {
            await db.query('COMMIT');
            conflicts.push({ changeId: change.changeId, entityType: change.entityType, entityId: change.entityId, remoteRevision: currentRevision, remotePayload: existing.rows[0]?.payload_envelope ?? null, remoteDeleted: existing.rows[0]?.deleted ?? false }); continue;
          }
          const revision = (currentRevision ?? 0) + 1;
          await db.query(`INSERT INTO lifeos_records(account_id,entity_type,entity_id,revision,payload_envelope,deleted)
            VALUES($1,$2,$3,$4,$5,$6) ON CONFLICT(account_id,entity_type,entity_id) DO UPDATE SET revision=EXCLUDED.revision,payload_envelope=EXCLUDED.payload_envelope,deleted=EXCLUDED.deleted,updated_at=now()`,
          [accountId, change.entityType, change.entityId, revision, change.operation === 'delete' ? null : change.payload, change.operation === 'delete']);
          const inserted = await db.query(`INSERT INTO lifeos_changes(account_id,device_id,change_id,entity_type,entity_id,revision,operation,payload_envelope)
            VALUES($1,$2,$3,$4,$5,$6,$7,$8) RETURNING cursor`, [accountId, device.id, change.changeId, change.entityType, change.entityId, revision, change.operation, change.operation === 'delete' ? null : change.payload]);
          await db.query('COMMIT');
          acknowledgements.push({ changeId: change.changeId, revision: String(revision), cursor: String(inserted.rows[0].cursor) });
        } catch (error) { await db.query('ROLLBACK'); throw error; } finally { db.release(); }
      }
      return json(res, 200, { acknowledgements, conflicts });
    }
    if (req.method === 'GET' && url.pathname === '/v1/changes') {
      const query = parseChangesQuery(url.searchParams);
      if (query === null) {
        return json(res, 400, { error: 'Invalid cursor or limit' });
      }
      const { cursor, limit } = query;
      const result = await pool.query(`SELECT cursor,change_id,entity_type,entity_id,revision,operation,payload_envelope,created_at
        FROM lifeos_changes WHERE account_id=$1 AND cursor>$2 ORDER BY cursor LIMIT $3`, [accountId, cursor.toString(), limit]);
      const changes = result.rows.map((row) => ({ cursor: String(row.cursor), changeId: row.change_id, entityType: row.entity_type, entityId: row.entity_id, revision: Number(row.revision), operation: row.operation, payload: row.payload_envelope, createdAt: row.created_at }));
      return json(res, 200, { changes, nextCursor: changes.length ? changes.at(-1).cursor : cursor.toString(), hasMore: changes.length === limit });
    }
    return json(res, 404, { error: 'Not found' });
  } catch (error) {
    console.error('Request failed:', error?.message ?? 'unknown error');
    return json(res, error?.statusCode ?? 500, {
      error: error?.statusCode ? error.message : 'Request failed',
    });
  }
});
app.listen(port, '0.0.0.0', () => console.log(`Life OS sync API listening on ${port}`));
process.on('SIGTERM', async () => { app.close(); await pool.end(); process.exit(0); });
