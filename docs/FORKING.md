your `applicationId`.
# Forking Church Analytics — Identity & Deployment

This guide combines all steps needed to fork Church Analytics for another
church or organization. Work through the steps in order.

For release mechanics, CI tagging, and ongoing maintenance, also see
`docs/RELEASE.md`.

---

## 1. Android launcher name (home screen label)

This is what users see on their phone's home screen and in the app drawer.

**File:** `android/app/src/main/AndroidManifest.xml`

Find:

```xml
android:label="church_analytics"
```

Change to your church name, for example:

```xml
android:label="Nairobi Central SDA"
```

Keep it short — long names are truncated on small screens.

---

## 2. Android application ID (package name)

Required if you intend to publish to the Google Play Store. Two apps on the
Play Store cannot share the same `applicationId`.

**File:** `android/app/build.gradle.kts`

Find and change both `namespace` and `applicationId`:

```kotlin
// BEFORE
namespace   = "com.church.church_analytics"
applicationId = "com.church.church_analytics"

// AFTER — use a reverse-domain ID you control
namespace   = "com.nairobicentralsda.analytics"
applicationId = "com.nairobicentralsda.analytics"
```

Warning: The `applicationId` is permanent. Changing it after your first
public release means existing users must uninstall the old app before
installing the update. Choose carefully before your first release.

---

## 3. Windows app name (taskbar and title bar)

**File:** `windows/runner/Runner.rc`

Find the two `VALUE` entries (around line 93 and 98):

```rc
VALUE "FileDescription", "church_analytics" "\0"
VALUE "ProductName",     "church_analytics" "\0"
```

Change both to your church name:

```rc
VALUE "FileDescription", "Nairobi Central SDA" "\0"
VALUE "ProductName",     "Nairobi Central SDA" "\0"
```

These strings control what appears in the Windows taskbar tooltip, the
Alt+Tab switcher, and the Windows Apps & Features list.

---

## 4. In-app display name (app bar titles and About screen)

The string "Church Analytics" is used directly in several screens as the
human-readable app name shown in app bar titles and the About section.

Search the `lib/` directory and replace all occurrences:

```bash
# Preview all occurrences first
grep -rn '"Church Analytics"' lib/

# Then replace (macOS)
find lib/ -name "*.dart" -exec sed -i '' 's/"Church Analytics"/"Your Church Name"/g' {} +

# Then replace (Linux)
find lib/ -name "*.dart" -exec sed -i 's/"Church Analytics"/"Your Church Name"/g' {} +

# Windows (PowerShell)
Get-ChildItem -Recurse -Filter "*.dart" lib/ |
  ForEach-Object { (Get-Content $_) -replace '"Church Analytics"', '"Your Church Name"' | Set-Content $_ }
```

There are approximately 8–12 occurrences across screens. After replacing,
run `flutter analyze` to confirm no syntax errors were introduced.

---

## 5. Update the in-app update manifest URL

Open `lib/services/update_service.dart` and find `_kProductionManifestUrl`.
Change it to point to your repository's release download URL:

```dart
const _kProductionManifestUrl =
    'https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPO/releases/latest/download/update.json';
```

Without this change, the update checker will point to the original repository.

---

## 6. App icon

Replace `assets/images/app_icon.png` with your church's logo and regenerate
all platform icon sizes. Full instructions are in `docs/CUSTOMISATION.md`.

---

## 7. Android signing keystore

Generate a new keystore for your fork. Do not reuse the original keystore.

Run this once from the project root. Use the alias `church_analytics` to match
`android/key.properties.template`:

```bash
keytool -genkey -v \
  -keystore android/keystore.jks \
  -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias church_analytics
```

Do not commit `android/keystore.jks` to git. Verify your `.gitignore` contains:

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

## 8. Configure GitHub Secrets

Go to your repository on GitHub:
Settings → Secrets and variables → Actions → New repository secret

Add all six secrets:

| Secret name | Value |
|---|---|
| `KEYSTORE_BASE64` | The Base64 string from Step 7 |
| `KEYSTORE_STORE_PASSWORD` | The store password you chose in Step 7 |
| `KEYSTORE_KEY_PASSWORD` | The key password you chose in Step 7 |
| `KEYSTORE_KEY_ALIAS` | `church_analytics` |
| `SYNCFUSION_LICENSE_KEY` | From your Syncfusion account dashboard |
| `CRASH_REPORT_EMAIL` | Email address for crash log reports (optional) |

Leaving `SYNCFUSION_LICENSE_KEY` empty is safe — charts will show the community
watermark. Leaving `CRASH_REPORT_EMAIL` empty is safe — the Send Report button
is hidden from the crash dialog.

---

## 9. `pubspec.yaml` package name (optional)

**File:** `pubspec.yaml`, top line:

```yaml
name: church_analytics
```

This is the Dart package name, used internally for import paths
(`package:church_analytics/...`). It is not visible to end users.

You only need to change this if:
- You intend to publish to pub.dev, or
- You want the import paths to reflect your fork's identity.

If you do change it, run a global find-and-replace across all `lib/` imports:

```bash
find lib/ -name "*.dart" -exec sed -i '' \
  's|package:church_analytics/|package:your_package_name/|g' {} +
```

Then update the `name:` field in `pubspec.yaml` to match.

If you are not publishing to pub.dev, skip this step — leaving
`name: church_analytics` causes no problems at runtime.

---

## 10. Run code generation (only if schema changes)

After any Drift schema change, or on a fresh clone where generated files are
missing:

```bash
dart run build_runner build --delete-conflicting-outputs
```

The generated file `lib/database/app_database.g.dart` is committed to the
repository, so this step is not needed for normal development.

---

## 11. Verify before first release

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

## 12. Push a release tag to trigger CI

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
without an uninstall prompt. If it requires an uninstall, the signing key has
changed — go back to Step 7.

---

## 13. Ongoing maintenance

- Keystore: back it up outside the repo. Losing it means you can never issue an
  update to existing installs.
- Secrets: if you rotate the keystore, update `KEYSTORE_BASE64` and both
  password secrets simultaneously and push a new release.
- Syncfusion key: update `SYNCFUSION_LICENSE_KEY` if your license tier changes.

---

## Quick reference — name locations

| Location | File | Controls |
|---|---|---|
| Android home screen label | `android/app/src/main/AndroidManifest.xml` | `android:label` attribute on `<application>` |
| Android package / Play Store ID | `android/app/build.gradle.kts` | `namespace` and `applicationId` |
| Windows taskbar / title | `windows/runner/Runner.rc` | `ProductName` and `FileDescription` VALUES |
| In-app titles and About screen | `lib/` (multiple `.dart` files) | Hardcoded "Church Analytics" strings (~8–12 occurrences) |
| Dart package name (internal) | `pubspec.yaml` | `name:` field (optional to change) |
| App icon | `assets/images/app_icon.png` | See `docs/CUSTOMISATION.md` |
