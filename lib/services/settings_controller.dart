import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidleo/models/app_settings.dart';

class SettingsController extends ChangeNotifier {
  static const _kAspectRatio = 'aspect_ratio';
  static const _kShortCount = 'short_count';
  static const _kClipDuration = 'clip_duration';

  AppSettings _settings = AppSettings.defaults;

  AppSettings get settings => _settings;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = AppSettings(
      aspectRatio: VideoAspectRatio.values[prefs.getInt(_kAspectRatio) ?? 0],
      shortsCount: prefs.getInt(_kShortCount) ?? AppSettings.defaults.shortsCount,
      clipDurationSeconds:
          prefs.getInt(_kClipDuration) ?? AppSettings.defaults.clipDurationSeconds,
    );
    notifyListeners();
  }

  Future<void> update(AppSettings updated) async {
    _settings = updated;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAspectRatio, updated.aspectRatio.index);
    await prefs.setInt(_kShortCount, updated.shortsCount);
    await prefs.setInt(_kClipDuration, updated.clipDurationSeconds);
  }
}
