import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/catalog.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'voice_selection_screen.dart';

class SceneEditorScreen extends StatefulWidget {
  const SceneEditorScreen({super.key});

  @override
  State<SceneEditorScreen> createState() => _SceneEditorScreenState();
}

class _SceneEditorScreenState extends State<SceneEditorScreen> {
  void _addScene() {
    final project = context.read<AppState>().activeProject;
    if (project == null) return;
    setState(() => project.scenes.add(ToonScene(dialogue: 'New scene dialogue...')));
  }

  void _removeScene(ToonScene s) {
    final project = context.read<AppState>().activeProject;
    if (project == null) return;
    setState(() => project.scenes.remove(s));
  }

  void _reorder(int oldIndex, int newIndex) {
    final project = context.read<AppState>().activeProject;
    if (project == null) return;
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final scene = project.scenes.removeAt(oldIndex);
      project.scenes.insert(newIndex, scene);
    });
  }

  @override
  Widget build(BuildContext context) {
    final project = context.watch<AppState>().activeProject;
    final scenes = project?.scenes ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scene Editor'),
        actions: [
          IconButton(onPressed: _addScene, icon: const Icon(Icons.add_box_outlined)),
        ],
      ),
      body: scenes.isEmpty
          ? const Center(child: Text('No scenes yet. Tap + to add one.', style: TextStyle(color: Colors.black45)))
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: scenes.length,
              onReorder: _reorder,
              itemBuilder: (context, i) => _SceneCard(
                key: ValueKey(scenes[i].id),
                index: i,
                scene: scenes[i],
                characters: project!.characters,
                onDelete: () => _removeScene(scenes[i]),
                onChanged: () => setState(() {}),
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: PrimaryCTA(
            label: 'Continue to Voice Selection',
            icon: Icons.record_voice_over_rounded,
            onPressed: scenes.isNotEmpty
                ? () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const VoiceSelectionScreen()),
                    )
                : () {},
          ),
        ),
      ),
    );
  }
}

class _SceneCard extends StatefulWidget {
  final int index;
  final ToonScene scene;
  final List<ToonCharacter> characters;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _SceneCard({
    super.key, required this.index, required this.scene, required this.characters,
    required this.onDelete, required this.onChanged,
  });

  @override
  State<_SceneCard> createState() => _SceneCardState();
}

class _SceneCardState extends State<_SceneCard> {
  late TextEditingController _dialogueCtrl;
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    _dialogueCtrl = TextEditingController(text: widget.scene.dialogue);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scene;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.drag_indicator_rounded, color: Colors.black26),
                const SizedBox(width: 6),
                CircleAvatar(
                  radius: 12, backgroundColor: AppColors.brand,
                  child: Text('${widget.index + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Scene ${widget.index + 1} · ${s.background} · ${s.action}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                ),
                IconButton(
                  icon: Icon(expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded),
                  onPressed: () => setState(() => expanded = !expanded),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            if (expanded) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _dialogueCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Scene dialogue...'),
                onChanged: (v) {
                  s.dialogue = v;
                  widget.onChanged();
                },
              ),
              const SectionLabel('Background'),
              OptionChips(
                options: Catalog.backgrounds, selected: s.background,
                onSelected: (v) => setState(() { s.background = v; widget.onChanged(); }),
              ),
              const SectionLabel('Action'),
              OptionChips(
                options: Catalog.actions, selected: s.action,
                onSelected: (v) => setState(() { s.action = v; widget.onChanged(); }),
              ),
              if (widget.characters.isNotEmpty) ...[
                const SectionLabel('Characters in this scene'),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: widget.characters.map((c) {
                    final inScene = s.characterIds.contains(c.id);
                    return FilterChip(
                      label: Text(c.name),
                      selected: inScene,
                      onSelected: (v) => setState(() {
                        v ? s.characterIds.add(c.id) : s.characterIds.remove(c.id);
                        widget.onChanged();
                      }),
                    );
                  }).toList(),
                ),
              ],
            ] else
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(s.dialogue, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black54, fontSize: 12.5)),
              ),
          ],
        ),
      ),
    );
  }
}
