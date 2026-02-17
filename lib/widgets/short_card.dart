import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:vidleo/models/generated_short.dart';

class ShortCard extends StatefulWidget {
  const ShortCard({
    super.key,
    required this.short,
    required this.onExport,
    required this.onDelete,
    required this.onRegenerate,
  });

  final GeneratedShort short;
  final VoidCallback onExport;
  final VoidCallback onDelete;
  final VoidCallback onRegenerate;

  @override
  State<ShortCard> createState() => _ShortCardState();
}

class _ShortCardState extends State<ShortCard> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _setupVideo();
  }

  Future<void> _setupVideo() async {
    final file = File(widget.short.outputPath);
    if (!await file.exists()) return;
    _controller = VideoPlayerController.file(file);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _controller?.value.isInitialized == true
                  ? AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    )
                  : const Center(child: Text('Preview unavailable')),
            ),
            const SizedBox(height: 8),
            Text(widget.short.clip, style: Theme.of(context).textTheme.labelLarge),
            Text(
              widget.short.outputPath,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Wrap(
              spacing: 8,
              children: [
                FilledButton(onPressed: widget.onExport, child: const Text('Export')),
                OutlinedButton(onPressed: widget.onRegenerate, child: const Text('Re-generate')),
                IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete_outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
