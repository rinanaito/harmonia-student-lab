const functions = require('firebase-functions');
const express = require('express');
const admin = require('firebase-admin');
const { google } = require('googleapis');
const multer = require('multer');
const bcrypt = require('bcryptjs');
const { v4: uuidv4 } = require('uuid');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const os = require('os');

// ── Initialize Firebase Admin ──
admin.initializeApp();
const db = admin.database();

// ── Google Drive Setup ──
const GOOGLE_FOLDER_ID = process.env.GOOGLE_DRIVE_FOLDER_ID || '';
let driveAuth;
try {
  const keyFile = path.join(__dirname, 'google-credentials.json');
  if (fs.existsSync(keyFile)) {
    driveAuth = new google.auth.GoogleAuth({
      keyFile,
      scopes: ['https://www.googleapis.com/auth/drive']
    });
  }
} catch (e) {
  console.warn('Google Drive credentials not configured:', e.message);
}
const drive = driveAuth ? google.drive({ version: 'v3', auth: driveAuth }) : null;

// ── Express App ──
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

const upload = multer({ dest: os.tmpdir(), limits: { fileSize: 50 * 1024 * 1024 } });

// ═══════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════
async function ensureDefaults() {
  const snap = await db.ref('admins').once('value');
  if (!snap.exists()) {
    const hash = await bcrypt.hash('admin123', 10);
    await db.ref('admins/admin').set({ password: hash, role: 'super' });
  }
  const studentsSnap = await db.ref('students').once('value');
  if (!studentsSnap.exists()) {
    await db.ref('students').set({
      'S-1001': { name: 'Emma Johnson', class: 'Grade 3-A', createdAt: Date.now() },
      'S-1002': { name: 'Liam Smith', class: 'Grade 2-B', createdAt: Date.now() },
      'S-1003': { name: 'Aisha Mendez', class: 'Grade 4-A', createdAt: Date.now() }
    });
  }
  const mediaSnap = await db.ref('media').once('value');
  if (!mediaSnap.exists()) {
    await db.ref('media').set({
      [uuidv4()]: { studentIds: ['S-1001'], type: 'photo', title: 'Science Fair Project', date: '2025-03-15', driveFileId: '', thumbUrl: '', createdAt: Date.now() },
      [uuidv4()]: { studentIds: ['S-1001', 'S-1002'], type: 'photo', title: 'Art Class Masterpiece', date: '2025-04-02', driveFileId: '', thumbUrl: '', createdAt: Date.now() },
      [uuidv4()]: { studentIds: ['S-1002'], type: 'photo', title: 'Reading Hour', date: '2025-03-10', driveFileId: '', thumbUrl: '', createdAt: Date.now() },
      [uuidv4()]: { studentIds: ['S-1003'], type: 'photo', title: 'Maths Olympiad', date: '2025-05-20', driveFileId: '', thumbUrl: '', createdAt: Date.now() }
    });
  }
}
ensureDefaults().catch(console.error);

async function uploadToDrive(filePath, fileName, mimeType) {
  if (!drive) throw new Error('Google Drive not configured');
  const res = await drive.files.create({
    requestBody: {
      name: fileName,
      mimeType,
      parents: GOOGLE_FOLDER_ID ? [GOOGLE_FOLDER_ID] : undefined
    },
    media: { mimeType, body: fs.createReadStream(filePath) },
    fields: 'id, webViewLink, webContentLink, thumbnailLink'
  });
  await drive.permissions.create({
    fileId: res.data.id,
    requestBody: { role: 'reader', type: 'anyone' }
  });
  return {
    id: res.data.id,
    webViewLink: res.data.webViewLink,
    directLink: `https://drive.google.com/uc?export=view&id=${res.data.id}`,
    thumbnailLink: res.data.thumbnailLink
  };
}

async function deleteFromDrive(fileId) {
  if (!drive || !fileId) return;
  try { await drive.files.delete({ fileId }); } catch (e) { console.error('Drive delete error:', e); }
}

// ═══════════════════════════════════════════════
//  AUTH
// ═══════════════════════════════════════════════
app.post('/api/auth/parent', async (req, res) => {
  const { query } = req.body;
  if (!query) return res.status(400).json({ error: 'Missing query' });
  const q = query.toLowerCase().trim();
  const snap = await db.ref('students').once('value');
  const students = snap.val() || {};
  const match = Object.entries(students).find(([id, s]) =>
    id.toLowerCase() === q || s.name.toLowerCase() === q
  );
  if (!match) return res.status(404).json({ error: 'Student not found' });
  res.json({ student: { id: match[0], ...match[1] } });
});

app.post('/api/auth/admin', async (req, res) => {
  const { username, password } = req.body;
  const snap = await db.ref(`admins/${username}`).once('value');
  const admin = snap.val();
  if (!admin || !await bcrypt.compare(password, admin.password)) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  res.json({ success: true, token: `admin_${username}_${Date.now()}` });
});

// ═══════════════════════════════════════════════
//  STUDENTS (FULL CRUD)
// ═══════════════════════════════════════════════
app.get('/api/students', async (req, res) => {
  const snap = await db.ref('students').once('value');
  const val = snap.val() || {};
  const list = Object.entries(val).map(([id, s]) => ({ id, ...s }));
  res.json(list);
});

app.post('/api/students', async (req, res) => {
  const { id, name, class: cls } = req.body;
  if (!id || !name) return res.status(400).json({ error: 'ID and name required' });
  const existing = await db.ref(`students/${id}`).once('value');
  if (existing.exists()) return res.status(409).json({ error: 'Student ID exists' });
  await db.ref(`students/${id}`).set({ name, class: cls || '', createdAt: Date.now() });
  res.json({ success: true, student: { id, name, class: cls } });
});

