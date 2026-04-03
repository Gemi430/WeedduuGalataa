import admin from "firebase-admin";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";

let initialized = false;

function hasCredentials() {
  return Boolean(
    process.env.FIREBASE_SERVICE_ACCOUNT_JSON ||
      process.env.GOOGLE_APPLICATION_CREDENTIALS,
  );
}

/**
 * Initialize Firebase Admin once. Call before using auth() or firestore().
 * Returns null if no service account env is set (useful for local health checks).
 */
export function initFirebase() {
  if (initialized) {
    return admin;
  }

  if (!hasCredentials()) {
    console.warn(
      "[firebase] No credentials. Set GOOGLE_APPLICATION_CREDENTIALS or FIREBASE_SERVICE_ACCOUNT_JSON for Auth/Firestore.",
    );
    return null;
  }

  const json = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  const credPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

  if (json) {
    const parsed = JSON.parse(json);
    admin.initializeApp({
      credential: admin.credential.cert(parsed),
    });
  } else if (credPath) {
    const absolute = resolve(process.cwd(), credPath);
    const file = readFileSync(absolute, "utf8");
    const parsed = JSON.parse(file);
    admin.initializeApp({
      credential: admin.credential.cert(parsed),
    });
  }

  initialized = true;
  return admin;
}

export function getAuth() {
  const app = initFirebase();
  if (!app) {
    throw new Error("Firebase not configured");
  }
  return app.auth();
}

export function getFirestore() {
  const app = initFirebase();
  if (!app) {
    throw new Error("Firebase not configured");
  }
  return app.firestore();
}
