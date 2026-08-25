require("dotenv").config();
const express = require("express");
const cors = require("cors");
const path = require("path");
const fs = require("fs");

const storyRoutes = require("./routes/story");
const voiceRoutes = require("./routes/voice");
const characterRoutes = require("./routes/character");
const renderRoutes = require("./routes/render");

const app = express();
app.use(cors());
app.use(express.json({ limit: "5mb" }));

// Ensure working directories exist.
for (const dir of ["uploads", "output"]) {
  const p = path.join(__dirname, dir);
  if (!fs.existsSync(p)) fs.mkdirSync(p, { recursive: true });
}

// Serve uploaded photos and rendered/audio output as static files so
// D-ID, ElevenLabs results, and the Flutter app can all fetch by URL.
app.use("/uploads", express.static(path.join(__dirname, "uploads")));
app.use("/files", express.static(path.join(__dirname, "output")));

app.get("/health", (_req, res) => res.json({ ok: true }));

app.use("/api/story", storyRoutes);
app.use("/api/voice", voiceRoutes);
app.use("/api/character", characterRoutes);
app.use("/api/render", renderRoutes);

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`ToonAI Studio backend listening on port ${PORT}`);
  console.log(`Public base URL: ${process.env.PUBLIC_BASE_URL}`);
});
