import 'package:flutter_test/flutter_test.dart';
import 'package:vidleo/models/app_settings.dart';

void main() {
  test('default settings clip duration in requested range', () {
    expect(AppSettings.defaults.clipDurationSeconds, inInclusiveRange(30, 60));
  });
}
