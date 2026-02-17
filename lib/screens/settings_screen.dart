import 'package:flutter/material.dart';
import 'package:vidleo/models/app_settings.dart';
import 'package:vidleo/services/settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.settings});

  static const route = '/settings';
  final SettingsController settings;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late VideoAspectRatio _ratio;
  late double _count;
  late double _duration;

  @override
  void initState() {
    super.initState();
    final current = widget.settings.settings;
    _ratio = current.aspectRatio;
    _count = current.shortsCount.toDouble();
    _duration = current.clipDurationSeconds.toDouble();
  }

  Future<void> _save() async {
    final next = AppSettings(
      aspectRatio: _ratio,
      shortsCount: _count.toInt(),
      clipDurationSeconds: _duration.toInt().clamp(30, 60),
    );
    await widget.settings.update(next);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Aspect Ratio', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<VideoAspectRatio>(
            segments: VideoAspectRatio.values
                .map((r) => ButtonSegment(value: r, label: Text(r.label)))
                .toList(),
            selected: {_ratio},
            onSelectionChanged: (value) => setState(() => _ratio = value.first),
          ),
          const SizedBox(height: 24),
          Text('Number of shorts: ${_count.toInt()}'),
          Slider(
            min: 1,
            max: 20,
            divisions: 19,
            value: _count,
            onChanged: (value) => setState(() => _count = value),
          ),
          const SizedBox(height: 16),
          Text('Clip duration: ${_duration.toInt()} sec (30–60)'),
          Slider(
            min: 30,
            max: 60,
            divisions: 30,
            value: _duration,
            onChanged: (value) => setState(() => _duration = value),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: _save, child: const Text('Save settings')),
        ],
      ),
    );
  }
}
