import 'package:flutter_test/flutter_test.dart';

import 'package:warmup/main.dart';

void main() {
  testWidgets('App launches to the Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const WarmupApp());
    await tester.pump();

    expect(find.text('Warmup'), findsOneWidget);
    expect(find.text('Start practice'), findsOneWidget);
  });
}
