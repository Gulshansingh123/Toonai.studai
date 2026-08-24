# ToonAI Studio — AI Cartoon Video Maker

"Apni Story, Apna Character, Apna Cartoon Video!"

A working Flutter app scaffold covering all 13 screens from the PRD, with
functional in-memory navigation, character creation, story-to-scene
splitting, scene editing, voice selection, a mock video preview, export
flow, a Premium paywall, and Settings.

## ⚠️ What's real vs. mocked

This app is wired to **real AI services** via a companion backend
(`/toonai_backend` in this same zip) — story splitting, voice, and
photo-to-talking-character are no longer mocked. Set your backend URL in
`lib/services/ai_service.dart` (`AiService(baseUrl: ...)`) and set up your
API keys per `toonai_backend/README.md`, and these flows call real AI:

| Feature | Backed by |
|---|---|
| Story → Scenes | Claude (Anthropic API) |
| Voice | ElevenLabs Text-to-Speech (Hindi + English) |
| Photo → Talking Character | D-ID (photo → lip-synced talking video) |
| Final Video | ffmpeg on the backend (stitches scenes, mixes music, burns in watermark) |

Two things are still intentionally left as `// TODO` for you to wire up,
since they're platform-specific rather than AI-specific:

| Feature | Current state | To make it real |
|---|---|---|
| Camera/gallery photo picking | `photo_to_cartoon_screen.dart` marks a photo as "picked" without real bytes | Add the `image_picker` package and use its result's bytes in `_generate()` |
| Rewarded ads / Play Billing | Mocked instantly in `home_screen.dart`, `premium_screen.dart`, `export_screen.dart` | Wire `google_mobile_ads` and `in_app_purchase` — see PRD §2.9 |

One honest limitation: **built-in chip-based characters (not from a photo)
don't have a real portrait image**, so `renderSceneClip` in `app_state.dart`
will throw for them until you add a text-to-image step (e.g. via Replicate)
that generates a portrait from the character's chosen hairstyle/outfit/skin
tone/etc. Photo-to-Cartoon characters work today since they have a real
uploaded photo. See `toonai_backend/README.md` §7 for more on this gap.

## Project structure

```
lib/
  main.dart                  # App entry point
  theme/app_theme.dart       # Brand colors, Material theme
  models/models.dart         # Character, Scene, Project, Voice, Template
  data/catalog.dart          # Static content catalog (character types, voices,
                              # backgrounds, actions, templates) — swap for a
                              # CMS/API call to make content server-driven
  state/app_state.dart       # App-wide state (Provider), mocked AI calls
  widgets/shared_widgets.dart# Reusable chips, cards, buttons, avatars
  screens/                   # All 13 screens from the PRD
```

## Setup — run it for real

You'll need the Flutter SDK installed locally (this was built in a sandbox
with no internet access, so it hasn't been compiled or run yet).

1. **Install Flutter**: https://docs.flutter.dev/get-started/install
2. **Copy this project** to your machine, then from its root run:
   ```bash
   flutter create --platforms=android .
   ```
   This generates the `android/` platform folder matching your exact
   installed Flutter/Gradle/Kotlin versions (safer than hand-copying
   platform files, which are version-sensitive). It won't overwrite the
   `lib/` folder or `pubspec.yaml` you already have.
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run on an emulator or connected Android device:
   ```bash
   flutter run
   ```
5. Build a release APK:
   ```bash
   flutter build apk --release
   ```

## Next steps toward production

1. Swap the three mocked features above for real backend calls (see PRD
   §5.2 for the suggested Story/Character/Voice/Render service split).
2. Add persistence: `lib/state/app_state.dart` is in-memory only right now —
   plug in Hive or SQLite (`sqflite`) so drafts survive app restarts, per
   PRD §5.1.
3. Add `image_picker` for real camera/gallery photo selection in
   `photo_to_cartoon_screen.dart`.
4. Wire `google_mobile_ads` (AdMob) and `in_app_purchase` (Play Billing) —
   entry points are already isolated in `AppState`.
5. Add authentication + cloud sync if you want cross-device projects.
6. Add server-side content moderation on story text and uploaded photos
   before they reach the render pipeline (PRD §7).

## Design tokens

- Primary: `#6C3CE9` (deep violet)
- Accent: `#FF7A59` (coral)
- Background tint: `#F2EEFD`

See the companion PRD document for full feature specs, screen-by-screen
requirements, monetization tiers, and the content-safety policy.


## Android + Codemagic

This ZIP now includes the `android/` platform folder and a root `codemagic.yaml` for Android APK builds. Open the `toonai_studio` folder in Android Studio (with Flutter SDK configured), run `flutter pub get`, then build/run the app.
