enum VideoSourceType { youtube, local }

class VideoSource {
  const VideoSource({
    required this.type,
    required this.value,
  });

  final VideoSourceType type;
  final String value;
}
