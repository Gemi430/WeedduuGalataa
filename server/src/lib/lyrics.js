export const LYRIC_SECTION_TYPES = [
  "INTRO",
  "VERSE",
  "CHORUS",
  "PRE_CHORUS",
  "BRIDGE",
  "OUTRO",
];

export function isValidLyricPayload(payload) {
  if (!payload || typeof payload !== "object") return false;
  if (!Array.isArray(payload.sections)) return false;

  for (const s of payload.sections) {
    if (!s || typeof s !== "object") return false;
    if (!LYRIC_SECTION_TYPES.includes(s.type)) return false;
    if (!Array.isArray(s.lines)) return false;
    if (s.lines.some((line) => typeof line !== "string")) return false;
  }

  return true;
}

