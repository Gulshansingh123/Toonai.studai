import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'character_creator_screen.dart';
import 'photo_to_cartoon_screen.dart';
import 'scene_editor_screen.dart';

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  final Set<String> selectedIds = {};

  @override
  void initState() {
    super.initState();
    final project = context.read<AppState>().activeProject;
    if (project != null) {
      selectedIds.addAll(project.characters.map((c) => c.id));
    }
  }

  void _continue() {
    final state = context.read<AppState>();
    final project = state.activeProject;
    if (project == null) return;
    project.characters = state.characterLibrary.where((c) => selectedIds.contains(c.id)).toList();
    state.touchActiveProject();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SceneEditorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final library = state.characterLibrary;

    return Scaffold(
      appBar: AppBar(title: const Text('Character Selection')),
      body: Column(
        children: [
          Expanded(
            child: library.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.groups_2_rounded, size: 56, color: Colors.black26),
                          const SizedBox(height: 12),
                          const Text('No characters yet.\nCreate one to add to your story.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black45)),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: library.length,
                    itemBuilder: (context, i) {
                      final c = library[i];
                      final selected = selectedIds.contains(c.id);
                      return GestureDetector(
                        onTap: () => setState(() =>
                            selected ? selectedIds.remove(c.id) : selectedIds.add(c.id)),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected ? AppColors.brand.withOpacity(0.08) : AppColors.light,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: selected ? AppColors.brand : Colors.transparent, width: 2),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              CharacterAvatar(label: c.name, size: 64),
                              const SizedBox(height: 8),
                              Text(c.name,
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text(c.characterType,
                                  style: const TextStyle(fontSize: 11, color: Colors.black45)),
                              const Spacer(),
                              if (selected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.brand, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text('New Character'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CharacterCreatorScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: const Text('From Photo'),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PhotoToCartoonScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: PrimaryCTA(
            label: 'Continue to Scene Editor (${selectedIds.length} selected)',
            icon: Icons.arrow_forward_rounded,
            onPressed: selectedIds.isNotEmpty ? _continue : () {},
          ),
        ),
      ),
    );
  }
}
