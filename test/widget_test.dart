import 'package:flutter_test/flutter_test.dart';

import 'package:davao_coffee/main.dart' as app;

void main() {
  testWidgets('app shows login screen first', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();

    expect(find.text('Login Screen'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}
