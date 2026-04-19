import { onRequest } from "firebase-functions/v2/https";
import express from "express";
import cors from "cors";
import { initFirebase } from "../src/config/firebase.js";
import { requireAuth } from "../src/middleware/auth.js";
import { adminRouter } from "../src/routes/admin.js";
import { catalogRouter } from "../src/routes/catalog.js";

const app = express();

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

// Initialize Firebase Admin
initFirebase();

app.get("/health", (_req, res) => {
  res.json({ ok: true, service: "weedduu-galataa-api" });
});

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

// Export as Cloud Function
export const api = onRequest(
  {
    region: "us-central1",
    memory: "256MiB",
    timeoutSeconds: 60,
    minInstances: 0,
    maxInstances: 100,
  },
  app
);