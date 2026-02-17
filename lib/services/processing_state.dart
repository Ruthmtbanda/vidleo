import 'package:flutter/foundation.dart';
import 'package:vidleo/models/clip_option.dart';
import 'package:vidleo/models/generated_short.dart';
import 'package:vidleo/models/video_source.dart';

class ProcessingState extends ChangeNotifier {
  VideoSource? source;
  bool processing = false;
  double progress = 0;
  String progressMessage = 'Idle';
  List<ClipOption> clips = const [];
  List<GeneratedShort> generated = const [];

  void reset() {
    processing = false;
    progress = 0;
    progressMessage = 'Idle';
    clips = const [];
    generated = const [];
    notifyListeners();
  }

  void setSource(VideoSource next) {
    source = next;
    notifyListeners();
  }

  void updateProgress({required double value, required String message}) {
    progress = value;
    progressMessage = message;
    notifyListeners();
  }

  void setClips(List<ClipOption> values) {
    clips = values;
    notifyListeners();
  }

  void setGenerated(List<GeneratedShort> values) {
    generated = values;
    notifyListeners();
  }
}
