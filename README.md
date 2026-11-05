# PaTh

PaTh is an offline-first personal tracking app for Android and Windows. It stores records in local SQLite and can synchronize encrypted record content through the self-hosted API.

## Latest personal-use builds

- Android APK: `outputs/PaTh-Android.apk`
- Windows portable bundle: `outputs/PaTh-Windows-Portable.zip`
- Windows app folder: `outputs/PaTh-Windows-Release-2026-11-05/` — run `PaTh.exe` and keep its adjacent DLLs and `data/` folder together.

The Android APK updates the existing `com.example.life_os` app using the same development signing key. Installing it over that app preserves local data. This APK is for personal testing; it is not Play Store signed. The Windows ZIP is portable, not an installer, and is not digitally signed.

## Build from source

Prerequisites: Flutter stable, Android SDK command-line tools/platform tools, Java 17 for Android builds, and Visual Studio with **Desktop development with C++** for Windows builds.

```powershell
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build windows --release
```

Do not run `flutter create` in this existing project. The Android and Windows runners are already present.

## Private synchronization

See [backend/README.md](backend/README.md) for the self-hosted PostgreSQL and API setup. Docker Desktop must be running to use the local server. The API listens only on loopback; use a private HTTPS route such as Tailscale Serve for phone access. Do not expose the API port or enable Tailscale Funnel. Sync is unavailable while the laptop or server is offline; records continue to save locally and retry later.

## Backups and recovery

In the app, open **Settings → Backup, restore & export** and choose **Create backup & CSV exports**. The app writes JSON and dataset CSV files in its app documents folder under `PaTh-Exports`. On Windows, this is under the current user's Documents directory. Android uses app-specific documents storage, which may not appear in Downloads.

Restore accepts version 1 PaTh/legacy Life OS JSON backups. **Merge** adds records whose stable IDs are not already present. **Replace** replaces local record collections and queues sync updates/deletions; export a backup first. A failed import rolls back. Pairing tokens and recovery phrases are not exported.

JSON backups are plaintext and contain sensitive journal, health, and financial information; store them privately. Keep a separate backup of the server's PostgreSQL volume. Losing the sync recovery phrase makes encrypted synchronized record contents unreadable. Account key rotation and recovery are not implemented.

## Privacy and security boundaries

The app has no advertising SDKs or external AI processing. Sync record contents are encrypted client-side; the server still sees account/device IDs, record type/ID, revisions, and timing metadata. The encryption design has not received an independent security audit. TLS is required for non-local sync URLs. The self-hosting operator is responsible for HTTPS hosting, pairing-code secrecy/rotation, PostgreSQL backups, and protecting backup files.

## PaTh name update — 5 November 2026

- The Android launcher and reminder notifications, in-app title, Windows window title, and Windows file metadata use **PaTh**.
- The Android release APK was rebuilt, installed over the existing app, and launched on the connected phone. The Android package ID and local database name remain stable so the update keeps your existing data.
- The Windows release was rebuilt. The portable ZIP contains `PaTh.exe`, Flutter runtime files, and app data. Windows keeps its internal CMake target name `life_os`; the packaged executable is named `PaTh.exe`.
- `flutter analyze --no-pub` reports no errors or warnings. It still reports 136 info-level style notices.

## App icon update — 6 November 2026

The supplied black-and-white PaTh artwork is stored at `assets/branding/PaTh-app-icon-source.jpg` and used for all Android launcher sizes and the Windows executable icon. Both release builds completed, and the rebuilt Android APK was installed and launched on the connected phone.
## Verification status — 27 October 2026

- All **58 Flutter tests passed**. Drift emitted non-fatal multiple-test-database notices.
- `flutter analyze --no-pub` reported no errors or warnings; it returned code 1 because **136 info-level style notices** remain.
- Android and Windows release builds completed successfully. The APK is 62.1 MB; the Windows ZIP contains `PaTh.exe`, its Flutter runtime, and app data.
- The APK was installed over the connected phone app without clearing its data, launched, and visually inspected. The phone showed **Synced just now** afterward.
- The refreshed Windows package was launched and visually checked on the dashboard, Quick add menu, and Mood tracker history view. Windows showed **Synced just now**. The server recorded both phone and Windows check-ins and currently holds 10 encrypted records.
- Windows/Android app-to-app sync is configured and both devices have checked in. The UI and build checks passed; larger text was sampled on the connected phone and the original phone setting restored. Offline recovery, notification behavior, full assistive-technology review, independent security review, and signed distribution still need dedicated review before public production distribution.

See [outputs/PaTh_Redesign_Report_2026-10-27.md](outputs/PaTh_Redesign_Report_2026-10-27.md) for the detailed redesign and verification notes.
