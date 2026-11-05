export const MAX_REQUEST_BYTES = 2_000_000;

export function createPairingRateLimiter({
  windowMs = 15 * 60 * 1000,
  maxAttempts = 10,
  maxKeys = 1000,
} = {}) {
  const attempts = new Map();
  return function isRateLimited(key, now = Date.now()) {
    for (const [address, attempt] of attempts) {
      if (now - attempt.startedAt >= windowMs) attempts.delete(address);
    }
    const existing = attempts.get(key);
    if (!existing || now - existing.startedAt >= windowMs) {
      if (attempts.size >= maxKeys) {
        const oldest = attempts.keys().next().value;
        if (oldest !== undefined) attempts.delete(oldest);
      }
      attempts.set(key, { startedAt: now, count: 1 });
      return false;
    }
    existing.count += 1;
    return existing.count > maxAttempts;
  };
}

export function parseJsonBody(buffer) {
  if (buffer.length > MAX_REQUEST_BYTES) {
    const error = new Error('Request too large');
    error.statusCode = 413;
    throw error;
  }
  if (buffer.length === 0) return {};
  try {
    return JSON.parse(buffer.toString('utf8'));
  } catch {
    const error = new Error('Malformed JSON request');
    error.statusCode = 400;
    throw error;
  }
}

export function parseChangesQuery(searchParams) {
  const rawCursor = searchParams.get('cursor') ?? '0';
  const rawLimit = searchParams.get('limit') ?? '100';
  if (!/^\d{1,30}$/.test(rawCursor) || !/^\d{1,3}$/.test(rawLimit)) {
    return null;
  }
  return {
    cursor: BigInt(rawCursor),
    limit: Math.max(1, Math.min(200, Number(rawLimit))),
  };
}
