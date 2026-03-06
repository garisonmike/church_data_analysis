# Update System Contract and Trust Model

## Overview

This document defines the contract for the Church Analytics update system, including the `update.json` manifest schema, trust model, security considerations, and implementation requirements.

## Version

**Contract Version:** 1.0.1  
**Last Updated:** 2026-03-06

---

## update.json Schema

### Stable URL Format

The `update.json` manifest MUST be hosted at the following stable URL:

```
https://github.com/GarisonMike/church_data_analysis/releases/latest/download/update.json
```

**Requirements:**
- MUST use `https://` scheme (HTTP is explicitly rejected)
- MUST be accessible without authentication
- MUST include CORS headers for Web client compatibility:
  - `Access-Control-Allow-Origin: *`
  - `Access-Control-Allow-Methods: GET, HEAD`

### Schema Definition

```json
{
  "version": "1.2.0",
  "release_date": "2026-03-01",
  "min_supported_version": "1.0.0",
  "release_notes": "- Fixed overflow bug\n- Improved import speed\n- Added export enhancements",
  "platforms": {
    "android": {
      "download_url": "https://github.com/GarisonMike/church_data_analysis/releases/download/v1.2.0/app-release.apk",
      "sha256": "abc123def456..."
    },
    "windows": {
      "download_url": "https://github.com/GarisonMike/church_data_analysis/releases/download/v1.2.0/ChurchAnalytics-Setup.exe",
      "sha256": "def456ghi789..."
    },
    "linux": {
      "download_url": "https://github.com/GarisonMike/church_data_analysis/releases/download/v1.2.0/church-analytics-linux.tar.gz",
      "sha256": "ghi789jkl012..."
    }
  }
}
```

### Field Specifications

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `version` | string | Yes | Semantic version string (e.g., "1.2.0") |
| `release_date` | string | Yes | ISO 8601 date (YYYY-MM-DD) |
| `min_supported_version` | string | Yes | Minimum app version that can upgrade to this release |
| `release_notes` | string | Yes | Markdown-formatted release notes |
| `platforms` | object | Yes | Platform-specific download assets |
| `platforms.<platform>` | object | No | Per-platform asset (android, windows, linux) |
| `platforms.<platform>.download_url` | string | Yes | HTTPS URL to installer binary |
| `platforms.<platform>.sha256` | string | Yes | SHA-256 checksum of the installer (hex-encoded) |

### Validation Rules

1. **Version Format**: MUST follow semantic versioning (major.minor.patch)
2. **Date Format**: MUST be ISO 8601 (YYYY-MM-DD)
3. **Download URLs**: MUST use `https://` scheme
4. **SHA-256**: MUST be 64-character hex string
5. **Unknown Fields**: MUST be ignored (forward compatibility)
6. **Missing Required Fields**: MUST throw `UpdateManifestParseException`

### Example Valid Manifest

```json
{
  "version": "1.3.0",
  "release_date": "2026-03-15",
  "min_supported_version": "1.0.0",
  "release_notes": "## What's New\n\n- **Storage**: Fixed export path handling\n- **UI**: Improved settings layout\n- **Performance**: Reduced memory usage by 15%\n\n## Bug Fixes\n\n- Resolved crash on large dataset export\n- Fixed timezone handling in reports",
  "platforms": {
    "android": {
      "download_url": "https://github.com/GarisonMike/church_data_analysis/releases/download/v1.3.0/church-analytics-v1.3.0.apk",
      "sha256": "a3f5d8c9e2b1f4c6a8d9e7f2b5c4a1d8e9f7c2b6a4d1e8f9c7b2a5d4e1f8c9d2"
    },
    "windows": {
      "download_url": "https://github.com/GarisonMike/church_data_analysis/releases/download/v1.3.0/ChurchAnalytics-v1.3.0-Setup.exe",
      "sha256": "b4e6d9c0e3b2f5c7a9d0e8f3b6c5a2d9e0f8c3b7a5d2e9f0c8b3a6d5e2f9c0d3"
    },
    "linux": {
      "download_url": "https://github.com/GarisonMike/church_data_analysis/releases/download/v1.3.0/church-analytics-v1.3.0-linux-x64.tar.gz",
      "sha256": "c5f7e0d1e4b3f6c8a0d1e9f4b7c6a3d0e1f9c4b8a6d3e0f1c9b4a7d6e3f0c1d4"
    }
  }
}
```

---

## Trust Model

### Security Boundaries

The update system implements **integrity verification** but does not currently implement **source authenticity verification**. Understanding this distinction is critical:

#### What We Verify ✓

