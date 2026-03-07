# Release Workflow

## Overview

This document defines the release process for Church Analytics, from development through production deployment.

**Last Updated:** 2026-03-07  
**Current Version:** 1.2.0

---

## Branch Strategy

### Branch Overview

| Branch | Purpose | Stability | Protected |
|--------|---------|-----------|-----------|
| `develop` | Active development and feature integration | Unstable | No |
| `main` | Production-ready code; release candidates | Stable | Yes |

### Branch Workflow

```
develop (1.3.0-dev) → PR → main (1.3.0-rc) → Tag v1.3.0 → Release
```

- **`develop`**: All feature branches merge here first
- **`main`**: Receives PRs from `develop` when ready for release
- **Tags**: Applied to `main` after final verification

---

## Version Numbering Strategy

### Semantic Versioning

Church Analytics follows [Semantic Versioning 2.0.0](https://semver.org/):

```
MAJOR.MINOR.PATCH+BUILD
```

**Example:** `1.3.2+5`

| Component | When to Increment | Example |
|-----------|-------------------|---------|
| **MAJOR** | Breaking changes (database schema, API incompatibility) | `1.x.x` → `2.0.0` |
| **MINOR** | New features (backward compatible) | `1.2.x` → `1.3.0` |
| **PATCH** | Bug fixes only (no new features) | `1.2.3` → `1.2.4` |
| **BUILD** | Every build (increments automatically) | `1.2.3+4` → `1.2.3+5` |

### Version File Location

Version is defined in **`pubspec.yaml`**:

```yaml
version: 1.2.0+2
```

### Version Update Rules

1. **Feature release**: Increment MINOR, reset PATCH to 0, increment BUILD
   - `1.2.0+2` → `1.3.0+3`

2. **Bug fix release**: Increment PATCH, increment BUILD
   - `1.2.0+2` → `1.2.1+3`

3. **Breaking change**: Increment MAJOR, reset MINOR and PATCH to 0, increment BUILD
   - `1.2.0+2` → `2.0.0+3`

---

## Release Process

### Phase 1: Feature Development (develop)

**Branch:** `develop`

1. Create feature branches from `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/your-feature-name
   ```

2. Develop and test locally

3. Merge feature branch back into `develop`:
   ```bash
   git checkout develop
   git merge feature/your-feature-name
   git push origin develop
   ```

### Phase 2: Release Preparation (develop → main)

**When:** Features for next release are complete and tested

1. **Update version in `pubspec.yaml`:**
   ```yaml
   version: 1.3.0+3  # Increment appropriately
   ```

2. **Update `docs/update.json`** with new version and release notes:
   ```json
   {
     "version": "1.3.0",
     "release_date": "2026-03-15",
     "release_notes": "## What's New\n\n- Feature A\n- Feature B"
   }
   ```

3. **Commit version bump:**
   ```bash
   git add pubspec.yaml docs/update.json
   git commit -m "chore: bump version to 1.3.0"
   git push origin develop
   ```

4. **Create Pull Request from `develop` to `main`:**
   - Title: `Release v1.3.0`
   - Description: Include release notes from `update.json`
   - Ensure all CI checks pass

5. **Review and merge PR** (requires approval if branch protection is enabled)

### Phase 3: Tagging and Release (main)

**Branch:** `main`

1. **Pull latest `main`:**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **Create annotated tag:**
   ```bash
   git tag -a v1.3.0 -m "Release version 1.3.0"
   git push origin v1.3.0
   ```

3. **GitHub Actions automatically:**
   - Builds Android APK
   - Builds Windows installer
   - Builds Web Docker image
   - Creates GitHub Release with assets attached

### Phase 4: Release Asset Upload

**Manual step required:** Upload `update.json` to the release

1. Go to: https://github.com/GarisonMike/church_data_analysis/releases/tag/v1.3.0

2. Click **"Edit release"**

3. Upload `docs/update.json` as an additional asset

4. Verify the following assets are attached:
   - `app-release.apk` (Android)
   - `ChurchAnalytics-Windows.zip` (Windows)
   - `update.json` (Update manifest)

5. Click **"Update release"**

6. **Verify update.json is accessible:**
   ```bash
   curl https://github.com/GarisonMike/church_data_analysis/releases/latest/download/update.json
   ```

### Phase 5: Post-Release

1. **Merge main back to develop** to keep branches in sync:
   ```bash
   git checkout develop
   git merge main
   git push origin develop
   ```

2. **Verify update detection** in a running app instance:
   - Go to Settings → About
   - Tap "Check for Updates"
   - Confirm new version is detected

---

## GitHub Actions Workflow

### Trigger Conditions

The `.github/workflows/build-release.yml` workflow triggers on:

| Event | Trigger | Action |
|-------|---------|--------|
| Push to `develop` | Every push | Build artifacts (no release) |
| Push to `main` | Every push | Build artifacts + push Docker image |
| Tag push `v*` | Tag creation | Build artifacts + create GitHub Release |

### Build Artifacts Generated

| Platform | Artifact Name | Path | Size (approx) |
|----------|---------------|------|---------------|
| Android | `app-release.apk` | `build/app/outputs/flutter-apk/` | ~50 MB |
| Windows | `ChurchAnalytics-Windows.zip` | `build/windows/x64/runner/Release/` | ~30 MB |
| Docker | `ghcr.io/garisonmike/church-analytics-web` | Container Registry | ~200 MB |

### Required Secrets

None required (uses `GITHUB_TOKEN` automatically).

---

## Release Checklist

Use this checklist for every release:

### Pre-Release

- [ ] All features for this release are merged into `develop`
- [ ] All tests pass locally (`flutter test`)
- [ ] Version incremented in `pubspec.yaml`
- [ ] `docs/update.json` updated with new version and release notes
- [ ] Release notes include all user-facing changes
- [ ] Version bump committed to `develop`

### Release

- [ ] PR created from `develop` to `main`
- [ ] PR approved and merged
- [ ] Annotated tag created on `main` (`git tag -a v1.x.x -m "..."`)
- [ ] Tag pushed to GitHub (`git push origin v1.x.x`)
- [ ] GitHub Actions workflow completed successfully
- [ ] GitHub Release created automatically

### Post-Release

- [ ] `update.json` uploaded to GitHub Release as asset
- [ ] All expected assets attached to release:
  - `app-release.apk`
  - `ChurchAnalytics-Windows.zip`
  - `update.json`
- [ ] `update.json` accessible at stable URL:
  ```
  https://github.com/GarisonMike/church_data_analysis/releases/latest/download/update.json
  ```
- [ ] `main` merged back into `develop`
- [ ] Update detection verified in running app

---

## Hotfix Process

For critical bugs in production that can't wait for the next feature release:

1. **Create hotfix branch from `main`:**
   ```bash
   git checkout main
   git checkout -b hotfix/critical-bug-fix
   ```

2. **Fix the bug and test thoroughly**

3. **Update version (PATCH increment only):**
   ```yaml
   version: 1.2.1+3  # Was 1.2.0+2
   ```

4. **Update `docs/update.json`**

5. **Merge hotfix to `main`:**
   ```bash
   git checkout main
   git merge hotfix/critical-bug-fix
   git push origin main
   ```

6. **Tag and release** (follow Phase 3 above)

7. **Merge `main` back to `develop`:**
   ```bash
   git checkout develop
   git merge main
   git push origin develop
   ```

---

## Version History

| Version | Release Date | Type | Key Changes |
|---------|--------------|------|-------------|
| 1.2.0 | 2026-03-06 | Minor | Android export fixes, update system, storage refactor |
| 1.1.0 | 2026-02-15 | Minor | Activity logging, export UI improvements |
| 1.0.0 | 2026-01-20 | Major | Initial stable release |

---

## Rollback Procedure

If a release has critical issues:

1. **Do NOT delete the problematic release or tag**

2. **Create a new hotfix** following the hotfix process above

3. **Alternatively, revert to previous version:**
   ```bash
   git checkout main
   git revert <commit-hash>  # Revert the problematic merge
   git push origin main
   git tag -a v1.2.1 -m "Rollback release"
   git push origin v1.2.1
   ```

4. Update `docs/update.json` to point to the stable version

---

## Continuous Deployment

### Docker Image (Web)

Docker images are automatically built and pushed on:
- Every push to `main`
- Every tag creation

**Image Tags:**
- `latest` — most recent tagged release
- `main` — latest `main` branch build
- `v1.3.0` — specific version tags

**Pull command:**
```bash
docker pull ghcr.io/garisonmike/church-analytics-web:latest
```

### Future: Automatic Update Deployment

Future improvements planned:
- Automatic F-Droid/Google Play upload (Android)
- Automatic Microsoft Store upload (Windows)
- Auto-update Linux AppImage releases

---

## Troubleshooting

### Issue: Tag created but no release appeared

**Solution:**
- Check GitHub Actions workflow status
- Ensure the tag starts with `v` (e.g., `v1.3.0`)
- Verify the tag was pushed to GitHub (`git push origin v1.3.0`)

### Issue: update.json returns 404

**Solution:**
- Verify `update.json` was manually uploaded to the release
- Check URL: `https://github.com/GarisonMike/church_data_analysis/releases/latest/download/update.json`

### Issue: App not detecting new version

**Solution:**
- Clear app cache or reinstall
- Verify `version` field in `update.json` is higher than current app version
- Check app update check logs for errors

---

## Related Documentation

- [Update System Contract](update-contract.md) — Update manifest schema and trust model
- [GitHub Workflow](.github/workflows/build-release.yml) — CI/CD automation
- [Semantic Versioning](https://semver.org/) — Official semver specification

---

## Questions?

For release-related questions or issues, contact the development team or open a GitHub issue with the `release` label.
