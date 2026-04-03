import { getAuth } from "../config/firebase.js";

/**
 * Expects: Authorization: Bearer <Firebase ID token>
 * Attaches req.user = { uid, ...decodedToken }
 */
export async function requireAuth(req, res, next) {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    return res.status(401).json({ error: "Missing or invalid Authorization header" });
  }

  const token = header.slice("Bearer ".length).trim();
  if (!token) {
    return res.status(401).json({ error: "Empty bearer token" });
  }

  try {
    const decoded = await getAuth().verifyIdToken(token);
    req.user = decoded;
    next();
  } catch (err) {
    if (err.message === "Firebase not configured") {
      return res.status(503).json({ error: "Server Firebase not configured" });
    }
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}
