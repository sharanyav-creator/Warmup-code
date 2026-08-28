import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:warmup/main.dart';

void main() {
  testWidgets('App launches to onboarding on first run', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const WarmupApp());
    await tester.pumpAndSettle();

    expect(find.text('Practice Daily.\nA minute, a day.'), findsOneWidget);
  });
}
