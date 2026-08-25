const express = require("express");
const axios = require("axios");
const fs = require("fs");
const path = require("path");
const { v4: uuid } = require("uuid");

const router = express.Router();

// Map our in-app voice styles to real ElevenLabs voice IDs.
// Replace these with voice IDs from your own ElevenLabs "Voice Library"
// (Hindi + English voices, or your own cloned/designed voices).
// See: https://elevenlabs.io/docs/api-reference/voices/search
const VOICE_MAP = {
  hi_female_1: process.env.ELEVENLABS_VOICE_HI_FEMALE || "21m00Tcm4TlvDq8ikWAM",
  hi_male_1: process.env.ELEVENLABS_VOICE_HI_MALE || "29vD33N1CtxCmqQRPOHJ",
  hi_child_1: process.env.ELEVENLABS_VOICE_HI_CHILD || "21m00Tcm4TlvDq8ikWAM",
  en_female_1: process.env.ELEVENLABS_VOICE_EN_FEMALE || "21m00Tcm4TlvDq8ikWAM",
  en_male_1: process.env.ELEVENLABS_VOICE_EN_MALE || "29vD33N1CtxCmqQRPOHJ",
  en_child_1: process.env.ELEVENLABS_VOICE_EN_CHILD || "21m00Tcm4TlvDq8ikWAM",
};

/**
 * POST /api/voice/tts
 * body: { text: string, voiceId: string ("hi_female_1", etc.) }
 *
 * Synthesizes speech with ElevenLabs and saves the MP3 to /output, returning
 * a URL the app (or the D-ID animate step) can use.
 */
router.post("/tts", async (req, res) => {
  const { text, voiceId = "en_female_1" } = req.body;
  if (!text || !text.trim()) return res.status(400).json({ error: "text is required" });

  const elevenVoiceId = VOICE_MAP[voiceId] || VOICE_MAP.en_female_1;

  try {
    const response = await axios.post(
      `https://api.elevenlabs.io/v1/text-to-speech/${elevenVoiceId}`,
      {
        text,
        model_id: "eleven_multilingual_v2", // supports Hindi + English in one model
      },
      {
        headers: {
          "xi-api-key": process.env.ELEVENLABS_API_KEY,
          "Content-Type": "application/json",
        },
        responseType: "arraybuffer",
      }
    );

    const filename = `voice_${uuid()}.mp3`;
    const filePath = path.join(__dirname, "..", "output", filename);
    fs.writeFileSync(filePath, response.data);

    res.json({ audioUrl: `${process.env.PUBLIC_BASE_URL}/files/${filename}` });
  } catch (err) {
    console.error("voice/tts error:", err.response?.data?.toString?.() || err.message);
    res.status(502).json({ error: "Failed to synthesize voice", detail: err.message });
  }
});

module.exports = router;
