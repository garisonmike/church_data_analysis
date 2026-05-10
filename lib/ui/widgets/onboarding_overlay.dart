// lib/ui/widgets/onboarding_overlay.dart
//
// First-launch tutorial overlay.
//
// Usage (auto, on first launch — startup_gate_screen.dart):
//   final done = await isOnboardingComplete();
//   if (!done && mounted) {
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         fullscreenDialog: true,
//         builder: (_) => const OnboardingOverlay(),
//       ),
//     );
//   }
//
// Usage (manual, from App Settings):
//   OnboardingOverlay(fromSettings: true)
//
// The `fromSettings: true` flag skips writing the completion pref so
// re-opening from settings never resets the first-launch state.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingCompleteKey = 'onboarding_complete';

/// Returns true if the user has already completed (or dismissed) the
/// onboarding flow at least once.
Future<bool> isOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingCompleteKey) ?? false;
}

/// Marks the onboarding flow as complete so it is not shown again on launch.
/// Called automatically when the user finishes or skips the overlay —
/// unless [OnboardingOverlay.fromSettings] is true.
Future<void> markOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kOnboardingCompleteKey, true);
}

/// Full-screen onboarding tutorial shown on first launch.
///
/// Five slides covering the core app workflow. After the last slide
/// (or after tapping Skip / Close) the overlay is popped from the
/// navigator and, when [fromSettings] is false, the completion flag
/// is persisted so it never auto-shows again.
class OnboardingOverlay extends StatefulWidget {
  /// When true, replaces the "Skip" label with "Close" and does NOT
  /// write the completion pref — so re-opening from Settings never
  /// resets the first-launch behaviour.
  final bool fromSettings;

  const OnboardingOverlay({super.key, this.fromSettings = false});

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends State<OnboardingOverlay> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.church,
      title: 'Welcome to Church Analytics',
      body:
          'This app helps you track weekly attendance and financial records for '
          'your church. Start by creating a church profile.',
    ),
    _OnboardingPage(
      icon: Icons.edit_calendar,
      title: 'Weekly Record Entry',
      body:
          'Each week, tap "New Entry" from the dashboard to record attendance '
          'by group (Men, Women, Youth, Children) and financial figures '
          '(Tithe, Offerings).',
    ),
    _OnboardingPage(
      icon: Icons.upload_file,
      title: 'Importing Existing Data',
      body:
          'Have existing records in a spreadsheet? Use the Import feature to '
          'upload a CSV or XLSX file. The app guides you through mapping your '
          'columns.',
    ),
    _OnboardingPage(
      icon: Icons.bar_chart,
      title: 'Analytics & Charts',
      body:
          'The Graph Center gives you attendance trends, financial breakdowns, '
          'and correlations. All charts update automatically as you add records.',
    ),
    _OnboardingPage(
      icon: Icons.picture_as_pdf,
      title: 'Exporting Reports',
      body:
          'Go to Reports & Backup to export a PDF report, download your data '
          'as CSV, or create a full backup. Visit chart screens first to '
          'include graphs in your PDF.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _dismiss();
    }
  }

  Future<void> _dismiss() async {
    if (!widget.fromSettings) {
      await markOnboardingComplete();
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: Skip / Close ──────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: TextButton(
                  onPressed: _dismiss,
                  child: Text(widget.fromSettings ? 'Close' : 'Skip'),
                ),
              ),
            ),

            // ── Slides ─────────────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _pages[i],
              ),
            ),

            // ── Bottom bar: dots + Next / Get Started ──────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == i
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),

                  FilledButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ── Private slide widget ──────────────────────────────────────────────────────

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
