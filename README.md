# PaTh

**Make space for the life you want to build.** PaTh is a private, offline-first tracker for the small things that shape your days: habits, goals, mood, sleep, movement, and more. A clear daily dashboard brings your quick actions and recent patterns together, while your records stay on your device.

PaTh runs on **Android and Windows**. Optional self-hosted sync lets paired devices share encrypted records while keeping the server under your control.

## Made for everyday use

- **A dashboard that fits you** — arrange the cards you care about and get to common updates through Quick add.
- **Track your own way** — keep habits, tasks, goals, mood, sleep, gym, study, and other personal records in one place.
- **See the recent picture** — use calendar, history, daily review, and analytics to notice your patterns over time.
- **Stay in control of your data** — work offline, create JSON backups, and export record sets as CSV.
- **Keep devices in sync, optionally** — pair Android and Windows with a self-hosted service; record contents are encrypted on the device before sync.

## Project layout

```text
.
├── android/                 Android app runner and launcher resources
├── assets/branding/         PaTh icon artwork
├── backend/                 Optional self-hosted sync API and database schema
├── docs/                    Architecture and project notes
├── lib/
│   ├── app/                 App setup, routing, navigation, and theme
│   ├── data/                Database, repositories, backup, and sync
│   └── features/            Dashboard, trackers, analytics, and settings UI
├── test/                    Flutter unit and widget tests
├── windows/                 Windows desktop runner and app icon
├── pubspec.yaml             Flutter app metadata and dependencies
└── README.md
```

See [docs/architecture.md](docs/architecture.md) for how the main pieces fit together.

## Build it

Install Flutter stable. For Android, also install Java 17 and the Android SDK tools. For Windows, use Visual Studio with **Desktop development with C++** enabled.

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build windows --release
```

The Android Gradle wrapper is included, so Android builds can start from a clean checkout. The Android package is development-signed, and the Windows executable is unsigned; neither is a store-ready installer.

## Optional private sync

The app works without a server. To synchronize paired devices, follow the [self-hosted sync setup](backend/README.md). Keep `backend/.env` private and replace every placeholder in `backend/.env.example` with unique values. For phone access to a laptop-hosted server, use a private HTTPS route such as Tailscale Serve; do not expose the API port or enable Tailscale Funnel.

Record contents are encrypted on the device before upload. The server still handles device and record metadata needed to order updates. This encryption has not received an independent security audit. Back up the database and keep the recovery phrase safe: losing it makes synchronized contents unreadable. Sync pauses when the self-hosted server is offline; local records remain available.

## Privacy notes

JSON backups contain personal journal, health, and financial records in plaintext. Keep backup files private. Pairing tokens and recovery phrases are not included in exports.

PaTh is a personal project. There is no open-source license, so public visibility allows people to view the code but does not grant reuse or redistribution rights. The project is not independently security-audited; review its limitations before using it for sensitive records.
