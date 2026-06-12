import 'package:flutter/material.dart';

import 'legal_document_screen.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'Privacy Policy',
      lastUpdated: 'June 12, 2026',
      intro:
          'Deutsch Starter is designed to work without account creation or cloud sync. Most learning progress stays on the current device or browser only.',
      sections: const [
        LegalSection(
          heading: '1. Information We Store Locally',
          body:
              'The app stores learning data on your device using local storage through shared_preferences. This can include learned vocabulary IDs, favorite vocabulary IDs, quiz scores, streak data, XP points, review schedules, wrong-answer review data, daily challenge completion, and dark mode preference.',
        ),
        LegalSection(
          heading: '2. No Account Required',
          body:
              'Version 1 of Deutsch Starter does not require login, registration, or cloud sync. We do not create a personal user account for you inside the app.',
        ),
        LegalSection(
          heading: '3. Analytics and Crash Reporting',
          body:
              'The app is prepared for Firebase Analytics and Crashlytics, but telemetry is only active when the app owner configures Firebase in a release environment. If enabled later, anonymized usage events and technical crash information may be collected to improve app quality and understand feature usage.',
        ),
        LegalSection(
          heading: '4. Advertising',
          body:
              'The current build uses placeholder or test ad integrations only. If real advertising is enabled later, third-party ad providers such as AdMob or AdSense may collect device or browser information according to their own privacy practices.',
        ),
        LegalSection(
          heading: '5. Backend Content Requests',
          body:
              'The app connects to a backend API to fetch German vocabulary, grammar topics, and quiz questions. These requests may create normal server logs such as IP address, request path, response status, and request time for technical operation, security, and troubleshooting.',
        ),
        LegalSection(
          heading: '6. Data Sharing',
          body:
              'We do not sell local learning progress data. Because Version 1 stores progress locally by design, your personal study data is not shared with other users through the app.',
        ),
        LegalSection(
          heading: '7. Your Choices',
          body:
              'You can reset local progress at any time from Settings. On web, clearing browser storage may also remove your saved study progress. On mobile, uninstalling the app may remove locally stored learning data.',
        ),
        LegalSection(
          heading: '8. Children and Educational Use',
          body:
              'Deutsch Starter is intended as a beginner-friendly educational product. Anyone using the app should review this policy with a parent, teacher, or guardian if needed before a public release.',
        ),
        LegalSection(
          heading: '9. Changes to This Policy',
          body:
              'This privacy policy may be updated as analytics, advertising, accounts, or other features change in future versions. The last updated date above should be changed whenever the policy is revised.',
        ),
        LegalSection(
          heading: '10. Contact',
          body:
              'Before launch, replace this section with your real business or support contact email and, if needed, your legal entity or publisher name.',
        ),
      ],
    );
  }
}
