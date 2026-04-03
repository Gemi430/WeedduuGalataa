import express from "express";
import { getFirestore } from "../config/firebase.js";
import { requireAdmin } from "../middleware/admin.js";
import { isValidLyricPayload } from "../lib/lyrics.js";

export const adminRouter = express.Router();

function asyncHandler(fn) {
  return (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
}

adminRouter.use(requireAdmin);

// ---------- Helpers ----------
function nowIso() {
  return new Date().toISOString();
}

function docToJson(doc) {
  return { id: doc.id, ...doc.data() };
}

// ---------- Scales ----------
adminRouter.get("/scales", asyncHandler(async (_req, res) => {
  const db = getFirestore();
  const snap = await db.collection("scales").get();
  res.json({ items: snap.docs.map(docToJson) });
}));

adminRouter.post("/scales", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { id, name } = req.body ?? {};

  if (typeof name !== "string" || !name.trim()) {
    return res.status(400).json({ error: "name is required" });
  }

  const data = { name: name.trim(), updatedAt: nowIso() };
  const ref = id ? db.collection("scales").doc(String(id)) : db.collection("scales").doc();
  await ref.set(data, { merge: true });
  res.status(201).json({ id: ref.id, ...data });
}));

adminRouter.put("/scales/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { name } = req.body ?? {};
  if (typeof name !== "string" || !name.trim()) {
    return res.status(400).json({ error: "name is required" });
  }
  await db.collection("scales").doc(req.params.id).set(
    { name: name.trim(), updatedAt: nowIso() },
    { merge: true },
  );
  res.json({ ok: true });
}));

adminRouter.delete("/scales/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  await db.collection("scales").doc(req.params.id).delete();
  res.json({ ok: true });
}));

// ---------- Styles ----------
adminRouter.get("/styles", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { scaleId } = req.query ?? {};

  const q = db.collection("styles");
  const snap = scaleId
    ? await q.where("scaleId", "==", String(scaleId)).get()
    : await q.get();

  res.json({ items: snap.docs.map(docToJson) });
}));

adminRouter.post("/styles", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { id, name, scaleId } = req.body ?? {};

  if (typeof name !== "string" || !name.trim()) {
    return res.status(400).json({ error: "name is required" });
  }
  if (!scaleId) {
    return res.status(400).json({ error: "scaleId is required" });
  }

  const data = { name: name.trim(), scaleId: String(scaleId), updatedAt: nowIso() };
  const ref = id ? db.collection("styles").doc(String(id)) : db.collection("styles").doc();
  await ref.set(data, { merge: true });
  res.status(201).json({ id: ref.id, ...data });
}));

adminRouter.put("/styles/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { name, scaleId } = req.body ?? {};
  if (typeof name !== "string" || !name.trim()) {
    return res.status(400).json({ error: "name is required" });
  }
  if (!scaleId) {
    return res.status(400).json({ error: "scaleId is required" });
  }

  await db.collection("styles").doc(req.params.id).set(
    { name: name.trim(), scaleId: String(scaleId), updatedAt: nowIso() },
    { merge: true },
  );
  res.json({ ok: true });
}));

adminRouter.delete("/styles/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  await db.collection("styles").doc(req.params.id).delete();
  res.json({ ok: true });
}));

// ---------- Singers ----------
adminRouter.get("/singers", asyncHandler(async (_req, res) => {
  const db = getFirestore();
  const snap = await db.collection("singers").get();
  res.json({ items: snap.docs.map(docToJson) });
}));

adminRouter.post("/singers", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { id, name } = req.body ?? {};

  if (typeof name !== "string" || !name.trim()) {
    return res.status(400).json({ error: "name is required" });
  }

  const data = { name: name.trim(), updatedAt: nowIso() };
  const ref = id ? db.collection("singers").doc(String(id)) : db.collection("singers").doc();
  await ref.set(data, { merge: true });
  res.status(201).json({ id: ref.id, ...data });
}));

adminRouter.put("/singers/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { name } = req.body ?? {};
  if (typeof name !== "string" || !name.trim()) {
    return res.status(400).json({ error: "name is required" });
  }
  await db.collection("singers").doc(req.params.id).set(
    { name: name.trim(), updatedAt: nowIso() },
    { merge: true },
  );
  res.json({ ok: true });
}));

adminRouter.delete("/singers/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  await db.collection("singers").doc(req.params.id).delete();
  res.json({ ok: true });
}));

// ---------- Songs (metadata only; lyrics live in songVersions) ----------
adminRouter.get("/songs", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const snap = await db.collection("songs").get();
  res.json({ items: snap.docs.map(docToJson) });
}));

