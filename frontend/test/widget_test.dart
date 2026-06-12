import 'package:flutter_test/flutter_test.dart';

import 'package:german_learning_app/main.dart';

void main() {
  testWidgets('app renders splash screen while state initializes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GermanLearningApp());

    expect(find.text('Deutsch Starter'), findsOneWidget);
  });
}
