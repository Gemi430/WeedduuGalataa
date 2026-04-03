import express from "express";
import { getFirestore } from "../config/firebase.js";

export const catalogRouter = express.Router();

function asyncHandler(fn) {
  return (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
}

function docToJson(doc) {
  return { id: doc.id, ...doc.data() };
}

// ---------- Catalog reads (public) ----------
catalogRouter.get("/scales", asyncHandler(async (_req, res) => {
  const db = getFirestore();
  const snap = await db.collection("scales").get();
  res.json({ items: snap.docs.map(docToJson) });
}));

catalogRouter.get("/scales/:scaleId/styles", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const snap = await db
    .collection("styles")
    .where("scaleId", "==", String(req.params.scaleId))
    .get();
  res.json({ items: snap.docs.map(docToJson) });
}));

catalogRouter.get("/singers", asyncHandler(async (_req, res) => {
  const db = getFirestore();
  const snap = await db.collection("singers").get();
  res.json({ items: snap.docs.map(docToJson) });
}));

catalogRouter.get("/singers/:singerId/songs", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { singerId } = req.params;

  // Find songs linked to the singer
  const mapSnap = await db.collection("songSingers").where("singerId", "==", singerId).get();
  const songIds = Array.from(new Set(mapSnap.docs.map((d) => d.data().songId))).filter(Boolean);

  if (songIds.length === 0) return res.json({ items: [] });

  // Firestore 'in' queries are limited; chunk it.
  const chunks = [];
  const chunkSize = 10;
  for (let i = 0; i < songIds.length; i += chunkSize) {
    chunks.push(songIds.slice(i, i + chunkSize));
  }

  const results = [];
  for (const c of chunks) {
    const snap = await db.collection("songs").where("__name__", "in", c).get();
    results.push(...snap.docs.map(docToJson));
  }

  res.json({ items: results });
}));

// List songs available for a given (scale, style)
catalogRouter.get("/songs", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { scaleId, styleId } = req.query ?? {};

  let q = db.collection("songVersions");
  if (scaleId) q = q.where("scaleId", "==", String(scaleId));
  if (styleId) q = q.where("styleId", "==", String(styleId));

  const snap = await q.limit(200).get();
  const songIds = Array.from(new Set(snap.docs.map((d) => d.data().songId))).filter(Boolean);

  if (songIds.length === 0) return res.json({ items: [] });

  const chunks = [];
  const chunkSize = 10;
  for (let i = 0; i < songIds.length; i += chunkSize) chunks.push(songIds.slice(i, i + chunkSize));

  const results = [];
  for (const c of chunks) {
    const songSnap = await db.collection("songs").where("__name__", "in", c).get();
    results.push(...songSnap.docs.map(docToJson));
  }

  res.json({ items: results });
}));

// Get one song version lyrics
catalogRouter.get("/songVersions", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { songId, scaleId, styleId } = req.query ?? {};
  if (!songId || !scaleId || !styleId) {
    return res.status(400).json({ error: "songId, scaleId, styleId are required" });
  }

  const id = `${String(songId)}__${String(scaleId)}__${String(styleId)}`;
  const doc = await db.collection("songVersions").doc(id).get();
  if (!doc.exists) return res.status(404).json({ error: "Not found" });

  res.json({ item: docToJson(doc) });
}));

