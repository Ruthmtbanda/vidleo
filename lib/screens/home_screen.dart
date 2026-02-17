import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vidleo/models/video_source.dart';
import 'package:vidleo/screens/processing_screen.dart';
import 'package:vidleo/screens/settings_screen.dart';
import 'package:vidleo/services/app_scope.dart';
import 'package:vidleo/services/settings_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.settings});

  static const route = '/';

  final SettingsController settings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _youtubeController = TextEditingController();

  @override
  void dispose() {
    _youtubeController.dispose();
    super.dispose();
  }

  void _startYoutube() {
    final url = _youtubeController.text.trim();
    if (url.isEmpty) return;
    AppScope.processingState
      ..reset()
      ..setSource(VideoSource(type: VideoSourceType.youtube, value: url));
    Navigator.pushNamed(context, ProcessingScreen.route);
  }

  Future<void> _pickLocalVideo() async {
    await Permission.storage.request();
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'avi'],
    );
    final path = picked?.files.single.path;
    if (path == null) return;

    AppScope.processingState
      ..reset()
      ..setSource(VideoSource(type: VideoSourceType.local, value: path));

    if (!mounted) return;
    Navigator.pushNamed(context, ProcessingScreen.route);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VIDLEO'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.route),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create shorts from long videos',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            TextField(
              controller: _youtubeController,
              decoration: const InputDecoration(
                labelText: 'Paste YouTube URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _startYoutube,
              icon: const Icon(Icons.link),
              label: const Text('Analyze YouTube video'),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _pickLocalVideo,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload local video (MP4/MOV/AVI)'),
            ),
            const SizedBox(height: 24),
            ListenableBuilder(
              listenable: widget.settings,
              builder: (context, _) {
                final current = widget.settings.settings;
                return Text(
                  'Shorts format: 9:16 (fixed), '
                  '${current.shortsCount} shorts, '
                  '${current.clipDurationSeconds}s each',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
