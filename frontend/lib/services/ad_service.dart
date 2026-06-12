import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';

class AdService {
  static Future<void> showQuizCompletionInterstitial(
    BuildContext context,
  ) async {
    if (kIsWeb || !context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Interstitial Ad Placeholder'),
          content: Text(
            'Replace this mobile interstitial placeholder later with '
            'a real AdMob integration.\n\n'
            'Current test ID:\n${AppConfig.admobInterstitialTestId}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }
}
