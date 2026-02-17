import 'package:flutter/material.dart';
import 'package:vidleo/models/app_settings.dart';
import 'package:vidleo/screens/shorts_screen.dart';
import 'package:vidleo/services/app_scope.dart';
import 'package:vidleo/services/settings_controller.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key, required this.settings});

  static const route = '/processing';
  final SettingsController settings;

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final state = AppScope.processingState;
    final source = state.source;
    if (source == null) return;

    try {
      state.updateProgress(value: 0.05, message: 'Preparing input source...');
      final input = await AppScope.videoService.resolveInputPath(source);

      state.updateProgress(value: 0.35, message: 'Analyzing highlights...');
      final clips = await AppScope.videoService.analyzeHighlights(
        input,
        clipDurationSeconds: widget.settings.settings.clipDurationSeconds,
      );

      state.updateProgress(value: 0.65, message: 'Generating selected shorts...');
      final maxCount = widget.settings.settings.shortsCount.clamp(1, clips.length);
      final generated = <dynamic>[];
      for (var i = 0; i < maxCount; i++) {
        final clip = clips[i];
        final render = await AppScope.videoService.renderClip(
          inputPath: input,
          option: clip,
          ratio: VideoAspectRatio.ratio9x16,
        );
        generated.add(render);
        state.updateProgress(
          value: 0.65 + ((i + 1) / maxCount) * 0.35,
          message: 'Rendered ${i + 1}/$maxCount shorts',
        );
      }

      state
        ..setClips(clips)
        ..setGenerated(generated.cast())
        ..updateProgress(value: 1, message: 'Done');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, ShortsScreen.route);
    } catch (e) {
      state.updateProgress(value: 0, message: 'Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Processing')),
      body: Center(
        child: AnimatedBuilder(
          animation: AppScope.processingState,
          builder: (context, _) {
            final state = AppScope.processingState;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: state.progress),
                  const SizedBox(height: 12),
                  Text(state.progressMessage),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
