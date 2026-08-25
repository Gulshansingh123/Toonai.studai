import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'video_preview_screen.dart';

class VoiceSelectionScreen extends StatefulWidget {
  const VoiceSelectionScreen({super.key});

  @override
  State<VoiceSelectionScreen> createState() => _VoiceSelectionScreenState();
}

class _VoiceSelectionScreenState extends State<VoiceSelectionScreen> {
  String language = 'Hindi';

  @override
  Widget build(BuildContext context) {
    final project = context.watch<AppState>().activeProject;
    final characters = project?.characters ?? [];
    final voices = Catalog.voicesFor(language);

    return Scaffold(
      appBar: AppBar(title: const Text('Voice Selection')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const SectionLabel('Language'),
          OptionChips(
            options: const ['Hindi', 'English'],
            selected: language,
            onSelected: (v) => setState(() => language = v),
          ),
          const SizedBox(height: 8),
          if (characters.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No characters in this project yet.', style: TextStyle(color: Colors.black45)),
            )
          else
            ...characters.map((c) => _VoicePicker(character: c, voices: voices)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.record_voice_over_rounded, color: AppColors.brand, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lip-sync is generated automatically from the chosen voice and each scene\'s dialogue.',
                    style: TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryCTA(
            label: 'Continue to Preview',
            icon: Icons.play_circle_outline_rounded,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VideoPreviewScreen()),
            ),
          ),
        ),
      ),
    );
  }
}

class _VoicePicker extends StatefulWidget {
  final ToonCharacter character;
  final List<VoiceOption> voices;
  const _VoicePicker({required this.character, required this.voices});

  @override
  State<_VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends State<_VoicePicker> {
  @override
  Widget build(BuildContext context) {
    final c = widget.character;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CharacterAvatar(label: c.name, size: 40),
                const SizedBox(width: 10),
                Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: widget.voices.map((v) {
                final selected = c.voiceId == v.id;
                return ChoiceChip(
                  label: Text('${v.label} · ${v.style}'),
                  selected: selected,
                  onSelected: (_) => setState(() => c.voiceId = v.id),
                  avatar: Icon(
                    selected ? Icons.graphic_eq_rounded : Icons.play_circle_outline_rounded,
                    size: 16, color: selected ? Colors.white : AppColors.brand,
                  ),
                  selectedColor: AppColors.brand,
                  labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
