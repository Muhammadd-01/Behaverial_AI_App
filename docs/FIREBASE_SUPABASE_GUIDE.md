# Firebase + Supabase Storage — Complete Setup Guide

This guide walks you through setting up Firebase (Auth + Firestore) and Supabase (Storage Buckets) for the Positive Attitude Creator app.

---

## Part 1: Firebase Project Setup

### Step 1: Create Firebase Project
1. Go to **[console.firebase.google.com](https://console.firebase.google.com)**
2. Click **"Add project"**
3. Name: `positive-attitude-creator`
4. Disable Google Analytics (optional) → **Create Project**

### Step 2: Add Flutter Apps

#### Android
1. Click **Android icon** on the project overview
2. Package name: `com.positiveai.positive_attitude_creator`
   - Find yours in `android/app/build.gradle` → `applicationId`
3. App nickname: `Positive Attitude Creator (Android)`
4. SHA-1 (needed for Google Sign-In):
   ```bash
   cd android && ./gradlew signingReport
   ```
   Copy the `SHA1` from the `debug` variant.
5. Click **Register App**
6. Download `google-services.json`
7. Place it in: `android/app/google-services.json`

#### iOS
1. Click **Add app → iOS**
2. Bundle ID: `com.positiveai.positiveAttitudeCreator`
   - Find yours in `ios/Runner.xcodeproj/project.pbxproj` → `PRODUCT_BUNDLE_IDENTIFIER`
3. Click **Register App**
4. Download `GoogleService-Info.plist`
5. Open Xcode → drag-drop into `ios/Runner/` (make sure "Copy items if needed" is checked)

### Step 3: Enable Firebase Auth

1. In Firebase Console → **Build → Authentication → Get Started**
2. **Sign-in method** tab:
   - Enable **Email/Password** → Toggle ON → Save
   - Enable **Google** → Toggle ON
     - Set project support email → Save

### Step 4: Create Firestore Database

1. **Build → Firestore Database → Create database**
2. Choose **Start in production mode**
3. Select the **closest region** (e.g., `asia-south1` for Pakistan)
4. Click **Create**
5. Go to **Rules** tab → paste the rules from [`firebase/firestore_schema.md`](file:///Users/muhammadaffan/Coding/Behaverial_Ai_App/firebase/firestore_schema.md) → **Publish**

### Step 5: Install FlutterFire CLI

```bash
# Install the CLI globally
dart pub global activate flutterfire_cli

# From your project root, configure Firebase
cd /Users/muhammadaffan/Coding/Behaverial_Ai_App
flutterfire configure
```

This auto-generates `lib/firebase_options.dart` with your project config.

---

## Part 2: Supabase Storage Setup

### Step 1: Create Supabase Project

1. Go to **[supabase.com](https://supabase.com)** → Sign up / Log in
2. Click **New Project**
3. Name: `positive-attitude-storage`
4. Database Password: (save this securely)
5. Region: Choose closest to your users
6. Click **Create new project** (wait ~2 minutes)

### Step 2: Get API Keys

1. Go to **Settings → API**
2. Note down these values:
   - **Project URL**: `https://YOUR_PROJECT_ID.supabase.co`
   - **anon (public) key**: `eyJhbG...` (safe to use in client apps)
   - **service_role key**: `eyJhbG...` (NEVER expose in client — server only)

### Step 3: Create Storage Buckets

Go to **Storage** in the Supabase dashboard.

#### Bucket 1: `profile-images` (Profile Pictures)
1. Click **New Bucket**
2. Name: `profile-images`
3. **Public bucket**: ✅ ON (profile images are publicly accessible via URL)
4. File size limit: `5MB`
5. Allowed MIME types: `image/jpeg, image/png, image/webp`
6. Click **Create bucket**

#### Bucket 2: `journal-attachments` (Journal Entry Images)
1. Click **New Bucket**
2. Name: `journal-attachments`
3. **Public bucket**: ✅ ON
4. File size limit: `10MB`
5. Allowed MIME types: `image/jpeg, image/png, image/webp, image/gif`
6. Click **Create bucket**

### Step 4: Set Storage Policies (RLS)

Go to **Storage → Policies** for each bucket.

> [!IMPORTANT]
> Supabase Storage uses Row Level Security (RLS) policies on the `storage.objects` table. Each policy controls who can SELECT (read), INSERT (upload), UPDATE, or DELETE files.

#### Policy Plan

We use a **folder-per-user** pattern: each user uploads to a folder named after their Firebase UID.

```
profile-images/
  ├── user_abc123/
  │   └── avatar.jpg
  └── user_def456/
      └── avatar.png

journal-attachments/
  ├── user_abc123/
  │   ├── entry_001.jpg
  │   └── entry_002.png
  └── user_def456/
      └── entry_001.jpg
```

#### SQL Policies (run in Supabase SQL Editor)

Go to **SQL Editor** → New query → paste and run each block:

```sql
-- ═══════════════════════════════════════════
-- POLICY: Anyone can READ public bucket files
-- (needed because images are displayed in the app)
-- ═══════════════════════════════════════════

-- profile-images: public read
CREATE POLICY "Public read for profile-images"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-images');

-- journal-attachments: public read
CREATE POLICY "Public read for journal-attachments"
ON storage.objects FOR SELECT
USING (bucket_id = 'journal-attachments');
```

```sql
-- ═══════════════════════════════════════════
-- POLICY: Authenticated users can UPLOAD to their own folder
-- The folder name must match their auth UID
-- ═══════════════════════════════════════════

-- profile-images: upload to own folder
CREATE POLICY "Users upload own profile images"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile-images'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- journal-attachments: upload to own folder
CREATE POLICY "Users upload own journal attachments"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'journal-attachments'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

```sql
-- ═══════════════════════════════════════════
-- POLICY: Users can UPDATE (overwrite) their own files
-- ═══════════════════════════════════════════

CREATE POLICY "Users update own profile images"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profile-images'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users update own journal attachments"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'journal-attachments'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

```sql
-- ═══════════════════════════════════════════
-- POLICY: Users can DELETE their own files only
-- ═══════════════════════════════════════════

CREATE POLICY "Users delete own profile images"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'profile-images'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY "Users delete own journal attachments"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'journal-attachments'
  AND auth.role() = 'authenticated'
  AND (storage.foldername(name))[1] = auth.uid()::text
);
```

#### Policies Summary

| Action | Who | Condition |
|--------|-----|-----------|
| **SELECT** (read/view) | Anyone | Public bucket |
| **INSERT** (upload) | Authenticated user | Folder name = their UID |
| **UPDATE** (overwrite) | Authenticated user | Folder name = their UID |
| **DELETE** (remove) | Authenticated user | Folder name = their UID |

> [!CAUTION]
> **Never** use the `service_role` key in client-side Flutter code. The `anon` key is safe because RLS policies protect data access.

---

## Part 3: Linking Supabase ↔ Firebase Auth

Since your primary auth is **Firebase Auth** (not Supabase Auth), you have two approaches:

### Recommended: Use Supabase Auth with custom JWT

Since your users authenticate with Firebase, you can create a **Supabase JWT** from your Firebase token on your FastAPI backend, or use the simpler approach below.

### Simpler Approach: Use Supabase anon key + folder naming

For this app, the storage is **public buckets** with folder-per-user organization. This means:
- Files are **publicly readable** via URL (displayed in your app UI)
- Uploads are done **server-side** via FastAPI using the `service_role` key
- The Flutter app just sends images to FastAPI → FastAPI uploads to Supabase → returns the public URL → Flutter saves the URL in Firestore

This is the **most secure** approach because:
- The `service_role` key stays on your server only
- No Supabase credentials in the Flutter app
- All image URLs are just CDN links stored in Firestore

---

## Part 3 (continued): Data Flow

```
User takes photo → Flutter sends image to FastAPI
                                    ↓
                    FastAPI uploads to Supabase Storage
                                    ↓
                    Gets public URL back from Supabase
                                    ↓
                    Returns URL to Flutter
                                    ↓
            Flutter stores URL in Firestore (photoUrl / imageUrl field)
                                    ↓
               All screens read the URL from Firestore and display it
```

---

## Part 4: Environment Config

Create a `.env` file in your `backend/` directory (**never commit this**):

```env
# Firebase (for token verification)
FIREBASE_PROJECT_ID=positive-attitude-creator

# Supabase
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_SERVICE_KEY=eyJhbG...your_service_role_key...
SUPABASE_ANON_KEY=eyJhbG...your_anon_key...
```

Add to `.gitignore`:
```
backend/.env
```
