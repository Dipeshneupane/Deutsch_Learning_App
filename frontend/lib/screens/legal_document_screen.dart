import 'package:flutter/material.dart';

import '../widgets/app_shell.dart';

class LegalSection {
  const LegalSection({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.lastUpdated,
    required this.intro,
    required this.sections,
  });

  final String title;
  final String lastUpdated;
  final String intro;
  final List<LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: title,
      child: SelectionArea(
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Last updated: $lastUpdated',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(intro),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final section in sections) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.heading,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(section.body),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
