class GeneratedShort {
  const GeneratedShort({
    required this.id,
    required this.clip,
    required this.outputPath,
    this.exported = false,
  });

  final String id;
  final String clip;
  final String outputPath;
  final bool exported;

  GeneratedShort copyWith({bool? exported}) {
    return GeneratedShort(
      id: id,
      clip: clip,
      outputPath: outputPath,
      exported: exported ?? this.exported,
    );
  }
}
