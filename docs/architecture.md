# PaTh architecture

PaTh is a Flutter application with a local-first data path. Android and Windows provide platform runners; the shared user interface and app behavior live in `lib/`.

## App layers

```text
Platform runner (android/ or windows/)
                 │
                 ▼
lib/app/  →  lib/features/  →  Riverpod providers
                                  │
                                  ▼
                          lib/data/repositories
                           ├─ Drift / SQLite
                           ├─ settings and backups
                           └─ optional sync engine → backend API
```

- **`lib/main.dart`** starts the Flutter app and wires app-level dependencies.
- **`lib/app/`** owns application composition, route definitions, adaptive navigation, and shared theme.
- **`lib/features/`** groups screens and user flows by feature: dashboard, trackers, calendar, analytics, settings, and device integrations.
- **`lib/data/database/`** defines the Drift SQLite database and generated table code.
- **`lib/data/records/`** provides record repositories and calculations used by trackers, summaries, and analytics.
- **`lib/data/settings/`** persists preferences, dashboard layout, and device options.
- **`lib/data/backup/`** imports and exports local records.
- **`lib/data/sync/`** holds pairing credentials, client-side encryption, API communication, pending changes, and conflict handling.
- **`lib/features/device/`** bridges reminders and platform-specific device capabilities.

## Optional sync service

`backend/` contains a small Node.js API and PostgreSQL schema. The Flutter app encrypts record payloads before sending them. The service stores encrypted envelopes plus the identifiers and revision metadata needed to synchronize changes. It does not receive the recovery phrase or plaintext record payloads.

The API is intentionally single-account per deployment and is designed to sit behind private HTTPS for personal use. `backend/.env.example` contains placeholders; real credentials belong only in the ignored local `backend/.env` file. The encryption implementation has not been independently audited.

## Tests

`test/` mirrors app concerns with Flutter unit and widget tests. The backend's `http_security.test.mjs` exercises HTTP security behavior using Node's built-in test runner.

```powershell
flutter test
```

```powershell
cd backend
npm test
npm run check
```
