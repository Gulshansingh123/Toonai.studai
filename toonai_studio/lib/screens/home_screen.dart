import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/catalog.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'create_story_screen.dart';
import 'my_projects_screen.dart';
import 'premium_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _HomeTab(),
      const MyProjectsScreen(embedded: true),
      const PremiumScreen(embedded: true),
      const SettingsScreen(embedded: true),
    ];

    return Scaffold(
      body: SafeArea(child: tabs[_tab]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.video_library_rounded), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.workspace_premium_rounded), label: 'Premium'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.brand, borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Text('ToonAI Studio',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ],
            ),
            TextButton.icon(
              onPressed: () => context.read<AppState>().toggleLanguage(),
              icon: const Icon(Icons.translate_rounded, size: 18),
              label: Text(state.isHindi ? 'हिंदी' : 'English'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const BrandBanner(
          title: 'Apni Story, Apna Character, Apna Cartoon Video!',
          subtitle: 'Write a story, pick your characters, and export a cartoon video in minutes.',
        ),
        const SizedBox(height: 20),
        PrimaryCTA(
          label: '+ New Video',
          icon: Icons.add_circle_outline_rounded,
          onPressed: () {
            context.read<AppState>().createProject('Untitled Story');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _FreeCreditsCard(
                left: state.freeGenerationsLeft,
                isPremium: state.isPremium,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text('Ready Templates',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: Catalog.templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final t = Catalog.templates[i];
              return _TemplateCard(
                emoji: t.emoji,
                title: t.title,
                category: t.category,
                onTap: () {
                  final project = context.read<AppState>().createProject(t.title);
                  project.storyText = t.sampleStory;
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        if (state.projects.isNotEmpty) ...[
          const Text('Continue Editing',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          ...state.projects.take(3).map((p) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.light,
                    child: Icon(Icons.movie_outlined, color: AppColors.brand),
                  ),
                  title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${p.scenes.length} scenes  •  ${p.status.name}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    context.read<AppState>().setActiveProject(p);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                    );
                  },
                ),
              )),
        ],
        const SizedBox(height: 16),
        // Mock AdMob banner placement (free tier only).
        if (!state.isPremium) const _MockAdBanner(),
      ],
    );
  }
}

class _FreeCreditsCard extends StatelessWidget {
  final int left;
  final bool isPremium;
  const _FreeCreditsCard({required this.left, required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(isPremium ? Icons.workspace_premium_rounded : Icons.bolt_rounded,
                color: AppColors.brand2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isPremium
                    ? 'Premium active — unlimited generations'
                    : '$left free video generation${left == 1 ? '' : 's'} left this month',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String category;
  final VoidCallback onTap;
  const _TemplateCard({
    required this.emoji, required this.title, required this.category, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(category,
                style: const TextStyle(fontSize: 11, color: AppColors.brand, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(title,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _MockAdBanner extends StatelessWidget {
  const _MockAdBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Text('AdMob Banner Ad (free tier)',
          style: TextStyle(fontSize: 12, color: Colors.black45)),
    );
  }
}
