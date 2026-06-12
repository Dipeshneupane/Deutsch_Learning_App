import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';

class PlaceholderAdBanner extends StatelessWidget {
  const PlaceholderAdBanner({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = kIsWeb ? 'AdSense Placeholder' : 'AdMob Banner Placeholder';
    final subtitle = kIsWeb
        ? AppConfig.adsensePlaceholderSlot
        : AppConfig.admobBannerTestId;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
      ),
      child: Row(
        children: [
          Icon(kIsWeb ? Icons.web : Icons.ad_units),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
