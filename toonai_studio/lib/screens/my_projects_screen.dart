import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'create_story_screen.dart';

class MyProjectsScreen extends StatelessWidget {
  final bool embedded;
  const MyProjectsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final projects = state.projects;

    final body = projects.isEmpty
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.video_library_outlined, size: 56, color: Colors.black26),
                  SizedBox(height: 12),
                  Text('No projects yet.\nStart a new video from Home.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.black45)),
                ],
              ),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: projects.length,
            itemBuilder: (context, i) {
              final p = projects[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.light,
                    child: Icon(
                      p.status == ProjectStatus.ready ? Icons.check_circle_rounded : Icons.edit_note_rounded,
                      color: AppColors.brand,
                    ),
                  ),
                  title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${p.scenes.length} scenes · ${_statusLabel(p.status)}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'open') {
                        state.setActiveProject(p);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                        );
                      } else if (value == 'delete') {
                        state.deleteProject(p.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'open', child: Text('Open / Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () {
                    state.setActiveProject(p);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                    );
                  },
                ),
              );
            },
          );

    if (embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: const [
                Text('My Projects', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('My Projects')), body: body);
  }

  String _statusLabel(ProjectStatus s) {
    switch (s) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.rendering:
        return 'Rendering';
      case ProjectStatus.ready:
        return 'Exported';
    }
  }
}
