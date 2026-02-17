import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vidleo/screens/home_screen.dart';
import 'package:vidleo/services/app_scope.dart';
import 'package:vidleo/services/settings_controller.dart';
import 'package:vidleo/widgets/short_card.dart';

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key, required this.settings});

  static const route = '/shorts';
  final SettingsController settings;

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  Future<void> _exportFile(String sourcePath) async {
    final downloads = await getApplicationDocumentsDirectory();
    final target = p.join(downloads.path, p.basename(sourcePath));
    await File(sourcePath).copy(target);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exported to: $target')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generated Shorts'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context, HomeScreen.route, (route) => false),
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: AppScope.processingState,
        builder: (context, _) {
          final generated = AppScope.processingState.generated;
          final clipCount = AppScope.processingState.clips.length;

          if (generated.isEmpty) {
            return const Center(child: Text('No shorts generated yet.'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('Top 10 highlights first · $clipCount candidates found'),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: generated.length,
                  itemBuilder: (context, index) {
                    final item = generated[index];
                    return ShortCard(
                      short: item,
                      onExport: () => _exportFile(item.outputPath),
                      onRegenerate: () {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      onDelete: () async {
                        await AppScope.videoService.deleteClip(item.outputPath);
                        final next = [...generated]..removeAt(index);
                        AppScope.processingState.setGenerated(next);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
