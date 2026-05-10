// Build-time injected secrets. Values come from --dart-define flags.
// Never put real values in this file.

/// Syncfusion Charts license key.
/// Empty string means no license registration.
const kSyncfusionLicenseKey = String.fromEnvironment('SYNCFUSION_LICENSE_KEY');

/// Email address to receive crash log reports.
/// Empty string hides the Send Report action.
const kCrashEmail = String.fromEnvironment('CRASH_REPORT_EMAIL');
