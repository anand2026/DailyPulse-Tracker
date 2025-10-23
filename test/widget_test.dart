import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_pulse_tracker/main.dart';

void main() {
  testWidgets('DailyPulse app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DailyPulseApp(),
      ),
    );

    expect(find.text('DailyPulse'), findsOneWidget);
  });
}
