# PaTh

PaTh is a personal, offline-first life-tracking app for Android and Windows. It keeps records in a local SQLite database and can synchronize encrypted record content through an optional, self-hosted service.

## What it includes

- A customizable dashboard with quick actions and cards for daily tracking
- Trackers for habits, tasks, goals, mood, sleep, workouts, and other personal records
- Recent-history and analytics views, calendar, daily review, and reminders
- Local backup, restore, and CSV export
- Optional end-to-end encrypted sync between paired devices using a self-hosted API
- Android and Windows desktop builds

## Build from source

Install Flutter stable, Java 17 and Android SDK tools for Android builds, and Visual Studio with **Desktop development with C++** for Windows builds.

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build windows --release
```

The checked-in Android Gradle wrapper files are included for clean checkouts. Do not run `flutter create` in this existing project.

## Optional self-hosted sync

Sync requires a separately configured PostgreSQL database and API. See [backend/README.md](backend/README.md) for setup. Keep `backend/.env` private; start from the placeholder values in `backend/.env.example` and replace them with unique secrets. For phone access to a laptop-hosted server, use a private HTTPS route such as Tailscale Serve. Do not expose the API port or use Tailscale Funnel.

The server stores encrypted record envelopes and metadata needed to synchronize them; it does not receive plaintext record content or the recovery phrase. The encryption implementation has not had an independent security audit. Back up the database volume and store the recovery phrase securely: losing it makes synchronized record contents unreadable. Sync is unavailable when the self-hosted server is offline; local records continue to work.

## Backups and privacy

JSON exports contain personal journal, health, and financial records in plaintext. Store them privately. Pairing tokens and recovery phrases are not included in exports.

PaTh is a personal project. The Android package uses a development signing key and is not Play Store signed. The Windows build is not digitally signed. Review the code and security limitations before using it with sensitive records.

No open-source license is included. Public visibility lets people view the code, but does not grant permission to reuse or redistribute it.
