# Deployment Guide — AI-Based Positive Attitude Creator

## Flutter App Deployment

### Android (Play Store)
```bash
# Build release APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### iOS (App Store)
```bash
flutter build ios --release
```
Then open `ios/Runner.xcworkspace` in Xcode and archive for distribution.

---

## FastAPI Backend Deployment

### Option 1: Railway / Render (Recommended)
1. Push `backend/` folder to a Git repo
2. Connect to Railway or Render
3. Set start command: `uvicorn main:app --host 0.0.0.0 --port $PORT`

### Option 2: Docker
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```
```bash
docker build -t positive-api .
docker run -p 8000:8000 positive-api
```

### Option 3: Google Cloud Run
```bash
gcloud run deploy positive-api \
  --source ./backend \
  --port 8000 \
  --allow-unauthenticated
```

---

## Post-Deployment
1. Update `_baseUrl` in `api_service.dart` to your deployed API URL
2. Rebuild Flutter app with the new URL
3. Test all endpoints from the mobile app
