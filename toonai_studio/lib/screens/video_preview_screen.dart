import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'export_screen.dart';

class VideoPreviewScreen extends StatefulWidget {
  const VideoPreviewScreen({super.key});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  int sceneIndex = 0;

  @override
  Widget build(BuildContext context) {
    final project = context.watch<AppState>().activeProject;
    if (project == null) {
      return const Scaffold(body: Center(child: Text('No project selected')));
    }
    final scenes = project.scenes;
    final isVertical = project.aspectRatio == AspectRatio.vertical916;

    return Scaffold(
      appBar: AppBar(title: const Text('Video Preview')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: isVertical ? 9 / 16 : 16 / 9,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 260),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.brand, AppColors.brand2],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: scenes.isEmpty
                      ? const Text('No scenes', style: TextStyle(color: Colors.white))
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 48),
                              const SizedBox(height: 10),
                              Text('Scene ${sceneIndex + 1}/${scenes.length}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              const SizedBox(height: 6),
                              Text(scenes[sceneIndex].dialogue,
                                  textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (scenes.isNotEmpty)
            Slider(
              value: sceneIndex.toDouble(),
              min: 0, max: (scenes.length - 1).toDouble(),
              divisions: scenes.length > 1 ? scenes.length - 1 : null,
              activeColor: AppColors.brand,
              label: 'Scene ${sceneIndex + 1}',
              onChanged: (v) => setState(() => sceneIndex = v.round()),
            ),
          const SectionLabel('Aspect Ratio'),
          Row(
            children: [
              Expanded(
                child: _AspectButton(
                  label: '9:16 Reels/Shorts', selected: isVertical,
                  onTap: () => setState(() => project.aspectRatio = AspectRatio.vertical916),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _AspectButton(
                  label: '16:9 Landscape', selected: !isVertical,
                  onTap: () => setState(() => project.aspectRatio = AspectRatio.landscape169),
                ),
              ),
            ],
          ),
          const SectionLabel('Music'),
          DropdownButtonFormField<String>(
            initialValue: project.musicTrack,
            items: Catalog.musicTracks
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (v) => setState(() => project.musicTrack = v ?? project.musicTrack),
          ),
          const SectionLabel('Volume Controls'),
          _VolumeSlider(
            label: 'Voice', value: project.voiceVolume,
            onChanged: (v) => setState(() => project.voiceVolume = v),
          ),
          _VolumeSlider(
            label: 'Music', value: project.musicVolume,
            onChanged: (v) => setState(() => project.musicVolume = v),
          ),
          _VolumeSlider(
            label: 'Sound Effects', value: project.sfxVolume,
            onChanged: (v) => setState(() => project.sfxVolume = v),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryCTA(
            label: 'Continue to Export',
            icon: Icons.ios_share_rounded,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExportScreen()),
            ),
          ),
        ),
      ),
    );
  }
}

class _AspectButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _AspectButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : AppColors.light,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w700, fontSize: 12.5)),
      ),
    );
  }
}

class _VolumeSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  const _VolumeSlider({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        Expanded(
          child: Slider(value: value, onChanged: onChanged, activeColor: AppColors.brand),
        ),
      ],
    );
  }
}
