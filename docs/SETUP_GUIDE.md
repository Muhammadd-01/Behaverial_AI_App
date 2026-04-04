# Setup Guide — AI-Based Positive Attitude Creator

## Prerequisites
- Flutter SDK 3.x+ ([install](https://docs.flutter.dev/get-started/install))
- Python 3.8+ 
- Firebase account ([console](https://console.firebase.google.com))
- Android Studio or Xcode for emulators

---

## 1. Flutter App Setup

```bash
# Clone and enter the project
cd Behaverial_Ai_App

# Install dependencies
flutter pub get

# Run on a connected device/emulator
flutter run
```

### Firebase Setup (Optional for full features)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android app → download `google-services.json` → place in `android/app/`
3. Add iOS app → download `GoogleService-Info.plist` → place in `ios/Runner/`
4. Enable **Email/Password** and **Google** sign-in in Firebase Auth
5. Create a Firestore database → set rules from `firebase/firestore_schema.md`
6. Install FlutterFire CLI and configure:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

> **Note:** The app works fully WITHOUT Firebase using simulated auth and dummy data.

---

## 2. FastAPI Backend Setup

```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# OR: venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Run the server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

API will be available at `http://localhost:8000`
- Docs: `http://localhost:8000/docs` (Swagger UI)
- Health: `http://localhost:8000/`

### Test the API
```bash
# Test analyze endpoint
curl -X POST http://localhost:8000/analyze \
  -H "Content-Type: application/json" \
  -d '{"text": "I feel grateful and happy today", "user_id": "test", "input_type": "journal"}'

# Test chatbot
curl -X POST http://localhost:8000/chatbot \
  -H "Content-Type: application/json" \
  -d '{"message": "I am feeling stressed"}'
```

---

## 3. Connect Flutter to Backend

In `lib/core/services/api_service.dart`, update the base URL:
```dart
static const String _baseUrl = 'http://YOUR_IP:8000';
```

For Android emulator use `10.0.2.2:8000`, for iOS simulator use `localhost:8000`.

---

## 4. Run Everything

1. Start FastAPI: `cd backend && uvicorn main:app --reload`
2. Start Flutter: `flutter run`
3. Navigate: Splash → Onboarding → Login → Dashboard → Record → Analyze!
