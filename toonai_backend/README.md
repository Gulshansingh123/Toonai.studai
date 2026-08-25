# ToonAI Studio — AI Backend

This is a **real, working backend** (not mocked) that wires ToonAI Studio to
actual AI providers:

| Step | Provider | What it does |
|---|---|---|
| Story → Scenes | **Claude (Anthropic API)** | Splits a Hindi/English story into structured scenes with background + action suggestions |
| Voice | **ElevenLabs** | Text-to-speech in Hindi & English, multiple voice styles |
| Photo → Talking Character | **D-ID** | Turns a photo into a lip-synced, talking animated character speaking each scene's dialogue |
| Final Video | **ffmpeg** (self-hosted) | Stitches all scene clips together, mixes in background music, optionally burns in a watermark |

## 1. Get API keys

1. **Anthropic (Claude)** — https://console.anthropic.com → API Keys
2. **ElevenLabs** — https://elevenlabs.io → Profile → API Keys. Also grab
   voice IDs for the Hindi/English voices you want from the Voice Library
   (https://elevenlabs.io/docs/api-reference/voices/search) and put them in
   `.env` (`ELEVENLABS_VOICE_HI_FEMALE`, etc.)
3. **D-ID** — https://studio.d-id.com → API tab. Free trial includes a
   limited number of render credits/minutes to test with.

Copy `.env.example` to `.env` and fill in all keys.

## 2. Install ffmpeg on the server

`fluent-ffmpeg` is a wrapper — the actual `ffmpeg` binary must be installed
on the machine running this server:

```bash
# Ubuntu/Debian
sudo apt install ffmpeg
# macOS
brew install ffmpeg
```

## 3. Run it

```bash
npm install
cp .env.example .env   # then edit .env with your real keys
npm start
```

The server needs to be reachable at the `PUBLIC_BASE_URL` you set in `.env`
(D-ID and the app fetch uploaded photos/audio/video by URL) — for local
testing, tunnel it with something like `ngrok http 8080` and put the ngrok
URL in `PUBLIC_BASE_URL`. In production, deploy it behind a real domain
(Render, Fly.io, a VPS, etc.) with HTTPS.

## 4. How a video actually gets made (end-to-end)

1. App calls `POST /api/story/split` → Claude returns structured scenes.
2. For each scene: app calls `POST /api/voice/tts` → ElevenLabs returns an
   `audioUrl` for that scene's dialogue, in the chosen character's voice.
3. App calls `POST /api/character/animate` with the character's portrait +
   that scene's `audioUrl` → D-ID returns a `videoUrl` of the character
   speaking that line, lip-synced.
4. Once every scene has a clip, app calls `POST /api/render/compose` with
   the ordered list of clip URLs → ffmpeg stitches them into one final
   video, mixes in music, and (for free-tier users) burns in the
   "ToonAI Studio" watermark.

## 5. Costs & scaling notes

- D-ID and ElevenLabs are **paid, credit-metered APIs** — every generation
  in the app costs real money once you go over the free trial. Enforce the
  app's free-generation caps (`AppState.consumeGeneration()` in Flutter) on
  this server too — never trust the client alone.
- Move `render/compose` and `character/animate` to a background job queue
  (e.g. Bull + Redis, or a cloud task queue) for production — they can take
  well over a minute and shouldn't block an HTTP request thread. This
  scaffold polls synchronously to keep the example readable.
- Add authentication (e.g. Firebase Auth token verification) on every route
  before going live — right now anyone with the URL can call these and
  spend your API credits.

## 6. Content safety (do not skip)

- Only call `/api/character/upload-photo` **after** the app has shown the
  mandatory photo-upload consent notice and the user has confirmed it (see
  the Photo-to-Cartoon screen).
- Add a moderation check (e.g. a vision-moderation API, or Claude with a
  moderation prompt) on uploaded photos and story text **before** they
  reach D-ID/ElevenLabs, to catch disallowed content early.
- Log consent confirmations with a timestamp for trust & safety review.

## 7. Character animation quality note

D-ID is built for realistic "talking head" presenter videos from a photo,
not stylized/2D cartoon rigs. For a closer match to the built-in
chip-based cartoon characters (walk/wave/laugh/sit, not just talk), you'll
eventually want a second pipeline — e.g. a 2D skeletal rig (Spine/DragonBones
style) driven by the same audio's timing, or a generative video model via
Replicate for stylized animation. D-ID is the fastest real path to "photo
says the dialogue with lip-sync" today; treat it as Phase 1 for the
Photo-to-Cartoon feature specifically, and keep the built-in character
action library (Section 2.5 of the PRD) for fully-designed characters.
