import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/shared_widgets.dart';
import 'character_selection_screen.dart';

class CreateStoryScreen extends StatefulWidget {
  const CreateStoryScreen({super.key});

  @override
  State<CreateStoryScreen> createState() => _CreateStoryScreenState();
}

class _CreateStoryScreenState extends State<CreateStoryScreen> {
  late TextEditingController _ctrl;
  bool splitting = false;

  @override
  void initState() {
    super.initState();
    final project = context.read<AppState>().activeProject;
    _ctrl = TextEditingController(text: project?.storyText ?? '');
  }

  Future<void> _splitIntoScenes() async {
    final state = context.read<AppState>();
    final project = state.activeProject;
    if (project == null) return;
    if (!state.consumeGeneration()) {
      _showOutOfCreditsSheet();
      return;
    }
    setState(() => splitting = true);
    project.storyText = _ctrl.text;
    final lang = state.isHindi ? "Hindi" : "English";
    try {
      project.scenes = await state.splitStoryIntoScenes(_ctrl.text, language: lang);
      state.touchActiveProject();
      if (!mounted) return;
      setState(() => splitting = false);
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CharacterSelectionScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => splitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not split story right now: $e')),
      );
    }
  }

  void _showOutOfCreditsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Out of free generations',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 8),
            const Text('Watch a rewarded ad to unlock one more generation, or go Premium for unlimited.'),
            const SizedBox(height: 16),
            PrimaryCTA(
              label: 'Watch Ad for +1 Generation',
              icon: Icons.smart_display_rounded,
              onPressed: () {
                context.read<AppState>().grantRewardedGeneration();
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const SizedBox(width: double.infinity, child: Text('Maybe Later', textAlign: TextAlign.center)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Story')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SectionLabel('Write your story or dialogue (Hindi or English)'),
          TextField(
            controller: _ctrl,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Papa aaya thak kar ghar... / Papa comes home tired...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tip: write it like you would tell a friend — our AI will split it into scenes automatically.',
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 24),
          PrimaryCTA(
            label: splitting ? 'Splitting into scenes...' : 'AI: Split into Scenes',
            icon: Icons.auto_fix_high_rounded,
            onPressed: (!splitting && _ctrl.text.trim().isNotEmpty) ? _splitIntoScenes : () {},
          ),
        ],
      ),
    );
  }
}
