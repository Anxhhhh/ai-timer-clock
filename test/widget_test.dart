import 'package:ai_timer_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test — renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const AiTimerApp());
    // Verify the bottom navigation is present
    expect(find.text('Focus'), findsOneWidget);
  });
}
