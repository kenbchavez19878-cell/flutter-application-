import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TechStockApp());

    // Verify that the app renders with the expected title
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
