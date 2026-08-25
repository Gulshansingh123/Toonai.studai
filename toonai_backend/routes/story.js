const express = require("express");
const Anthropic = require("@anthropic-ai/sdk");

const router = express.Router();
const anthropic = new Anthropic({ apiKey: process.env.ANTHROPIC_API_KEY });

const BACKGROUNDS = ["Home", "School", "Office", "Park", "Village", "City", "Shop"];
const ACTIONS = ["Walk", "Talk", "Laugh", "Cry", "Wave", "Sit", "Stand", "Run", "Hug", "Jump", "Point", "Idle"];

/**
 * POST /api/story/split
 * body: { story: string, language: "Hindi" | "English" | "Hinglish" }
 *
 * Calls Claude to break a story into cartoon scenes. Returns strict JSON so
 * the client can render it directly into the Scene Editor.
 */
router.post("/split", async (req, res) => {
  const { story, language = "English" } = req.body;
  if (!story || !story.trim()) {
    return res.status(400).json({ error: "story is required" });
  }

  const system = `You split short stories/dialogues into cartoon video scenes.
Rules:
- Return ONLY valid JSON, no prose, no markdown fences.
- JSON shape: { "scenes": [ { "dialogue": string, "background": string, "action": string, "characterHints": string[] } ] }
- "background" must be one of: ${BACKGROUNDS.join(", ")}.
- "action" must be one of: ${ACTIONS.join(", ")}.
- "characterHints" is a short list of who is likely speaking/present in the scene (e.g. ["Papa","Baby"]), inferred from the text.
- Keep each scene's dialogue short enough to speak in a few seconds (roughly one sentence or beat).
- Preserve the story's original language (${language}) in "dialogue".
- Produce between 3 and 12 scenes depending on story length.`;

  try {
    const msg = await anthropic.messages.create({
      model: process.env.CLAUDE_MODEL || "claude-sonnet-5",
      max_tokens: 2000,
      system,
      messages: [{ role: "user", content: story }],
    });

    const text = msg.content.find((b) => b.type === "text")?.text ?? "{}";
    const cleaned = text.replace(/```json|```/g, "").trim();
    const parsed = JSON.parse(cleaned);

    res.json({ scenes: parsed.scenes || [] });
  } catch (err) {
    console.error("story/split error:", err.message);
    res.status(502).json({ error: "Failed to split story into scenes", detail: err.message });
  }
});

module.exports = router;
