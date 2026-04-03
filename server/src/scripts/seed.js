import admin from 'firebase-admin';
import dotenv from 'dotenv';
import { readFileSync } from 'fs';

dotenv.config();

const credentialsPath = process.env.GOOGLE_APPLICATION_CREDENTIALS || './serviceAccountKey.json';
const serviceAccount = JSON.parse(readFileSync(credentialsPath, 'utf8'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const sampleSongs = [
  {
    title: "Waa Boqonnaa",
    lyrics: `Waa Boqonnaa isa nutiif
Himmatni keenyatti dhihaa
Yesus waa qalbii keenyatti
Himmatni isaa dhihaa

Waa Boqonnaa isa nutiif
Nama dhoksaa ta'e
Yesus waa raga keenyatti
Nama dhoksaa ta'e`,
    scale: "1st",
    style: "Waltz",
    isSingle: true,
  },
  {
    title: "Namoonni Isaa",
    lyrics: `Namoonni isaa hiriyaa kiyya
Yeroo ammaa gammadde
Waa qalbii kiyya jiraachuuf
Raga kiyyaa kaa'e

Namoonni isaa hiriyaa kiyya
Yeroo ammaa gammadde`,
    scale: "1st",
    style: "Slow Rock",
    isSingle: false,
  },
  {
    title: "Eela Eela",
    lyrics: `Eela eela waa jaalala
Jaalala isa nutiif
Eela eela waa qalbii
Qalbii isa nutiif

Eela eela waa raga
Raga isa nutiif`,
    scale: "2nd",
    style: "Reggae",
    isSingle: true,
  },
  {
    title: "Magaalaa Finfinnee",
    lyrics: `Magaalaa Finfinnee kiyya
Nuti gammadde yeroo ammaa
Yesus waa qalbii keenyatti
Nuti jiraachuuf dhihaa

Magaalaa Finfinnee kiyya
Nuti gammadde yeroo ammaa`,
    scale: "2nd",
    style: "Chikchika",
    isSingle: false,
  },
  {
    title: "Himmatni Waa",
    lyrics: `Himmatni waa isa nutiif
Yeroo ammaa dhihaa
Yesus waa raga keenyatti
Nuti gammadde yeroo ammaa

Himmatni waa isa nutiif
Nama dhoksaa ta'e`,
    scale: "5th",
    style: "Wallo",
    isSingle: true,
  },
  {
    title: "Qalbii Kiyya",
    lyrics: `Qalbii kiyya jaalala isaa
Yeroo ammaa jiraachuuf
Yesus waa namoota keenyatti
Namoota dhoksaa ta'e

Qalbii kiyya jaalala isaa
Yeroo ammaa jiraachuuf`,
    scale: "5th",
    style: "Disco",
    isSingle: false,
  },
  {
    title: "Raga Kiyya",
    lyrics: `Raga kiyya isa nutiif
Himmatni keenyatti dhihaa
Yesus waa namoota dhoksaa
Namoota keenyatti jiraachuuf

Raga kiyya isa nutiif
Himmatni keenyatti dhihaa`,
    scale: "6th",
    style: "Waltz",
    isSingle: true,
  },
  {
    title: "Jaalala Isa",
    lyrics: `Jaalala isa nutiif
Waa qalbii keenyatti
Yesus waa himmatni keenyatti
Himmatni isaa dhihaa

Jaalala isa nutiif
Waa raga keenyatti`,
    scale: "6th",
    style: "Slow Rock",
    isSingle: false,
  },
];

const sampleAlbums = [
  {
    title: "Jaalala Waa",
    coverImageUrl: null,
    songIds: [],
  },
  {
    title: "Himmatni Qalbii",
    coverImageUrl: null,
    songIds: [],
  },
];

async function seedData() {
  console.log("Seeding sample data...\n");

  // Add songs
  console.log("Adding songs...");
  const songIds = [];
  for (const song of sampleSongs) {
    const docRef = await db.collection('songs').add(song);
    songIds.push(docRef.id);
    console.log(`  ✓ Added: ${song.title}`);
  }

  // Add albums with song references
  console.log("\nAdding albums...");
  sampleAlbums[0].songIds = songIds.slice(0, 4);
  sampleAlbums[1].songIds = songIds.slice(4);

  for (const album of sampleAlbums) {
    await db.collection('albums').add(album);
    console.log(`  ✓ Added: ${album.title}`);
  }

  console.log("\n✅ Seed completed successfully!");
  console.log(`   - ${songIds.length} songs added`);
  console.log(`   - ${sampleAlbums.length} albums added`);
}

seedData().catch(console.error);