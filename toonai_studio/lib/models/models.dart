import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// A user-created or built-in cartoon character.
class ToonCharacter {
  final String id;
  String name;
  String characterType; // baby, child, man, woman, father, mother, ...
  String hairstyle;
  String outfit;
  String faceShape;
  String skinTone;
  String bodyType;
  List<String> accessories;
  String? sourcePhotoPath; // set when created via Photo-to-Cartoon (local upload)
  String? generatedPortraitUrl; // public URL of the character's portrait, used for animation
  String voiceId;

  ToonCharacter({
    String? id,
    required this.name,
    required this.characterType,
    this.hairstyle = 'Style 1',
    this.outfit = 'Casual',
    this.faceShape = 'Round',
    this.skinTone = 'Medium',
    this.bodyType = 'Average',
    List<String>? accessories,
    this.sourcePhotoPath,
    this.generatedPortraitUrl,
    this.voiceId = 'hi_female_1',
  })  : id = id ?? _uuid.v4(),
        accessories = accessories ?? [];
}

/// One scene within a story/project.
class ToonScene {
  final String id;
  String dialogue;
  String background; // home, school, office, park, village, city, shop
  String action; // walk, talk, laugh, cry, wave, sit, stand, ...
  List<String> characterIds;

  ToonScene({
    String? id,
    required this.dialogue,
    this.background = 'Home',
    this.action = 'Talk',
    List<String>? characterIds,
  })  : id = id ?? _uuid.v4(),
        characterIds = characterIds ?? [];
}

enum AspectRatio { vertical916, landscape169 }

enum ProjectStatus { draft, rendering, ready }

/// A full video project.
class ToonProject {
  final String id;
  String title;
  String storyText;
  List<ToonScene> scenes;
  List<ToonCharacter> characters;
  AspectRatio aspectRatio;
  String musicTrack;
  double musicVolume;
  double voiceVolume;
  double sfxVolume;
  ProjectStatus status;
  bool watermarkRemoved; // true once unlocked via rewarded ad for this video
  List<String> sceneClipUrls; // rendered per-scene clips, filled in during export
  String? finalVideoUrl;
  DateTime updatedAt;

  ToonProject({
    String? id,
    required this.title,
    this.storyText = '',
    List<ToonScene>? scenes,
    List<ToonCharacter>? characters,
    this.aspectRatio = AspectRatio.vertical916,
    this.musicTrack = 'Funny Bounce',
    this.musicVolume = 0.7,
    this.voiceVolume = 1.0,
    this.sfxVolume = 0.8,
    this.status = ProjectStatus.draft,
    this.watermarkRemoved = false,
    List<String>? sceneClipUrls,
    this.finalVideoUrl,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        scenes = scenes ?? [],
        characters = characters ?? [],
        sceneClipUrls = sceneClipUrls ?? [],
        updatedAt = updatedAt ?? DateTime.now();
}

class VoiceOption {
  final String id;
  final String label;
  final String language; // Hindi / English
  final String style; // Male / Female / Child

  const VoiceOption({
    required this.id,
    required this.label,
    required this.language,
    required this.style,
  });
}

class StoryTemplate {
  final String id;
  final String title;
  final String category;
  final String sampleStory;
  final String emoji;

  const StoryTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.sampleStory,
    required this.emoji,
  });
}