adminRouter.post("/songs", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { id, title, shortTitle } = req.body ?? {};

  if (typeof title !== "string" || !title.trim()) {
    return res.status(400).json({ error: "title is required" });
  }
  const data = {
    title: title.trim(),
    shortTitle: typeof shortTitle === "string" && shortTitle.trim() ? shortTitle.trim() : null,
    updatedAt: nowIso(),
  };

  const ref = id ? db.collection("songs").doc(String(id)) : db.collection("songs").doc();
  await ref.set(data, { merge: true });
  res.status(201).json({ id: ref.id, ...data });
}));

adminRouter.put("/songs/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { title, shortTitle } = req.body ?? {};

  if (typeof title !== "string" || !title.trim()) {
    return res.status(400).json({ error: "title is required" });
  }

  await db.collection("songs").doc(req.params.id).set(
    {
      title: title.trim(),
      shortTitle:
        typeof shortTitle === "string" && shortTitle.trim() ? shortTitle.trim() : null,
      updatedAt: nowIso(),
    },
    { merge: true },
  );
  res.json({ ok: true });
}));

adminRouter.delete("/songs/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  await db.collection("songs").doc(req.params.id).delete();
  res.json({ ok: true });
}));

// ---------- Song ↔ Singers (many-to-many) ----------
// We store as collection `songSingers` with doc id `${songId}__${singerId}`.
adminRouter.post("/songSingers", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { songId, singerId } = req.body ?? {};
  if (!songId || !singerId) {
    return res.status(400).json({ error: "songId and singerId are required" });
  }

  const id = `${String(songId)}__${String(singerId)}`;
  await db.collection("songSingers").doc(id).set(
    { songId: String(songId), singerId: String(singerId), updatedAt: nowIso() },
    { merge: true },
  );

  res.status(201).json({ ok: true, id });
}));

adminRouter.delete("/songSingers/:songId/:singerId", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { songId, singerId } = req.params;
  const id = `${String(songId)}__${String(singerId)}`;
  await db.collection("songSingers").doc(id).delete();
  res.json({ ok: true });
}));

// ---------- Song Versions (structured lyrics) ----------
// Doc id is `${songId}__${scaleId}__${styleId}` so each version is unique.
adminRouter.get("/songVersions", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { songId, scaleId, styleId } = req.query ?? {};

  if (songId && scaleId && styleId) {
    const id = `${String(songId)}__${String(scaleId)}__${String(styleId)}`;
    const doc = await db.collection("songVersions").doc(id).get();
    if (!doc.exists) return res.status(404).json({ error: "Not found" });
    return res.json({ item: docToJson(doc) });
  }

  // Fallback: limited query by whichever params exist
  let q = db.collection("songVersions").orderBy("updatedAt", "desc");
  if (songId) q = q.where("songId", "==", String(songId));
  if (scaleId) q = q.where("scaleId", "==", String(scaleId));
  if (styleId) q = q.where("styleId", "==", String(styleId));

  const snap = await q.limit(50).get();
  res.json({ items: snap.docs.map(docToJson) });
}));

adminRouter.post("/songVersions", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { songId, scaleId, styleId, lyrics } = req.body ?? {};

  if (!songId || !scaleId || !styleId) {
    return res.status(400).json({ error: "songId, scaleId, styleId are required" });
  }
  if (!lyrics || typeof lyrics !== "object" || !isValidLyricPayload(lyrics)) {
    return res.status(400).json({ error: "Invalid lyrics payload" });
  }

  const id = `${String(songId)}__${String(scaleId)}__${String(styleId)}`;
  const data = {
    songId: String(songId),
    scaleId: String(scaleId),
    styleId: String(styleId),
    lyrics,
    updatedAt: nowIso(),
  };

  await db.collection("songVersions").doc(id).set(data, { merge: true });
  res.status(201).json({ ok: true, id });
}));

adminRouter.put("/songVersions/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  const { lyrics } = req.body ?? {};
  if (!lyrics || typeof lyrics !== "object" || !isValidLyricPayload(lyrics)) {
    return res.status(400).json({ error: "Invalid lyrics payload" });
  }

  await db.collection("songVersions").doc(req.params.id).set(
    { lyrics, updatedAt: nowIso() },
    { merge: true },
  );
  res.json({ ok: true });
}));

adminRouter.delete("/songVersions/:id", asyncHandler(async (req, res) => {
  const db = getFirestore();
  await db.collection("songVersions").doc(req.params.id).delete();
  res.json({ ok: true });
}));

