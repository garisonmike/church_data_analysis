# Fork & Deployment Guide

This guide covers everything you must do before a fork of Church Analytics is
production-ready under a different identity (church name, developer, or
distribution channel).

Work through the steps in order — each one builds on the last.

---

## 1. Change the Application ID

Open `android/app/build.gradle.kts` and change:

```kotlin
applicationId = "com.church.church_analytics"
```

to a unique reverse-domain ID you control, for example:

```kotlin
applicationId = "com.yourchurch.analytics"
```

This ID is permanent. Changing it after your first public release means users
must uninstall before installing the update (all local data is lost). Choose it
carefully.

---

## 2. Generate a Permanent Android Signing Keystore

Run this **once** from the project root. Use the alias `church_analytics` to
match what `android/key.properties.template` specifies:

```bash
keytool -genkey -v \
  -keystore android/keystore.jks \
  -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias church_analytics
```

Fill in the prompts. Keep the passwords you choose — you will need them in the
next step.

**Do not commit `android/keystore.jks` to git.** Verify your `.gitignore`
contains these two lines (they are already there):

```
android/keystore.jks
android/key.properties
```

Encode the keystore to Base64 so it can be stored as a GitHub Secret:

```bash
base64 -w 0 android/keystore.jks
```

Copy the full output string. That is your `KEYSTORE_BASE64` value.

---

## 3. Configure GitHub Secrets

Go to your repository on GitHub:
**Settings → Secrets and variables → Actions → New repository secret**

Add all six secrets:

| Secret name | Value |
|---|---|
| `KEYSTORE_BASE64` | The Base64 string from Step 2 |
| `KEYSTORE_STORE_PASSWORD` | The store password you chose in Step 2 |
| `KEYSTORE_KEY_PASSWORD` | The key password you chose in Step 2 |
| `KEYSTORE_KEY_ALIAS` | `church_analytics` |
| `SYNCFUSION_LICENSE_KEY` | From your Syncfusion account dashboard |
| `CRASH_REPORT_EMAIL` | Email address for crash log reports (optional) |

All six must be present before you push a release tag. Leaving
`SYNCFUSION_LICENSE_KEY` empty is safe — charts will show the community
watermark. Leaving `CRASH_REPORT_EMAIL` empty is safe — the Send Report button
is simply hidden from the crash dialog.

---

## 4. Update the In-App Update Manifest URL

Open `lib/services/update_service.dart` and find `_kProductionManifestUrl`.
Change it to point to your own repository's release download URL:

```dart
const _kProductionManifestUrl =
    'https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO/releases/latest/download/update.json';
```

Without this change the in-app update checker will point to the original
repository's releases and prompt your users to install the wrong APK.

---

## 5. Replace the App Icon

Replace `assets/images/icon.jpeg` with your church's logo. PNG is preferred;
minimum 1024 × 1024 pixels for best results across all densities.

Then run the generator:

```bash
dart run flutter_launcher_icons
```

Commit all generated icon files (Android mipmap folders, web icons, Windows
`.ico`). Do not commit only the source image and skip this step — the
platform-specific sizes will be wrong.

---

## 6. Run Code Generation

After any Drift schema change, or on a fresh clone where generated files are
missing:

```bash
dart run build_runner build --delete-conflicting-outputs
```

The generated file `lib/database/app_database.g.dart` is committed to the
repository so this step is not needed for normal development, only when you
change the database schema.

---

## 7. Verify Before First Release

Run these locally before pushing your first release tag:

```bash
flutter analyze
flutter test
flutter build apk --release \
  --dart-define=SYNCFUSION_LICENSE_KEY=your_key_here \
  --dart-define=CRASH_REPORT_EMAIL=your_email_here
```

Install the APK on a device. Verify:

- The launcher icon matches your image.
- Charts render without a community watermark.
- The app title bar shows your church's name after setup.
- The in-app update check points to your repository (not the original).

---

## 8. Push a Release Tag to Trigger CI

```bash
git tag v1.0.0
git push origin v1.0.0
```

The `build-release.yml` workflow runs automatically on any `v*` tag. It will:

1. Build and sign the Android APK with your keystore.
2. Build the Windows installer.
3. Build and push the Docker web image to GitHub Container Registry.
4. Stamp `docs/update.json` with the version and file checksums.
5. Create a GitHub Release and attach all assets.

Download the release APK and verify it installs over a previous version
**without** an uninstall prompt. If it requires an uninstall, the signing key
has changed — go back to Step 2.

---

## Ongoing maintenance

- **Keystore**: back it up outside the repo (e.g. a password manager or
  encrypted cloud storage). Losing it means you can never issue an update to
  existing installs.
- **Secrets**: if you rotate the keystore, update `KEYSTORE_BASE64` and both
  password secrets simultaneously and push a new release. Any APK signed with
  the old key is the last version users can update from before they need to
  reinstall.
- **Syncfusion key**: these are tied to your Syncfusion account licence tier.
  If the licence expires or is upgraded, update the `SYNCFUSION_LICENSE_KEY`
  secret and re-run CI.
