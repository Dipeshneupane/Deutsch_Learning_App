import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/app_state.dart';
import '../services/analytics_service.dart';
import '../widgets/app_shell.dart';
import 'privacy_policy_screen.dart';
import 'terms_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return AppShell(
      title: 'Settings',
      child: ListView(
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark mode'),
              subtitle: const Text('Switch between light and dark themes.'),
              value: appState.isDarkMode,
              onChanged: (value) {
                context.read<AppState>().toggleDarkMode(value);
              },
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Reset progress'),
              subtitle: const Text(
                'Clear learned words, favorites, quiz results, XP, and streak.',
              ),
              onTap: () async {
                final appStateReader = context.read<AppState>();
                final messenger = ScaffoldMessenger.of(context);
                final confirmed =
                    await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Reset progress?'),
                          content: const Text(
                            'This will remove your local progress on this device.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Reset'),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;

                if (!confirmed) {
                  return;
                }

                await appStateReader.resetProgress();
                messenger.showSnackBar(
                  const SnackBar(content: Text('Local progress reset.')),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text(
                    'Review how local progress, analytics, and ads are handled.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.gavel_outlined),
                  title: const Text('Terms of Use'),
                  subtitle: const Text(
                    'Read the current usage terms for this app version.',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TermsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About app'),
              subtitle: const Text(
                'See project scope, API base URL, and ad placeholder details.',
              ),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Deutsch Starter',
                  applicationVersion: 'Version 1.0.0',
                  children: [
                    const Text(
                      'Beginner-friendly German flashcards and grammar quizzes with local-only progress.',
                    ),
                    const SizedBox(height: 12),
                    Text('API base URL: ${AppConfig.apiBaseUrl}'),
                    const SizedBox(height: 8),
                    Text(
                      'AdMob banner test ID: ${AppConfig.admobBannerTestId}',
                    ),
                    Text(
                      'AdMob interstitial test ID: ${AppConfig.admobInterstitialTestId}',
                    ),
                    Text(
                      'AdSense placeholder slot: ${AppConfig.adsensePlaceholderSlot}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Firebase telemetry enabled: ${AppConfig.firebaseTelemetryEnabled}',
                    ),
                    Text(
                      'Analytics active now: ${AnalyticsService.instance.isEnabled}',
                    ),
                    Text(
                      'Crash reporting active now: ${AnalyticsService.instance.isCrashReportingEnabled}',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
