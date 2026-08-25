const express = require("express");
const axios = require("axios");
const ffmpeg = require("fluent-ffmpeg");
const fs = require("fs");
const path = require("path");
const { v4: uuid } = require("uuid");

const router = express.Router();
const TMP = path.join(__dirname, "..", "uploads");
const OUT = path.join(__dirname, "..", "output");

// Royalty-free music tracks — replace with your own licensed library.
// Keys must match the `musicTrack` values used in the Flutter/React app.
const MUSIC_LIBRARY = {
  "Funny Bounce": process.env.MUSIC_FUNNY_BOUNCE_URL || "",
  "Family Warmth": process.env.MUSIC_FAMILY_WARMTH_URL || "",
  "Festive Dhol": process.env.MUSIC_FESTIVE_DHOL_URL || "",
  "Motivational Rise": process.env.MUSIC_MOTIVATIONAL_URL || "",
  "Chill Acoustic": process.env.MUSIC_CHILL_ACOUSTIC_URL || "",
};

const RESOLUTIONS = {
  "9:16": { w: 1080, h: 1920 },
  "16:9": { w: 1920, h: 1080 },
};

async function downloadTo(url, destPath) {
  const response = await axios.get(url, { responseType: "stream" });
  await new Promise((resolve, reject) => {
    const writer = fs.createWriteStream(destPath);
    response.data.pipe(writer);
    writer.on("finish", resolve);
    writer.on("error", reject);
  });
  return destPath;
}

/**
 * POST /api/render/compose
 * body: {
 *   clipUrls: string[],        // per-scene D-ID talking-character clips, in order
 *   musicTrack?: string,       // key into MUSIC_LIBRARY
 *   musicVolume?: number,      // 0-1, default 0.25 (kept low under dialogue)
 *   aspectRatio: "9:16" | "16:9",
 *   watermark?: boolean,       // true = burn in "ToonAI Studio" corner logo (free tier)
 * }
 *
 * Downloads each scene clip, scales/pads them to a consistent target
 * resolution, concatenates them in order, mixes in background music, and
 * (optionally) burns in a watermark — producing one final MP4.
 *
 * NOTE: for real traffic, move this to a background job queue (e.g. Bull +
 * Redis) and notify the client via webhook/push when done, rather than
 * blocking an HTTP request for the full render time.
 */
router.post("/compose", async (req, res) => {
  const { clipUrls, musicTrack, musicVolume = 0.25, aspectRatio = "9:16", watermark = false } = req.body;
  if (!Array.isArray(clipUrls) || clipUrls.length === 0) {
    return res.status(400).json({ error: "clipUrls (non-empty array) is required" });
  }
  const { w, h } = RESOLUTIONS[aspectRatio] || RESOLUTIONS["9:16"];
  const jobId = uuid();
  const jobDir = path.join(TMP, jobId);
  fs.mkdirSync(jobDir, { recursive: true });

  try {
    // 1) Download all scene clips locally.
    const localClips = await Promise.all(
      clipUrls.map((url, i) => downloadTo(url, path.join(jobDir, `scene_${i}.mp4`)))
    );

    // 2) Normalize each clip to the target resolution (scale + pad, keep aspect).
    const normalizedClips = [];
    for (let i = 0; i < localClips.length; i++) {
      const outPath = path.join(jobDir, `norm_${i}.mp4`);
      await new Promise((resolve, reject) => {
        ffmpeg(localClips[i])
          .videoFilters([
            `scale=w=${w}:h=${h}:force_original_aspect_ratio=decrease`,
            `pad=${w}:${h}:(ow-iw)/2:(oh-ih)/2:color=black`,
          ])
          .outputOptions(["-c:a aac", "-ar 44100"])
          .save(outPath)
          .on("end", resolve)
          .on("error", reject);
      });
      normalizedClips.push(outPath);
    }

    // 3) Concatenate normalized clips.
    const concatListPath = path.join(jobDir, "concat.txt");
    fs.writeFileSync(concatListPath, normalizedClips.map((p) => `file '${p}'`).join("\n"));
    const concatenatedPath = path.join(jobDir, "concatenated.mp4");
    await new Promise((resolve, reject) => {
      ffmpeg()
        .input(concatListPath)
        .inputOptions(["-f concat", "-safe 0"])
        .outputOptions(["-c copy"])
        .save(concatenatedPath)
        .on("end", resolve)
        .on("error", reject);
    });

    // 4) Mix in background music (looped/trimmed to video length, lowered volume).
    let withMusicPath = concatenatedPath;
    const musicUrl = musicTrack ? MUSIC_LIBRARY[musicTrack] : null;
    if (musicUrl) {
      const musicLocal = path.join(jobDir, "music.mp3");
      await downloadTo(musicUrl, musicLocal);
      withMusicPath = path.join(jobDir, "with_music.mp4");
      await new Promise((resolve, reject) => {
        ffmpeg(concatenatedPath)
          .input(musicLocal)
          .inputOptions(["-stream_loop -1"])
          .complexFilter([
            `[1:a]volume=${musicVolume}[music]`,
            `[0:a][music]amix=inputs=2:duration=first:dropout_transition=2[aout]`,
          ])
          .outputOptions(["-map 0:v", "-map [aout]", "-shortest"])
          .save(withMusicPath)
          .on("end", resolve)
          .on("error", reject);
      });
    }

    // 5) Optional watermark burn-in for free-tier exports.
    const finalFilename = `toonai_${jobId}.mp4`;
    const finalPath = path.join(OUT, finalFilename);
    if (watermark) {
      await new Promise((resolve, reject) => {
        ffmpeg(withMusicPath)
          .videoFilters([
            `drawtext=text='ToonAI Studio':fontcolor=white@0.85:fontsize=28:x=w-tw-24:y=h-th-24:box=1:boxcolor=black@0.35:boxborderw=8`,
          ])
          .save(finalPath)
          .on("end", resolve)
          .on("error", reject);
      });
    } else {
      fs.copyFileSync(withMusicPath, finalPath);
    }

    // Clean up intermediate files, keep only the final export.
    fs.rmSync(jobDir, { recursive: true, force: true });

    res.json({ videoUrl: `${process.env.PUBLIC_BASE_URL}/files/${finalFilename}` });
  } catch (err) {
    console.error("render/compose error:", err.message);
    fs.rmSync(jobDir, { recursive: true, force: true });
    res.status(500).json({ error: "Failed to compose final video", detail: err.message });
  }
});

module.exports = router;
