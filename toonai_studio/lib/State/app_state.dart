import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/ai_service.dart';

enum AppLanguage { hindi, english }

/// Central app state. In production this would be backed by local storage
/// (Hive/SQLite) for offline drafts and synced to the backend when signed in.
class AppState extends ChangeNotifier {
  AppState({AiService? aiService}) : ai = aiService ?? AiService();

  final AiService ai;

  AppLanguage language = AppLanguage.english;

  // --- Monetization state (mocked; real checks happen server-side) ---
  bool isPremium = false;
  int freeGenerationsLeft = 3;
  static const int freeGenerationsMonthlyCap = 3;

  // --- Data ---
  final List<ToonCharacter> characterLibrary = [];
  final List<ToonProject> projects = [];

  ToonProject? activeProject;

  bool get isHindi => language == AppLanguage.hindi;

  void toggleLanguage() {
    language = language == AppLanguage.hindi ? AppLanguage.english : AppLanguage.hindi;
    notifyListeners();
  }

  void addCharacter(ToonCharacter c) {
    characterLibrary.add(c);
    notifyListeners();
  }

  ToonProject createProject(String title) {
    final project = ToonProject(title: title.isEmpty ? 'Untitled Story' : title);
    projects.insert(0, project);
    activeProject = project;
    notifyListeners();
    return project;
  }

  void setActiveProject(ToonProject project) {
    activeProject = project;
    notifyListeners();
  }

  void touchActiveProject() {
    activeProject?.updatedAt = DateTime.now();
    notifyListeners();
  }

  void deleteProject(String id) {
    projects.removeWhere((p) => p.id == id);
    if (activeProject?.id == id) activeProject = null;
    notifyListeners();
  }

  /// Consumes one generation credit. Returns false if the free user is
  /// out of credits (caller should route to rewarded-ad unlock or Premium).
  bool consumeGeneration() {
    if (isPremium) return true;
    if (freeGenerationsLeft <= 0) return false;
    freeGenerationsLeft -= 1;
    notifyListeners();
    return true;
  }

  /// Mock rewarded-ad unlock (real implementation calls Google AdMob's
  /// rewarded ad SDK and grants credit only on verified ad completion).
  void grantRewardedGeneration() {
    freeGenerationsLeft += 1;
    notifyListeners();
  }

  void unlockPremium() {
    isPremium = true;
    notifyListeners();
  }

  /// Calls the real backend (Claude-powered) to split a story into scenes.
  /// Falls back to a simple local sentence-split if the backend is
  /// unreachable, so the UI still works in demo/offline mode.
  Future<List<ToonScene>> splitStoryIntoScenes(String story, {String language = "English"}) async {
    final cleaned = story.trim();
    if (cleaned.isEmpty) return [];
    try {
      return await ai.splitStory(cleaned, language: language);
    } catch (_) {
      final parts = cleaned
          .split(RegExp(r'(?<=[.!?।])\s+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final backgrounds = ['Home', 'School', 'Park', 'Office', 'City', 'Shop'];
      final actions = ['Talk', 'Walk', 'Laugh', 'Wave', 'Sit', 'Point'];
      return List.generate(parts.length, (i) {
        return ToonScene(
          dialogue: parts[i],
          background: backgrounds[i % backgrounds.length],
          action: actions[i % actions.length],
        );
      });
    }
  }

  /// Generates the full talking-character video for one scene: synthesizes
  /// the dialogue in the character's chosen voice, then animates that
  /// character's portrait to speak it, lip-synced. Returns a clip URL.
  Future<String> renderSceneClip(ToonScene scene, ToonCharacter character) async {
    final audioUrl = await ai.synthesizeVoice(scene.dialogue, character.voiceId);
    final portraitUrl = character.sourcePhotoPath ?? character.generatedPortraitUrl;
    if (portraitUrl == null) {
      throw Exception('Character "${character.name}" has no portrait to animate yet.');
    }
    return ai.animateCharacter(imageUrl: portraitUrl, audioUrl: audioUrl);
  }

  /// Stitches every scene's rendered clip into the final export.
  Future<String> composeFinalVideo({
    required List<String> sceneClipUrls,
    required ToonProject project,
  }) {
    return ai.composeVideo(
      clipUrls: sceneClipUrls,
      musicTrack: project.musicTrack,
      musicVolume: project.musicVolume,
      aspectRatio: project.aspectRatio == AspectRatio.vertical916 ? "9:16" : "16:9",
      watermark: !isPremium && !project.watermarkRemoved,
    );
  }
}
