# System Architecture — AI-Based Positive Attitude Creator

## Overview
```
┌──────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter App  │────▶│  Firebase         │────▶│  Firestore DB   │
│  (Dart/UI)    │     │  (Auth + Storage) │     │  (User Data)    │
└──────┬───────┘     └──────────────────┘     └─────────────────┘
       │
       │ HTTP/REST
       ▼
┌──────────────┐     ┌──────────────────┐
│  FastAPI      │────▶│  NLP Engine       │
│  (Python)     │     │  (Sentiment/Tone) │
└──────────────┘     └──────────────────┘
```

## Data Flow
1. User records voice or writes journal → Flutter captures text
2. Text sent to FastAPI `/analyze` endpoint
3. NLP engine processes: sentiment, tone, positivity score
4. Results returned to Flutter → displayed on dashboard
5. User data stored in Firestore (optional)
6. Smart feedback generated based on analysis

## Clean Architecture (Flutter)
```
lib/
├── main.dart                    # App entry point
├── core/                        # Shared across features
│   ├── theme/                   # Colors, typography, ThemeData
│   ├── models/                  # Data models
│   ├── services/                # API, dummy data
│   ├── providers/               # Riverpod state management
│   └── widgets/                 # Reusable shared widgets
└── features/                    # Feature modules
    ├── splash/screens/          # Splash screen
    ├── onboarding/screens/      # 3-page onboarding
    ├── auth/screens/            # Login/Signup
    ├── dashboard/screens/       # Home + MainShell (nav)
    ├── record/screens/          # Voice + Journal input
    ├── report/screens/          # Analysis report
    ├── insights/screens/        # Charts + gamification
    └── settings/
        ├── screens/             # Settings page
        └── widgets/             # Chatbot sheet
```

## Key Technologies
| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | Flutter + Dart | Cross-platform mobile UI |
| State | Riverpod | Reactive state management |
| Charts | fl_chart | Line + Bar data visualization |
| Backend | FastAPI (Python) | REST API for NLP processing |
| Auth | Firebase Auth | Email + Google sign-in |
| Database | Cloud Firestore | User data persistence |
| NLP | Keyword-based + expandable | Sentiment & tone analysis |
