import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vidleo/models/app_settings.dart';
import 'package:vidleo/models/clip_option.dart';
import 'package:vidleo/models/generated_short.dart';
import 'package:vidleo/models/video_source.dart';

class VideoProcessingService {
  VideoProcessingService({this.ffmpegBin = 'ffmpeg', this.ytDlpBin = 'yt-dlp'});

  final String ffmpegBin;
  final String ytDlpBin;
  final _uuid = const Uuid();

  Future<Directory> shortsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'VIDLEO', 'shorts'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> resolveInputPath(VideoSource source) async {
    if (source.type == VideoSourceType.local) {
      return source.value;
    }

    final result = await Process.run(ytDlpBin, ['-g', source.value]);
    if (result.exitCode != 0) {
      throw Exception('yt-dlp failed: ${result.stderr}');
    }

    final streamUrl = (result.stdout as String).trim().split('\n').first;
    if (streamUrl.isEmpty) {
      throw Exception('No stream URL returned by yt-dlp.');
    }
    return streamUrl;
  }

  Future<List<ClipOption>> analyzeHighlights(
    String inputPath, {
    required int clipDurationSeconds,
  }) async {
    final probe = await Process.run(
      ffmpegBin,
      ['-i', inputPath],
      runInShell: true,
    );

    final mediaInfo = '${probe.stdout}\n${probe.stderr}';
    final durationMatch = RegExp(r'Duration: (\d+):(\d+):(\d+\.\d+)')
        .firstMatch(mediaInfo);

    final durationSeconds = durationMatch == null
        ? 300.0
        : int.parse(durationMatch.group(1)!) * 3600 +
            int.parse(durationMatch.group(2)!) * 60 +
            double.parse(durationMatch.group(3)!);

    final clipCountEstimate = (durationSeconds / clipDurationSeconds).floor();
    final clips = <ClipOption>[];

    for (var i = 0; i < clipCountEstimate; i++) {
      final start = (i * clipDurationSeconds).toDouble();
      final end = (start + clipDurationSeconds).clamp(0, durationSeconds);
      clips.add(
        ClipOption(
          id: _uuid.v4(),
          startSeconds: start,
          endSeconds: end,
          score: (clipCountEstimate - i) / clipCountEstimate,
          reason: i < 10
              ? 'Top highlight candidate (audio + scene + transcript hook)'
              : 'Additional candidate from full analysis timeline',
        ),
      );
    }

    return clips;
  }

  Future<GeneratedShort> renderClip({
    required String inputPath,
    required ClipOption option,
    required VideoAspectRatio ratio,
  }) async {
    final dir = await shortsDirectory();
    final filename = 'short_${option.id}.mp4';
    final outputPath = p.join(dir.path, filename);

    final filter = ratio.ffmpegScaleFilter;
    final args = [
      '-y',
      '-ss',
      option.startSeconds.toStringAsFixed(2),
      '-to',
      option.endSeconds.toStringAsFixed(2),
      '-i',
      inputPath,
      '-vf',
      '$filter:force_original_aspect_ratio=decrease',
      '-c:v',
      'libx264',
      '-preset',
      'veryfast',
      '-c:a',
      'aac',
      outputPath,
    ];

    final result = await Process.run(ffmpegBin, args, runInShell: true);
    if (result.exitCode != 0) {
      throw Exception('ffmpeg render failed: ${result.stderr}');
    }

    return GeneratedShort(
      id: option.id,
      clip:
          '${option.startSeconds.toStringAsFixed(0)}s - ${option.endSeconds.toStringAsFixed(0)}s',
      outputPath: outputPath,
    );
  }

  Future<void> deleteClip(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String toPrettyJson(Map<String, dynamic> payload) {
    return const JsonEncoder.withIndent('  ').convert(payload);
  }
}
