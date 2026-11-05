# PaTh self-hosted sync service

This service stores opaque encrypted record envelopes in PostgreSQL. It never receives the recovery secret or plaintext record payloads. It provides device pairing, per-device bearer tokens, revocation, optimistic revisions, deletion tombstones, an idempotent push endpoint, and a cursor-based change log.

## Deploy

1. Install Docker Compose and create a strong random PostgreSQL password, account UUID, and pairing code (at least 32 random characters).
2. Create `backend/.env` with `POSTGRES_PASSWORD`, `LIFEOS_ACCOUNT_ID`, and `LIFEOS_PAIRING_CODE`. Do not commit this file.
3. Run `docker compose up -d --build` from `backend/`.
4. Put the API behind an HTTPS reverse proxy (for example Caddy or nginx with a valid certificate). Expose only the HTTPS proxy publicly; keep port 8080 and PostgreSQL private.
5. Pair the first device with the server URL, pairing code, and a recovery phrase. Enter the same phrase on every paired device. The phrase is never sent to this service.

## Private Windows setup for Android + Windows

For a personal test setup, the Windows laptop can host PostgreSQL and the API. Tailscale Serve gives the API a private HTTPS URL that is reachable only by devices signed into the same tailnet. Keep the laptop powered on and connected to the internet for sync to work.

1. Install and start Docker Desktop for Windows. The project uses Linux containers with the WSL 2 backend. See the [official Docker Desktop Windows installation guide](https://docs.docker.com/desktop/setup/install/windows-install/).
2. In PowerShell, go to this `backend` folder, copy `.env.example` to `.env`, and replace all three sample values. Use a random long password for PostgreSQL, a new UUID for `LIFEOS_ACCOUNT_ID`, and a separate random pairing code of at least 32 characters. Keep `.env` private and do not send the values to anyone.
3. Run `docker compose up -d --build`. The API health check should respond at `http://127.0.0.1:8080/healthz`. This loopback address is for local verification only; the app rejects plain HTTP on non-local addresses.
4. Install Tailscale on the Windows laptop and Android phone and sign both into the same tailnet. Enable MagicDNS and HTTPS certificates if Tailscale asks.
5. Open an Administrator PowerShell, run `tailscale serve --bg 8080`, and copy the private `https://…ts.net` address it prints. Check `tailscale serve status`; then open `https://…ts.net/healthz` in a browser on the phone while Tailscale is connected.
6. In PaTh Sync Settings, enter that HTTPS address and the pairing code from `.env`. Choose a strong recovery phrase and enter exactly the same phrase on both devices. Store it somewhere secure; losing it prevents decryption of synchronized contents.

This path uses Tailscale as the private network and TLS endpoint. The API itself remains self-hosted. Tailscale Serve is private to the tailnet; do not enable Tailscale Funnel or public port forwarding for this private sync API. Tailscale documents that Serve provisions HTTPS for the tailnet and proxies to a local service; see its [Serve guide](https://tailscale.com/docs/use-cases/application-testing/share-local-dev-server-with-team) and [CLI reference](https://tailscale.com/docs/reference/tailscale-cli/serve).

The account encryption salt is generated once and persisted in PostgreSQL. Back up the database volume. Losing the recovery phrase makes encrypted record contents unrecoverable; losing the database loses the change history and current records.

## API

- `POST /v1/devices/pair` — exchange bootstrap pairing code for one device token.
- `GET /v1/sync/config` — retrieve the public KDF salt and iteration count.
- `POST /v1/changes` — push up to 100 idempotent mutations; stale base revisions return conflicts.
- `GET /v1/changes?cursor=N&limit=100` — pull changes after a durable cursor.
- `GET /v1/devices` and `DELETE /v1/devices/{id}` — list and revoke devices.
- `GET /healthz` — process health.

Every protected route uses a device bearer token. Revocation blocks subsequent requests. Pairing attempts are limited to 10 per source address per 15-minute window in each API process; failed attempts return HTTP 429 and a `Retry-After` header. Keep pairing credentials private and rotate them by restarting with a new code after onboarding. The API is intentionally single-owner (one account UUID per deployment) for this first sync iteration. For multiple API replicas, put a shared rate limiter at the HTTPS proxy because this in-process limit is per replica and resets on restart.

Run `npm install` and `npm run check` to validate the server source. Production traffic must use HTTPS at the reverse proxy.
