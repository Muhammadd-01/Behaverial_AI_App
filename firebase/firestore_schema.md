# Firestore Collections Schema + Security Rules

---

## Collections

### `users`
| Field | Type | Description |
|-------|------|-------------|
| `uid` | string | Firebase Auth UID (also the document ID) |
| `email` | string | User email |
| `displayName` | string | User display name |
| `photoUrl` | string | **Supabase Storage URL** — profile picture |
| `isPremium` | boolean | Premium subscription status |
| `streak` | number | Current day streak |
| `level` | number | Gamification level |
| `totalPoints` | number | Total XP points |
| `createdAt` | timestamp | Account creation date |
| `lastActiveAt` | timestamp | Last activity timestamp |

### `analyses`
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Auto-generated UUID (document ID) |
| `userId` | string | Firebase Auth UID of the owner |
| `inputText` | string | User's text input |
| `inputType` | string | `'voice'`, `'journal'`, or `'mood'` |
| `positivityScore` | number | 0–100 score |
| `sentiment` | string | `'positive'`, `'neutral'`, `'negative'` |
| `tone` | string | `'calm'`, `'stress'`, `'anger'`, `'motivation'`, `'joy'`, `'sadness'` |
| `keywords` | array\<string\> | Detected keywords |
| `imageUrl` | string | **Supabase Storage URL** — optional attached image |
| `analyzedAt` | timestamp | Analysis timestamp |

### `daily_reports`
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Auto-generated (document ID) |
| `userId` | string | Firebase Auth UID of the owner |
| `date` | timestamp | Report date |
| `averageScore` | number | Average daily positivity score |
| `dominantSentiment` | string | Most frequent sentiment |
| `dominantTone` | string | Most frequent tone |
| `entriesCount` | number | Number of entries that day |
| `suggestions` | array\<string\> | AI-generated suggestions |

### `streaks`
| Field | Type | Description |
|-------|------|-------------|
| `userId` | string | Firebase Auth UID (document ID) |
| `currentStreak` | number | Current streak count |
| `longestStreak` | number | All-time longest streak |
| `lastEntryDate` | timestamp | Date of last entry |

---

## Firestore Security Rules (Production-Ready)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ══════════════════════════════════════════
    // HELPER FUNCTIONS
    // ══════════════════════════════════════════

    // Check if the user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }

    // Check if the authenticated user owns this document
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // Check if the request data has all required fields
    function hasRequiredFields(fields) {
      return request.resource.data.keys().hasAll(fields);
    }

    // Validate string field is not empty and within max length
    function isValidString(field, maxLen) {
      return request.resource.data[field] is string
          && request.resource.data[field].size() > 0
          && request.resource.data[field].size() <= maxLen;
    }

    // Validate number is within a range
    function isInRange(field, min, max) {
      return request.resource.data[field] is number
          && request.resource.data[field] >= min
          && request.resource.data[field] <= max;
    }

    // ══════════════════════════════════════════
    // USERS COLLECTION
    // ══════════════════════════════════════════
    match /users/{userId} {
      // Users can only read their own profile
      allow read: if isOwner(userId);

      // Users can create their own profile (document ID must match auth UID)
      allow create: if isOwner(userId)
                    && hasRequiredFields(['uid', 'email', 'displayName', 'createdAt'])
                    && request.resource.data.uid == userId
                    && isValidString('email', 320)
                    && isValidString('displayName', 100);

      // Users can update their own profile, but cannot change uid or email
      allow update: if isOwner(userId)
                    && request.resource.data.uid == resource.data.uid
                    && request.resource.data.email == resource.data.email
                    && request.resource.data.createdAt == resource.data.createdAt;

      // Users can delete their own profile (GDPR / data deletion)
      allow delete: if isOwner(userId);
    }

    // ══════════════════════════════════════════
    // ANALYSES COLLECTION
    // ══════════════════════════════════════════
    match /analyses/{analysisId} {
      // Users can only read their own analyses
      allow read: if isAuthenticated()
                  && resource.data.userId == request.auth.uid;

      // Users can create analyses linked to themselves
      allow create: if isAuthenticated()
                    && request.resource.data.userId == request.auth.uid
                    && hasRequiredFields(['userId', 'inputText', 'inputType', 'positivityScore', 'sentiment', 'tone', 'analyzedAt'])
                    && isValidString('inputText', 5000)
                    && isInRange('positivityScore', 0, 100)
                    && request.resource.data.sentiment in ['positive', 'neutral', 'negative']
                    && request.resource.data.inputType in ['voice', 'journal', 'mood'];

      // Users cannot update analyses (immutable records)
      allow update: if false;

      // Users can delete their own analyses
      allow delete: if isAuthenticated()
                    && resource.data.userId == request.auth.uid;
    }

    // ══════════════════════════════════════════
    // DAILY REPORTS COLLECTION
    // ══════════════════════════════════════════
    match /daily_reports/{reportId} {
      allow read: if isAuthenticated()
                  && resource.data.userId == request.auth.uid;

      allow create: if isAuthenticated()
                    && request.resource.data.userId == request.auth.uid
                    && hasRequiredFields(['userId', 'date', 'averageScore', 'dominantSentiment', 'dominantTone'])
                    && isInRange('averageScore', 0, 100);

      allow update: if isAuthenticated()
                    && resource.data.userId == request.auth.uid
                    && request.resource.data.userId == resource.data.userId;

      allow delete: if isAuthenticated()
                    && resource.data.userId == request.auth.uid;
    }

    // ══════════════════════════════════════════
    // STREAKS COLLECTION (document ID = userId)
    // ══════════════════════════════════════════
    match /streaks/{userId} {
      allow read: if isOwner(userId);

      allow create: if isOwner(userId)
                    && request.resource.data.userId == userId;

      allow update: if isOwner(userId)
                    && request.resource.data.userId == userId;

      allow delete: if isOwner(userId);
    }

    // ══════════════════════════════════════════
    // DENY ALL OTHER ACCESS BY DEFAULT
    // ══════════════════════════════════════════
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Rules Summary

| Collection | Read | Create | Update | Delete |
|-----------|------|--------|--------|--------|
| `users` | Own only | Own only (validated) | Own only (immutable uid/email) | Own only |
| `analyses` | Own only | Own only (validated) | **Denied** (immutable) | Own only |
| `daily_reports` | Own only | Own only (validated) | Own only | Own only |
| `streaks` | Own only | Own only | Own only | Own only |
| Everything else | **Denied** | **Denied** | **Denied** | **Denied** |
