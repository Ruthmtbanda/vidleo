import 'package:vidleo/services/processing_state.dart';
import 'package:vidleo/services/video_processing_service.dart';

class AppScope {
  static final processingState = ProcessingState();
  static final videoService = VideoProcessingService();
}
