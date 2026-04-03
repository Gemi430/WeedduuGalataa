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
  : true;

app.use(
  cors({
    origin: corsOrigins,
    credentials: true,
  }),
);
app.use(express.json());

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

app.listen(port, () => {
  console.log(`API listening on http://localhost:${port}`);
});