1. **Transport Security**: All URLs MUST use HTTPS to prevent man-in-the-middle attacks during manifest and installer downloads
2. **File Integrity**: Downloaded installers are verified against their SHA-256 checksum to detect corruption or modification after publication
3. **Schema Validation**: The manifest structure is validated to prevent crashes from malformed data

#### What We Do NOT Verify ✗

1. **Manifest Authenticity**: The `update.json` file itself is not cryptographically signed or verified
2. **Source Identity**: We do not verify that the manifest or installers came from the legitimate publisher
3. **Compromise Detection**: If the GitHub repository or its credentials are compromised, a malicious `update.json` with matching SHA-256 hashes could redirect users to attacker-controlled binaries

### Trust Assumptions

Users of this update system trust:

1. **GitHub Infrastructure**: That GitHub's release hosting is not compromised
2. **Repository Access Control**: That only authorized maintainers can publish releases
3. **HTTPS/TLS**: That TLS certificate validation works correctly to prevent DNS or routing attacks
4. **Build Pipeline**: That the CI/CD pipeline producing releases is secure

### Threat Model

| Threat | Mitigation | Residual Risk |
|--------|------------|---------------|
| Network MITM | HTTPS enforcement | Low (relies on TLS) |
| Corrupted download | SHA-256 verification | Low |
| Compromised GitHub repo | None (see Future Work) | **High** |
| Malicious `update.json` | HTTPS only, host awareness | **Medium** |
| DNS hijacking | HTTPS + OS root certs | Low |
| Partial download | Checksum failure detection | Low |

### Accepted Risks

The current implementation accepts the following risks:

1. **Supply Chain Compromise**: If an attacker gains write access to the GitHub repository, they can publish a malicious update that will pass all integrity checks
2. **Trust on First Use**: There is no out-of-band verification of the initial `update.json` URL
3. **Dependency on GitHub**: The update system is centralized on GitHub infrastructure

These risks are typical for self-hosted update systems without separate signing infrastructure and are acceptable for open-source applications with limited budget and threat profile.

---

## HTTPS Enforcement

### Requirements

All update-related URLs MUST use the `https://` scheme. HTTP URLs are explicitly rejected.

**Rejected URL Examples:**
- `http://github.com/...` ❌
- `ftp://example.com/...` ❌
- `file:///tmp/update.json` ❌
- `//example.com/update.json` ❌

**Accepted URL Examples:**
- `https://github.com/GarisonMike/church_data_analysis/releases/latest/download/update.json` ✓
- `https://github.com/GarisonMike/church_data_analysis/releases/download/v1.2.0/app-release.apk` ✓

### Implementation

The `UpdateUrlValidator` utility enforces HTTPS:

```dart
/// Validates that a URL uses HTTPS scheme
/// Returns the validated URL if valid
/// Throws UpdateSecurityException if invalid
static String validateHttpsUrl(String url) {
  final uri = Uri.tryParse(url);
  
  if (uri == null) {
    throw UpdateSecurityException('Invalid URL format: $url');
  }
  
  if (uri.scheme != 'https') {
    throw UpdateSecurityException(
      'Update URLs must use HTTPS. Got: ${uri.scheme}://',
    );
  }
  
  return url;
}
```

### Enforcement Points

HTTPS validation MUST be applied at:

1. **Manifest URL** (in `UpdateService.checkForUpdate()`)
2. **Platform Asset URLs** (in `UpdateDownloadService.downloadInstaller()`)
3. **Any Redirect URLs** (if following HTTP 3xx responses)

---

## Future Work: Signature Verification

### Architectural Extension Point

The current implementation is designed to support future detached signature verification without breaking changes:

```json
{
  "version": "1.5.0",
  "release_date": "2026-06-01",
  "min_supported_version": "1.0.0",
  "release_notes": "...",
  "signature": {
    "algorithm": "ed25519",
    "public_key": "base64-encoded-public-key",
    "signature": "base64-encoded-signature-of-canonical-json"
  },
  "platforms": { ... }
}
```

### Planned Strategy (Not Implemented)

1. **Signing Key Management**:
   - Generate Ed25519 signing key pair
   - Store private key in CI/CD secrets
   - Embed public key in app at build time

2. **Signing Process**:
   - Canonical JSON serialization of manifest (minus `signature` field)
   - Sign with Ed25519 private key
   - Append `signature` field to manifest

3. **Verification Process**:
   - Extract `signature` field
   - Canonical JSON serialization of remaining manifest
   - Verify signature using embedded public key
   - Reject updates with invalid or missing signatures (after migration period)

4. **Key Rotation**:
   - Support multiple public keys during transition
   - Add `signature.key_id` field to identify which key was used

### Why Not Implemented Now

