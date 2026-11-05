import test from 'node:test';
import assert from 'node:assert/strict';
import {
  createPairingRateLimiter,
  MAX_REQUEST_BYTES,
  parseChangesQuery,
  parseJsonBody,
} from './http_security.mjs';

test('pairing limiter blocks excess attempts and resets after its window', () => {
  const limited = createPairingRateLimiter({ windowMs: 1000, maxAttempts: 2 });
  assert.equal(limited('device-a', 100), false);
  assert.equal(limited('device-a', 200), false);
  assert.equal(limited('device-a', 300), true);
  assert.equal(limited('device-a', 1200), false);
});

test('pairing limiter bounds stored source addresses', () => {
  const limited = createPairingRateLimiter({ maxKeys: 2 });
  limited('a', 0);
  limited('b', 0);
  assert.equal(limited('c', 0), false);
  assert.equal(limited('c', 1), false);
});

test('request JSON rejects malformed and oversized payloads with client status', () => {
  assert.throws(() => parseJsonBody(Buffer.from('{')), { statusCode: 400 });
  assert.throws(
    () => parseJsonBody(Buffer.alloc(MAX_REQUEST_BYTES + 1)),
    { statusCode: 413 },
  );
  assert.deepEqual(parseJsonBody(Buffer.from('{"ok":true}')), { ok: true });
});

test('change cursor and limit are validated and bounded', () => {
  assert.deepEqual(parseChangesQuery(new URLSearchParams()), {
    cursor: 0n,
    limit: 100,
  });
  assert.deepEqual(parseChangesQuery(new URLSearchParams('cursor=12&limit=999')), {
    cursor: 12n,
    limit: 200,
  });
  assert.equal(parseChangesQuery(new URLSearchParams('cursor=oops')), null);
  assert.equal(parseChangesQuery(new URLSearchParams('limit=1.5')), null);
});
