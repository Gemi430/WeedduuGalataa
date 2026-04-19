/// Base URL for the Node/Express API (no trailing slash).
/// Android emulator: use `http://10.0.2.2:3000` instead of localhost.
/// iOS simulator: `http://127.0.0.1:3000` usually works.
/// Production: Use Render deployment URL.
const String kApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://weedduu-galataa-api.onrender.com',
);
