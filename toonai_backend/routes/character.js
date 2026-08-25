const express = require("express");
const axios = require("axios");
const multer = require("multer");
const path = require("path");
const { v4: uuid } = require("uuid");

const router = express.Router();
const upload = multer({ dest: path.join(__dirname, "..", "uploads") });

/**
 * POST /api/character/upload-photo
 * multipart/form-data: { photo: <file> }
 *
 * Stores the uploaded photo and returns a public URL D-ID can fetch from.
 * IMPORTANT: only call this after the app has shown the mandatory consent
 * notice from the Photo-to-Cartoon screen and the user has confirmed it.
 */
router.post("/upload-photo", upload.single("photo"), (req, res) => {
  if (!req.file) return res.status(400).json({ error: "photo file is required" });
  const publicUrl = `${process.env.PUBLIC_BASE_URL}/uploads/${req.file.filename}`;
  res.json({ imageUrl: publicUrl });
});

/**
 * POST /api/character/animate
 * body:
 *   { imageUrl: string,               // from /upload-photo, or a saved character portrait
 *     audioUrl?: string,               // e.g. from /api/voice/tts — use this for lip-synced dialogue
 *     text?: string, ttsVoiceId?: string, // OR let D-ID do TTS itself (Microsoft voices) if no audioUrl given
 *   }
 *
 * Creates a D-ID "talk": an animated, lip-synced video of the character
 * speaking the given line. Polls until the render is complete and returns
 * the finished clip URL. In production, prefer D-ID's webhook callback
 * instead of polling to avoid tying up a request thread.
 */
router.post("/animate", async (req, res) => {
  const { imageUrl, audioUrl, text, ttsVoiceId } = req.body;
  if (!imageUrl) return res.status(400).json({ error: "imageUrl is required" });
  if (!audioUrl && !text) return res.status(400).json({ error: "either audioUrl or text is required" });

  const script = audioUrl
    ? { type: "audio", audio_url: audioUrl }
    : {
        type: "text",
        input: text,
        provider: { type: "microsoft", voice_id: ttsVoiceId || "en-US-JennyNeural" },
      };

  try {
    const auth = "Basic " + Buffer.from(process.env.DID_API_KEY).toString("base64");

    const create = await axios.post(
      "https://api.d-id.com/talks",
      { source_url: imageUrl, script },
      { headers: { Authorization: auth, "Content-Type": "application/json" } }
    );

    const talkId = create.data.id;

    // Poll for completion (D-ID renders typically take a few seconds to ~1 min).
    // For production, register a webhook URL instead of polling.
    let result = null;
    for (let attempt = 0; attempt < 30; attempt++) {
      await new Promise((r) => setTimeout(r, 2000));
      const check = await axios.get(`https://api.d-id.com/talks/${talkId}`, {
        headers: { Authorization: auth },
      });
      if (check.data.status === "done") {
        result = check.data;
        break;
      }
      if (check.data.status === "error" || check.data.status === "rejected") {
        return res.status(502).json({ error: "D-ID render failed", detail: check.data });
      }
    }

    if (!result) return res.status(504).json({ error: "D-ID render timed out" });

    res.json({ videoUrl: result.result_url, talkId, durationSec: result.duration });
  } catch (err) {
    console.error("character/animate error:", err.response?.data || err.message);
    res.status(502).json({ error: "Failed to animate character", detail: err.response?.data || err.message });
  }
});

module.exports = router;
