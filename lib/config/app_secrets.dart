// Build-time injected secrets. Values come from --dart-define flags.
// Never put real values in this file.

/// Email address to receive crash log reports.
/// Empty string hides the Send Report action.
const kCrashEmail = String.fromEnvironment('CRASH_REPORT_EMAIL');