1. **Development Priority**: Core update functionality must be validated first
2. **Complexity**: Key management and rotation requires careful planning
3. **Backward Compatibility**: Existing clients cannot verify signatures
4. **Risk Profile**: Acceptable for current threat model and user base

Signature verification MUST be implemented before:
- The application handles sensitive data (e.g., financial records)
- The user base exceeds 10,000 active installations
- A security audit identifies supply-chain security as a critical risk

---

## Web Platform Considerations

### CORS Configuration

The `update.json` file MUST be served with permissive CORS headers to support Web clients:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, HEAD
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 86400
```

GitHub Releases automatically provides these headers for publicly accessible assets.

### Cache Invalidation

Web browsers and CDNs may cache `update.json`, preventing update detection. Two strategies are available:

#### Strategy 1: Query Parameter Versioning (Recommended) ✅ Implemented

A `cb` (cache-buster) query parameter containing the current epoch in
milliseconds is appended to the manifest URL immediately before every HTTP GET:

```dart
// Inside UpdateService._buildFetchUri()
final params = Map<String, String>.from(base.queryParameters)
  ..['cb'] = '${DateTime.now().millisecondsSinceEpoch}';
return base.replace(queryParameters: params);
```

Example resulting URL:
```
https://github.com/GarisonMike/church_data_analysis/releases/latest/download/update.json?cb=1741270800000
```

**Effect**: Browsers and CDNs cache by exact URL. Each unique `cb` value
creates a distinct cache key, forcing a network request for the latest
manifest.

**Bandwidth cost**: Negligible — `UpdateService` only issues one HTTP GET per
session (subsequent calls return the in-memory cached result).  After a manual
`resetCache()`, a fresh fetch with a new timestamp is issued, which is the
correct behaviour.

**GitHub Releases compatibility**: Confirmed — GitHub Releases ignores unknown
query parameters and serves the file normally.

#### Strategy 2: Cache-Control Headers

Configure the release hosting to serve `update.json` with short-lived cache headers:

```
Cache-Control: public, max-age=3600, must-revalidate
```

**Pros**: Allows some caching for efficiency  
**Cons**: Requires control over hosting configuration (GitHub Releases uses default caching)

**Recommendation**: Use Strategy 1 (query parameters) in Web builds. Accept the minimal bandwidth cost for guaranteed freshness.

---

## Implementation Checklist

When implementing the update system, developers MUST:

- [ ] Validate the manifest URL is HTTPS before fetching
- [ ] Validate all platform asset URLs are HTTPS before downloading
- [ ] Parse the manifest with forward-compatible JSON handling (ignore unknown fields)
- [ ] Verify SHA-256 checksums after downloads complete
- [ ] Handle network errors gracefully with user-friendly messages
- [ ] Cache successful update checks for the session to avoid excessive requests
- [ ] Provide a fallback link to the GitHub Releases page in all error states
- [ ] Log update checks and failures to the activity log (see STORAGE-004)
- [ ] Enforce a 10-second timeout on network requests
- [ ] Delete partial downloads if checksum verification fails
- [x] Append cache-busting `?cb=<epoch_ms>` query parameter to manifest URL before each fetch (UPDATE-012)

---

## Testing Requirements

Update system components MUST include tests for:

1. **Valid Manifest Parsing**: Parse a complete, well-formed `update.json`
2. **Unknown Fields**: Ignore extra fields not in the schema (forward compatibility)
3. **Missing Required Fields**: Throw `UpdateManifestParseException`
4. **Malformed JSON**: Handle syntax errors gracefully
5. **HTTP URL Rejection**: Reject non-HTTPS manifest and asset URLs
6. **Invalid Schema**: Reject malformed URLs, invalid date formats, etc.
7. **Network Timeout**: Simulate slow/stalled connections
8. **Checksum Mismatch**: Verify rejection of tampered installer files

---

## Contact and Review

For questions or proposed changes to this contract:

- **Repository**: [https://github.com/GarisonMike/church_data_analysis](https://github.com/GarisonMike/church_data_analysis)
- **Issues**: File a GitHub issue with the `update-system` label
- **Security Concerns**: Open a security advisory (see SECURITY.md)

---

## Changelog

### v1.0.1 (2026-03-06)
- **Cache invalidation implemented (UPDATE-012)**: `UpdateService` now appends
  `?cb=<epoch_ms>` to the manifest URL via `_buildFetchUri()`, preventing
  stale Web browser / CDN cache hits.
- CORS requirements documented under Web Platform Considerations.
- Implementation checklist updated with cache-invalidation item.

### v1.0.0 (2026-03-06)
- Initial contract definition
- HTTPS enforcement requirements
- Trust model documentation
- Future signature verification architecture
