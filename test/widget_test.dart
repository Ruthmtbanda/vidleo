import 'package:flutter_test/flutter_test.dart';
import 'package:vidleo/main.dart';
import 'package:vidleo/services/settings_controller.dart';

void main() {
  testWidgets('VIDLEO app renders MaterialApp', (tester) async {
    final settings = SettingsController();
    await tester.pumpWidget(VidleoApp(settings: settings));

    expect(find.text('VIDLEO'), findsOneWidget);
  });
}
