enum VideoAspectRatio { ratio9x16, ratio16x9, ratio1x1 }

String aspectRatioScaleFilter(VideoAspectRatio ratio) {
  switch (ratio) {
    case VideoAspectRatio.ratio9x16:
      return 'scale=1080:1920';
    case VideoAspectRatio.ratio16x9:
      return 'scale=1920:1080';
    case VideoAspectRatio.ratio1x1:
      return 'scale=1080:1080';
  }
}

class AppSettings {
  const AppSettings({
    required this.shortsCount,
    required this.clipDurationSeconds,
  });

  final int shortsCount;
  final int clipDurationSeconds;

  AppSettings copyWith({
    int? shortsCount,
    int? clipDurationSeconds,
  }) {
    return AppSettings(
      shortsCount: shortsCount ?? this.shortsCount,
      clipDurationSeconds: clipDurationSeconds ?? this.clipDurationSeconds,
    );
  }

  static const defaults = AppSettings(
    shortsCount: 5,
    clipDurationSeconds: 45,
  );
}
