import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Talks to the ToonAI Studio backend (see /toonai_backend), which in turn
/// calls Claude (story→scenes), ElevenLabs (voice), D-ID (photo→talking
/// character with lip-sync), and ffmpeg (final video composition).
///
/// Set [baseUrl] to wherever you deploy that backend
/// (see toonai_backend/README.md — e.g. an ngrok URL while testing, or
/// your production domain).
class AiService {
  AiService({this.baseUrl = "https://YOUR-BACKEND-URL.example.com"});

  final String baseUrl;

  Map<String, String> get _jsonHeaders => {"Content-Type": "application/json"};

  /// Splits a story into scenes using the backend's Claude-powered endpoint.
  /// Throws on network/API failure — callers should catch and fall back to
  /// a friendly error state (see CreateStoryScreen).
  Future<List<ToonScene>> splitStory(String story, {String language = "English"}) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/story/split"),
      headers: _jsonHeaders,
      body: jsonEncode({"story": story, "language": language}),
    );
    if (res.statusCode != 200) {
      throw Exception("Story split failed (${res.statusCode}): ${res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final scenes = (data["scenes"] as List<dynamic>? ?? []);
    return scenes.map((s) {
      return ToonScene(
        dialogue: s["dialogue"] as String? ?? "",
        background: s["background"] as String? ?? "Home",
        action: s["action"] as String? ?? "Talk",
      );
    }).toList();
  }

  /// Synthesizes speech for one line of dialogue in the given character
  /// voice. Returns a URL to the generated audio (mp3).
  Future<String> synthesizeVoice(String text, String voiceId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/voice/tts"),
      headers: _jsonHeaders,
      body: jsonEncode({"text": text, "voiceId": voiceId}),
    );
    if (res.statusCode != 200) {
      throw Exception("Voice synthesis failed (${res.statusCode}): ${res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data["audioUrl"] as String;
  }

  /// Uploads a user's photo (only call this after the mandatory consent
  /// checkbox on the Photo-to-Cartoon screen has been confirmed) and
  /// returns a public URL for it.
  Future<String> uploadPhoto(List<int> photoBytes, String filename) async {
    final uri = Uri.parse("$baseUrl/api/character/upload-photo");
    final request = http.MultipartRequest("POST", uri)
      ..files.add(http.MultipartFile.fromBytes("photo", photoBytes, filename: filename));
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception("Photo upload failed (${res.statusCode}): ${res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data["imageUrl"] as String;
  }

  /// Turns a character photo + one line of (already-synthesized) dialogue
  /// audio into a lip-synced talking video clip for that scene.
  Future<String> animateCharacter({required String imageUrl, required String audioUrl}) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/character/animate"),
      headers: _jsonHeaders,
      body: jsonEncode({"imageUrl": imageUrl, "audioUrl": audioUrl}),
    );
    if (res.statusCode != 200) {
      throw Exception("Character animation failed (${res.statusCode}): ${res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data["videoUrl"] as String;
  }

  /// Stitches all per-scene clips into the final exportable video, mixing
  /// in background music and (for free-tier users) a watermark.
  Future<String> composeVideo({
    required List<String> clipUrls,
    String? musicTrack,
    double musicVolume = 0.25,
    required String aspectRatio, // "9:16" or "16:9"
    required bool watermark,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/render/compose"),
      headers: _jsonHeaders,
      body: jsonEncode({
        "clipUrls": clipUrls,
        "musicTrack": musicTrack,
        "musicVolume": musicVolume,
        "aspectRatio": aspectRatio,
        "watermark": watermark,
      }),
    );
    if (res.statusCode != 200) {
      throw Exception("Video composition failed (${res.statusCode}): ${res.body}");
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data["videoUrl"] as String;
  }
}