app.patch('/api/students/:id', async (req, res) => {
  const { id } = req.params;
  const { name, class: cls } = req.body;
  const existing = await db.ref(`students/${id}`).once('value');
  if (!existing.exists()) return res.status(404).json({ error: 'Student not found' });
  const updates = {};
  if (name !== undefined) updates.name = name;
  if (cls !== undefined) updates.class = cls;
  await db.ref(`students/${id}`).update(updates);
  res.json({ success: true, student: { id, ...existing.val(), ...updates } });
});

app.delete('/api/students/:id', async (req, res) => {
  const { id } = req.params;
  // Remove student from all media tags
  const mediaSnap = await db.ref('media').once('value');
  const media = mediaSnap.val() || {};
  const updates = {};
  for (const [key, m] of Object.entries(media)) {
    if (m.studentIds && m.studentIds.includes(id)) {
      const newIds = m.studentIds.filter(sid => sid !== id);
      if (newIds.length === 0) {
        // If no students left, delete media entirely
        await deleteFromDrive(m.driveFileId);
        updates[`media/${key}`] = null;
      } else {
        updates[`media/${key}/studentIds`] = newIds;
      }
    }
  }
  updates[`students/${id}`] = null;
  await db.ref().update(updates);
  res.json({ success: true });
});

// ═══════════════════════════════════════════════
//  MEDIA (with multi-student tagging)
// ═══════════════════════════════════════════════
app.get('/api/media', async (req, res) => {
  const { studentId, type } = req.query;
  const snap = await db.ref('media').once('value');
  let list = Object.entries(snap.val() || {}).map(([id, m]) => ({ id, ...m }));
  if (studentId) {
    list = list.filter(m => m.studentIds && m.studentIds.includes(studentId));
  }
  if (type) list = list.filter(m => m.type === type);
  list.sort((a, b) => b.date.localeCompare(a.date));
  const studentsSnap = await db.ref('students').once('value');
  const students = studentsSnap.val() || {};
  list = list.map(m => ({
    ...m,
    studentNames: (m.studentIds || []).map(sid => students[sid]?.name || sid)
  }));
  res.json(list);
});

app.post('/api/media', upload.array('files'), async (req, res) => {
  let { studentIds, date, title } = req.body;
  if (!studentIds) return res.status(400).json({ error: 'studentIds required' });
  if (!date || !title) return res.status(400).json({ error: 'date and title required' });
  // studentIds may come as JSON string or array
  if (typeof studentIds === 'string') {
    try { studentIds = JSON.parse(studentIds); } catch { studentIds = [studentIds]; }
  }
  if (!Array.isArray(studentIds) || studentIds.length === 0) {
    return res.status(400).json({ error: 'studentIds must be a non-empty array' });
  }
  const files = req.files || [];
  const results = [];
  for (const file of files) {
    const isVideo = file.mimetype.startsWith('video');
    let driveInfo = { id: '', directLink: '', thumbnailLink: '' };
    if (drive) {
      try {
        driveInfo = await uploadToDrive(file.path, file.originalname, file.mimetype);
      } catch (e) {
        console.error('Drive upload failed:', e);
      }
    }
    const mediaId = uuidv4();
    const mediaData = {
      studentIds,
      type: isVideo ? 'video' : 'photo',
      title,
      date,
      driveFileId: driveInfo.id,
      url: driveInfo.directLink || '',
      thumbUrl: driveInfo.thumbnailLink || driveInfo.directLink || '',
      createdAt: Date.now()
    };
    await db.ref(`media/${mediaId}`).set(mediaData);
    results.push({ id: mediaId, ...mediaData });
    fs.unlink(file.path, () => {});
  }
  res.json({ success: true, media: results });
});

app.patch('/api/media/:id', async (req, res) => {
  const { id } = req.params;
  const { title, date, studentIds } = req.body;
  const snap = await db.ref(`media/${id}`).once('value');
  if (!snap.exists()) return res.status(404).json({ error: 'Media not found' });
  const updates = {};
  if (title !== undefined) updates.title = title;
  if (date !== undefined) updates.date = date;
  if (studentIds !== undefined) updates.studentIds = studentIds;
  await db.ref(`media/${id}`).update(updates);
  res.json({ success: true });
});

app.delete('/api/media/:id', async (req, res) => {
  const { id } = req.params;
  const snap = await db.ref(`media/${id}`).once('value');
  const item = snap.val();
  if (item?.driveFileId) await deleteFromDrive(item.driveFileId);
  await db.ref(`media/${id}`).remove();
  res.json({ success: true });
});

// ═══════════════════════════════════════════════
//  STATS
// ═══════════════════════════════════════════════
app.get('/api/stats', async (req, res) => {
  const [studentsSnap, mediaSnap] = await Promise.all([
    db.ref('students').once('value'),
    db.ref('media').once('value')
  ]);
  const students = Object.keys(studentsSnap.val() || {}).length;
  const media = Object.values(mediaSnap.val() || {});
  const photos = media.filter(m => m.type === 'photo').length;
  const videos = media.filter(m => m.type === 'video').length;
  res.json({ students, photos, videos, total: media.length });
});

// Export for Firebase Functions
exports.api = functions.https.onRequest(app);

// Local dev fallback
if (process.env.NODE_ENV !== 'production') {
  const PORT = process.env.PORT || 3000;
  app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
}
