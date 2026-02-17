enum VideoAspectRatio { ratio9x16, ratio16x9, ratio1x1 }

String aspectRatioLabel(VideoAspectRatio ratio) {
  switch (ratio) {
    case VideoAspectRatio.ratio9x16:
      return '9:16';
    case VideoAspectRatio.ratio16x9:
      return '16:9';
    case VideoAspectRatio.ratio1x1:
      return '1:1';
  }
}

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
    required this.aspectRatio,
    required this.shortsCount,
    required this.clipDurationSeconds,
  });

  final VideoAspectRatio aspectRatio;
  final int shortsCount;
  final int clipDurationSeconds;

  AppSettings copyWith({
    VideoAspectRatio? aspectRatio,
    int? shortsCount,
    int? clipDurationSeconds,
  }) {
    return AppSettings(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      shortsCount: shortsCount ?? this.shortsCount,
      clipDurationSeconds: clipDurationSeconds ?? this.clipDurationSeconds,
    );
  }

  static const defaults = AppSettings(
    aspectRatio: VideoAspectRatio.ratio9x16,
    shortsCount: 5,
    clipDurationSeconds: 45,
  );
}
