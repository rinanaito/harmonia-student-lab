# 🎵 Harmonia — Language Lab Student Media Gallery

A full-stack **Flutter Web** application for language labs and schools to share student photos and videos with parents. Built with Flutter 3.x, deployed to Firebase Hosting, backed by Firebase Realtime Database and Google Drive file storage.

## What's New in This Version

- **Multi-Student Tagging**: One photo/video can be tagged with multiple students
- **Edit Tags**: Update which students are tagged on already-uploaded media
- **Full Student CRUD**: Create, Read, Update, Delete students
- **Harmonia Branding**: Custom logo and deep blue color scheme

## Architecture

| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter Web (Dart) |
| **Backend** | Node.js + Express (Firebase Cloud Function) |
| **Database** | Firebase Realtime Database |
| **File Storage** | Google Drive API (Service Account) |
| **Hosting** | Firebase Hosting |
| **State Mgmt** | Provider (`ChangeNotifier`) |

## Project Structure

```
harmonia-language-lab/
├── lib/
│   ├── main.dart                 # App entry + auth router
│   ├── models/
│   │   ├── student.dart          # Student data model
│   │   └── media_item.dart       # Media data model (multi-student tags)
│   ├── services/
│   │   ├── api_service.dart      # HTTP client (CRUD + upload + edit tags)
│   │   └── app_state.dart        # Auth state
│   ├── screens/
│   │   ├── login_screen.dart     # Harmonia branded login
│   │   ├── gallery_screen.dart   # Parent gallery (filters by studentIds)
│   │   ├── lightbox_screen.dart  # Fullscreen viewer
│   │   └── admin_screen.dart     # Dashboard, Upload, Students, Media
│   └── theme/
│       └── app_theme.dart        # Deep blue Harmonia palette
├── web/index.html                # Bootstrap with loading spinner
├── functions/                    # Backend API
│   ├── index.js                  # Express server (multi-student support)
│   ├── package.json
│   └── .env.example
├── assets/images/logo.png        # Harmonia logo
├── firebase.json                 # Hosting + Functions + Database
└── database.rules.json
```

## Prerequisites

1. **Flutter SDK 3.19+** with web support
2. **Node.js 20+** and npm
3. **Firebase CLI**: `npm install -g firebase-tools`
4. A **Firebase project** with Blaze plan (required for Cloud Functions)
5. A **Google Cloud project** with Drive API enabled

## Setup Guide

### 1. Install Flutter Dependencies

```bash
cd harmonia-language-lab
flutter pub get
```

### 2. Configure Backend (Google Drive)

1. Enable **Google Drive API** in Google Cloud Console
2. Create a **Service Account**, download its JSON key
3. Rename key to `google-credentials.json` and place in `functions/`
4. Create a Drive folder, share it with the service account email (as **Editor**)
5. Copy folder ID and create `functions/.env`:
   ```
   GOOGLE_DRIVE_FOLDER_ID=1ABC123xyz...
   ```

### 3. Local Development

```bash
# Terminal 1 — Backend
cd functions && npm install && npm start
# Runs at http://localhost:3000

# Terminal 2 — Flutter Web
flutter run -d chrome
```

### 4. Build & Deploy

```bash
flutter build web --release
firebase login
firebase deploy
```

Live at: `https://your-project-id.web.app`

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/parent` | Login by student name/ID |
| POST | `/api/auth/admin` | Admin login |
| GET | `/api/students` | List all students |
| POST | `/api/students` | Add new student |
| PATCH | `/api/students/:id` | **Update student** (name/class) |
| DELETE | `/api/students/:id` | Remove student + clean up tags |
| GET | `/api/media` | List media (filter by studentId or type) |
| POST | `/api/media` | Upload files + tag multiple students |
| PATCH | `/api/media/:id` | **Edit tags/title/date** on existing media |
| DELETE | `/api/media/:id` | Delete media from Drive + DB |
| GET | `/api/stats` | Dashboard statistics |

## Key Features

### Multi-Student Tagging
When uploading media, select **multiple students** via filter chips. The media will appear in each tagged student's gallery.

### Edit Tags
In the **All Media** admin panel, click **"Edit Tags"** on any item to reassign which students are tagged — without re-uploading the file.

### Full Student CRUD
- **Create**: Add new students with ID, name, and class
- **Read**: View all students with media count
- **Update**: Edit name or class inline
- **Delete**: Remove student — automatically removes them from all media tags (deletes media only if no students remain)

## Default Credentials

| Role | Login | Password |
|------|-------|----------|
| **Admin** | `admin` | `admin123` |
| **Parent** | Any student name or ID | — |

> ⚠️ **Change the admin password immediately** after first deployment.

## Database Schema

```json
{
  "students": {
    "S-1001": { "name": "Emma Johnson", "class": "Grade 3-A", "createdAt": 1718300000000 }
  },
  "media": {
    "uuid-123": {
      "studentIds": ["S-1001", "S-1002"],
      "type": "photo",
      "title": "Group Project",
      "date": "2025-03-15",
      "driveFileId": "1drive...",
      "url": "https://drive.google.com/uc?export=view&id=...",
      "thumbUrl": "...",
      "createdAt": 1718300000000
    }
  },
  "admins": {
    "admin": { "password": "<bcrypt-hash>", "role": "super" }
  }
}
```

## Security Notes

1. **Database Rules**: Currently open for demo. Lock down for production.
2. **Drive Files**: Uploaded with `anyone` reader permission. For stricter access, proxy through backend.
3. **CORS**: Open in development. Restrict to your Firebase Hosting domain in production.

## License

MIT — free for school and personal use.
