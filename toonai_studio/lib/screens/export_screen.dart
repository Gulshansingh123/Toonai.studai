import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'home_screen.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String resolution = '720p';
  bool exporting = false;
  bool exported = false;
  String? error;
  String progressLabel = '';
  bool watermarkOff = false;

  Future<void> _export() async {
    final state = context.read<AppState>();
    final project = state.activeProject;
    if (project == null) return;

    setState(() { exporting = true; error = null; });
    try {
      // 1) Render each scene: voice synth (ElevenLabs) + character
      //    animation/lip-sync (D-ID). Runs scene-by-scene so progress can
      //    be shown; in production, fan these out in parallel with a
      //    concurrency cap instead of strictly sequential.
      final clipUrls = <String>[];
      for (var i = 0; i < project.scenes.length; i++) {
        final scene = project.scenes[i];
        setState(() => progressLabel = 'Rendering scene ${i + 1} of ${project.scenes.length}...');
        final character = project.characters.firstWhere(
          (c) => scene.characterIds.contains(c.id),
          orElse: () => project.characters.isNotEmpty
              ? project.characters.first
              : throw Exception('Add at least one character to this project first.'),
        );
        final clipUrl = await state.renderSceneClip(scene, character);
        clipUrls.add(clipUrl);
      }
      project.sceneClipUrls = clipUrls;

      // 2) Stitch every scene clip into the final video (ffmpeg on the
      //    backend), mixing in music and burning in a watermark for
      //    free-tier users unless it's been unlocked for this export.
      setState(() => progressLabel = 'Composing final video, adding music...');
      project.watermarkRemoved = watermarkOff || state.isPremium;
      final finalUrl = await state.composeFinalVideo(sceneClipUrls: clipUrls, project: project);
      project.finalVideoUrl = finalUrl;
      project.status = ProjectStatus.ready;
      state.touchActiveProject();

      if (!mounted) return;
      setState(() { exporting = false; exported = true; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        exporting = false;
        error = 'Export failed: $e';
      });
    }
  }

  Future<void> _watchAdToRemoveWatermark() async {
    // TODO(ads): replace with a real google_mobile_ads rewarded ad; only
    // set watermarkOff = true in the onUserEarnedReward callback.
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => watermarkOff = true);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final project = state.activeProject;
    final isPremium = state.isPremium;

    return Scaffold(
      appBar: AppBar(title: const Text('Export & Share')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project?.title ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${project?.scenes.length ?? 0} scenes · '
                      '${project?.aspectRatio == AspectRatio.vertical916 ? '9:16' : '16:9'}',
                      style: const TextStyle(color: Colors.black45, fontSize: 12.5)),
                ],
              ),
            ),
          ),
          const SectionLabel('Export Resolution'),
          Row(
            children: [
              Expanded(
                child: _ResChip(label: '720p (Free)', selected: resolution == '720p',
                    onTap: () => setState(() => resolution = '720p')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ResChip(
                  label: '1080p ${isPremium ? '' : '🔒'}',
                  selected: resolution == '1080p',
                  onTap: isPremium ? () => setState(() => resolution = '1080p') : null,
                ),
              ),
            ],
          ),
          const SectionLabel('Watermark'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: watermarkOff || isPremium
                  ? const Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.success),
                        SizedBox(width: 10),
                        Expanded(child: Text('No watermark on this video', style: TextStyle(fontWeight: FontWeight.w700))),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Free exports include a small "ToonAI Studio" logo in the corner.',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _watchAdToRemoveWatermark,
                          icon: const Icon(Icons.play_circle_outline_rounded, size: 16),
                          label: const Text('Watch Ad to Remove'),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (!exported)
            PrimaryCTA(
              label: exporting ? 'Rendering video...' : 'Export Video',
              icon: Icons.videocam_rounded,
              onPressed: !exporting ? _export : () {},
            ),
          if (exporting) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(color: AppColors.brand),
            const SizedBox(height: 8),
            Text(progressLabel.isEmpty ? 'Starting render...' : progressLabel,
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
          ],
          if (error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),
          ],
          if (exported) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success),
                  SizedBox(width: 10),
                  Expanded(child: Text('Video exported! Save it to your gallery or share it directly.')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryCTA(label: 'Save to Gallery', icon: Icons.download_rounded, onPressed: () {}),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _ShareButton(icon: Icons.camera_alt_rounded, label: 'Reels')),
                const SizedBox(width: 10),
                Expanded(child: _ShareButton(icon: Icons.smart_display_rounded, label: 'Shorts')),
                const SizedBox(width: 10),
                Expanded(child: _ShareButton(icon: Icons.chat_rounded, label: 'WhatsApp')),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false,
              ),
              child: const SizedBox(width: double.infinity, child: Text('Back to Home', textAlign: TextAlign.center)),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _ResChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: disabled ? Colors.black12.withOpacity(0.05) : (selected ? AppColors.brand : AppColors.light),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(label,
            style: TextStyle(
              color: disabled ? Colors.black38 : (selected ? Colors.white : Colors.black87),
              fontWeight: FontWeight.w700, fontSize: 12.5,
            )),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ShareButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
      child: Column(
        children: [
          Icon(icon, size: 18, color: AppColors.brand),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
