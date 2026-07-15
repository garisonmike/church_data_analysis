// Demo-mode seed identity. Used only when demo mode is enabled in
// app_database.dart; production builds (demo mode off) never read these.
//
// Forks can rebrand the demo church at build time without touching code:
//   flutter run --dart-define=DEMO_CHURCH_NAME="My Church" \
//               --dart-define=DEMO_CHURCH_EMAIL="clerk@mychurch.org"

const kDemoChurchName = String.fromEnvironment(
  'DEMO_CHURCH_NAME',
  defaultValue: 'Demo Church',
);

const kDemoChurchAddress = String.fromEnvironment(
  'DEMO_CHURCH_ADDRESS',
  defaultValue: 'P.O. Box 000, Demo Town',
);

const kDemoChurchEmail = String.fromEnvironment(
  'DEMO_CHURCH_EMAIL',
  defaultValue: 'clerk@example.org',
);

const kDemoChurchPhone = String.fromEnvironment(
  'DEMO_CHURCH_PHONE',
  defaultValue: '+254700000000',
);

const kDemoChurchCurrency = String.fromEnvironment(
  'DEMO_CHURCH_CURRENCY',
  defaultValue: 'KES',
);

const kDemoChurchWebsite = String.fromEnvironment(
  'DEMO_CHURCH_WEBSITE',
  defaultValue: 'example.org',
);
