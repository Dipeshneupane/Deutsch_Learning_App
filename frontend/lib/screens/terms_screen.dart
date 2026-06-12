import 'package:flutter/material.dart';

import 'legal_document_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalDocumentScreen(
      title: 'Terms of Use',
      lastUpdated: 'June 12, 2026',
      intro:
          'These terms govern use of Deutsch Starter, a beginner-friendly German vocabulary flashcard and grammar quiz app for web and Android.',
      sections: const [
        LegalSection(
          heading: '1. Educational Purpose',
          body:
              'Deutsch Starter is provided for language-learning and self-study purposes. Content is designed to support beginner learners, but it should not be treated as certified academic, legal, immigration, or exam-preparation advice.',
        ),
        LegalSection(
          heading: '2. Local Progress Only',
          body:
              'Version 1 stores progress locally on the current device or browser. You are responsible for your own device, browser storage, backups, and any loss of local progress caused by uninstalling the app, clearing data, or changing devices.',
        ),
        LegalSection(
          heading: '3. Acceptable Use',
          body:
              'You agree not to misuse the app, interfere with the backend service, attempt unauthorized access, automate abusive traffic, reverse engineer protected integrations, or use the product in a way that harms normal app availability for others.',
        ),
        LegalSection(
          heading: '4. Content Availability',
          body:
              'Vocabulary, quiz topics, daily challenges, ads, analytics, and other app features may change, expand, or be removed over time. We do not guarantee that every feature will always remain available in the same form.',
        ),
        LegalSection(
          heading: '5. No Warranty',
          body:
              'The app is provided on an as-is and as-available basis. We do not guarantee uninterrupted service, perfect accuracy, or complete freedom from bugs, downtime, content mistakes, or compatibility issues.',
        ),
        LegalSection(
          heading: '6. Limitation of Liability',
          body:
              'To the maximum extent allowed by applicable law, the app owner is not liable for indirect, incidental, special, or consequential damages arising from use of the product, including loss of progress, device issues, network interruptions, or learning decisions based on app content.',
        ),
        LegalSection(
          heading: '7. Third-Party Services',
          body:
              'The app may rely on third-party tools and platforms such as hosting providers, analytics tools, crash reporting services, and future advertising services. Those services may be governed by their own terms and privacy policies.',
        ),
        LegalSection(
          heading: '8. Future Monetization',
          body:
              'If paid features, subscriptions, real ads, or in-app purchases are introduced in future releases, these terms may be updated to reflect those features before they go live.',
        ),
        LegalSection(
          heading: '9. Changes to the Terms',
          body:
              'These terms may be updated as the product grows. Continued use of the app after an updated version is published may count as acceptance of the revised terms, subject to applicable law.',
        ),
        LegalSection(
          heading: '10. Contact and Publisher Details',
          body:
              'Before launch, replace this section with your actual support email, publisher or company name, and any legally required business details for your target market.',
        ),
      ],
    );
  }
}
