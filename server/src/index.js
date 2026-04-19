import "dotenv/config";
import cors from "cors";
import express from "express";
import { initFirebase } from "./config/firebase.js";
import { requireAuth } from "./middleware/auth.js";
import { adminRouter } from "./routes/admin.js";
import { catalogRouter } from "./routes/catalog.js";

const app = express();
const port = Number(process.env.PORT) || 3000;

const corsOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(",").map((s) => s.trim())
  : ["*"];

app.use(
  cors({
    origin: corsOrigins,
    credentials: true,
  })
);
app.use(express.json());

// Health check endpoint for Render
app.get("/health", (_req, res) => {
  res.status(200).json({ ok: true, service: "weedduu-galataa-api", timestamp: new Date().toISOString() });
});

// Readiness check
app.get("/ready", (_req, res) => {
  res.status(200).json({ ready: true });
});

initFirebase();

app.get("/api/me", requireAuth, (req, res) => {
  res.json({
    uid: req.user.uid,
    email: req.user.email ?? null,
  });
});

app.use("/api/catalog", catalogRouter);
app.use("/api/admin", adminRouter);

app.use((err, _req, res, _next) => {
  console.error(err);
  if (err?.message === "Firebase not configured") {
    return res.status(503).json({ error: "Server Firebase not configured" });
  }
  res.status(500).json({ error: "Internal server error" });
});

// Use the PORT environment variable (required for Render)
const server = app.listen(port, '0.0.0.0', () => {
  console.log(`API listening on http://0.0.0.0:${port}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
});

export default server;