class ClipOption {
  const ClipOption({
    required this.id,
    required this.startSeconds,
    required this.endSeconds,
    required this.score,
    required this.reason,
  });

  final String id;
  final double startSeconds;
  final double endSeconds;
  final double score;
  final String reason;

  double get duration => endSeconds - startSeconds;
}
