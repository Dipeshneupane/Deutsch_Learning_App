# Deployment Commands

Use these commands as a practical launch checklist for Deutsch Starter.

## 1. Backend local Docker test

```bash
cd backend
docker build -t german-learning-backend .
docker run --rm -p 8080:8080 \
  -e DB_URL=jdbc:postgresql://HOST:5432/german_learning_app \
  -e DB_USERNAME=YOUR_DB_USER \
  -e DB_PASSWORD=YOUR_DB_PASSWORD \
  -e CORS_ALLOWED_ORIGINS=https://YOUR_WEB_DOMAIN \
  german-learning-backend
```

## 2. Render backend setup

1. Push the project to GitHub.
2. In Render, create a new Blueprint from the repository using [render.yaml](/Users/dipeshneupane/Downloads/Apps/German Learning App/render.yaml).
3. Set `CORS_ALLOWED_ORIGINS` to your final frontend domain.
4. Wait for the database and API service to finish deploying.

Verify:

```bash
curl https://YOUR_BACKEND_DOMAIN/api/v1/vocab/categories
curl https://YOUR_BACKEND_DOMAIN/api/v1/grammar/topics
```

## 3. Flutter web production build

Without Firebase telemetry:

```bash
cd frontend
flutter build web --release \
  --dart-define=API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1 \
  --dart-define=FIREBASE_ENABLED=false
```

With Firebase telemetry:

```bash
cd frontend
flutter build web --release \
  --dart-define=API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1 \
  --dart-define=FIREBASE_ENABLED=true \
  --dart-define=FIREBASE_API_KEY=YOUR_VALUE \
  --dart-define=FIREBASE_APP_ID=YOUR_VALUE \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=YOUR_VALUE \
  --dart-define=FIREBASE_PROJECT_ID=YOUR_VALUE \
  --dart-define=FIREBASE_STORAGE_BUCKET=YOUR_VALUE \
  --dart-define=FIREBASE_MEASUREMENT_ID=YOUR_VALUE \
  --dart-define=FIREBASE_AUTH_DOMAIN=YOUR_VALUE
```

Deploy the static output from:

- [frontend/build/web](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/build/web)

## 4. Android local release build

```bash
cd frontend
flutter build apk --release \
  --dart-define=API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1
```

If you prefer App Bundle for Play Store:

```bash
cd frontend
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1
```

## 5. Live smoke test checklist

After deployment, verify:

- Home screen loads
- Vocabulary categories open
- Flashcards load from the live backend
- Grammar topics load
- B1 grammar topics appear
- Wrong-answer review works
- Privacy Policy opens
- Terms of Use opens
- Local progress survives refresh on web
