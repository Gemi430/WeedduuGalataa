import { getAuth } from "../config/firebase.js";

/**
 * Admin is authorized when the Firebase ID token includes:
 * - a custom claim `admin: true`, OR
 * - a custom claim `role: "admin"`.
 *
 * Expects: Authorization: Bearer <Firebase ID token>
 * Attaches: req.user
 */
export async function requireAdmin(req, res, next) {
  // Development shortcut: allow admin calls with a shared secret header.
  // Header: `x-admin-secret: <ADMIN_SECRET>`
  if (process.env.ADMIN_SECRET) {
    const incoming = req.headers["x-admin-secret"];
    if (typeof incoming === "string" && incoming === process.env.ADMIN_SECRET) {
      return next();
    }
  }

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

    const isAdmin =
      decoded?.admin === true ||
      decoded?.role === "admin" ||
      decoded?.claims?.admin === true ||
      decoded?.claims?.role === "admin";

    if (!isAdmin) {
      return res.status(403).json({ error: "Forbidden: admin only" });
    }

    next();
  } catch (err) {
    if (err.message === "Firebase not configured") {
      return res.status(503).json({ error: "Server Firebase not configured" });
    }
    return res.status(401).json({ error: "Invalid or expired token" });
  }
}

