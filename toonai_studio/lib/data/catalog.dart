import '../models/models.dart';

/// Static "content pack" data. In production this is fetched from the
/// Content/CMS Service (see PRD section 5.4) so new characters, voices,
/// templates, backgrounds and music can be added without an app update.
class Catalog {
  static const List<String> characterTypes = [
    'Baby', 'Child', 'Man', 'Woman', 'Father', 'Mother',
    'Grandfather', 'Grandmother', 'Teacher', 'Student',
    'Businessman', 'Doctor', 'Police Officer', 'Superhero',
    'Animal', 'Other Fictional',
  ];

  static const List<String> hairstyles = [
    'Short', 'Long', 'Curly', 'Bald', 'Ponytail', 'Braided', 'Spiky',
  ];

  static const List<String> outfits = [
    'Casual', 'Formal', 'Traditional', 'Uniform', 'Sporty', 'Festive',
  ];

  static const List<String> faceShapes = [
    'Round', 'Oval', 'Square', 'Heart',
  ];

  static const List<String> skinTones = [
    'Fair', 'Wheatish', 'Medium', 'Deep', 'Dark',
  ];

  static const List<String> bodyTypes = [
    'Slim', 'Average', 'Sturdy', 'Tall', 'Short',
  ];

  static const List<String> accessories = [
    'Glasses', 'Cap', 'Jewellery', 'Watch', 'Bag', 'Turban', 'Scarf',
  ];

  static const List<String> backgrounds = [
    'Home', 'School', 'Office', 'Park', 'Village', 'City', 'Shop',
  ];

  static const List<String> actions = [
    'Walk', 'Talk', 'Laugh', 'Cry', 'Wave', 'Sit', 'Stand', 'Run', 'Hug', 'Jump', 'Point', 'Idle',
  ];

  static const List<String> musicTracks = [
    'Funny Bounce', 'Family Warmth', 'Festive Dhol', 'Motivational Rise', 'Chill Acoustic',
  ];

  static const List<VoiceOption> voices = [
    VoiceOption(id: 'hi_female_1', label: 'Kavya', language: 'Hindi', style: 'Female'),
    VoiceOption(id: 'hi_male_1', label: 'Arjun', language: 'Hindi', style: 'Male'),
    VoiceOption(id: 'hi_child_1', label: 'Chintu', language: 'Hindi', style: 'Child'),
    VoiceOption(id: 'en_female_1', label: 'Emma', language: 'English', style: 'Female'),
    VoiceOption(id: 'en_male_1', label: 'James', language: 'English', style: 'Male'),
    VoiceOption(id: 'en_child_1', label: 'Milo', language: 'English', style: 'Child'),
  ];

  static const List<StoryTemplate> templates = [
    StoryTemplate(
      id: 't1', category: 'Funny Family', title: 'Funny Family Stories', emoji: '👨‍👩‍👧',
      sampleStory:
          'Papa comes home tired. Beta hides his shoes as a prank. Papa searches everywhere while everyone laughs. Finally the dog brings the shoes back.',
    ),
    StoryTemplate(
      id: 't2', category: 'Baby & Papa', title: 'Baby & Papa Comedy', emoji: '👶',
      sampleStory:
          'Papa tries to feed the baby. The baby throws the spoon every time. Papa makes funny faces to trick the baby into eating.',
    ),
    StoryTemplate(
      id: 't3', category: 'School Comedy', title: 'School Comedy', emoji: '🏫',
      sampleStory:
          'Teacher asks who did not do homework. The whole class points at one boy. He blames it on his little sister.',
    ),
    StoryTemplate(
      id: 't4', category: 'Husband & Wife', title: 'Husband & Wife Comedy', emoji: '💑',
      sampleStory:
          'Husband forgets the anniversary. Wife pretends to be upset. He panics and orders flowers, cake and chocolates all at once.',
    ),
    StoryTemplate(
      id: 't5', category: 'Friends', title: 'Friends Comedy', emoji: '🧑‍🤝‍🧑',
      sampleStory:
          'Four friends plan a trip. Each one wants a different place. They argue for an hour and end up going to the same park as always.',
    ),
    StoryTemplate(
      id: 't6', category: 'Motivational', title: 'Motivational Stories', emoji: '🌟',
      sampleStory:
          'A student fails an exam and feels hopeless. His grandfather tells him a story about never giving up. He studies again and finally succeeds.',
    ),
    StoryTemplate(
      id: 't7', category: 'Festival', title: 'Festival Videos', emoji: '🎉',
      sampleStory:
          'The whole family decorates the house for the festival. Kids burst with excitement. Everyone gathers for sweets and blessings.',
    ),
    StoryTemplate(
      id: 't8', category: 'Short Story', title: 'Short Story Templates', emoji: '📖',
      sampleStory:
          'A young girl finds an injured bird in the park. She takes care of it every day until it can fly again.',
    ),
  ];

  static List<VoiceOption> voicesFor(String language) =>
      voices.where((v) => v.language == language).toList();
}
