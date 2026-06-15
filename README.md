# German Vocabulary Flashcards & Grammar Quiz

Version 1 of a beginner-friendly German learning platform built with:

- Flutter for Android and Web
- Spring Boot REST API
- PostgreSQL
- Local-only progress storage with `shared_preferences`
- AdMob and AdSense placeholder areas using test or placeholder IDs only

## Project Structure

```text
backend/   Spring Boot API + PostgreSQL seed data
frontend/  Flutter app for Android and Web
```

## Features in Version 1

- Vocabulary flashcards by category
- Grammar quizzes by topic from A1 to B1
- Level filters for vocabulary and grammar topics
- Grammar topic search and wrong-answer review
- In-app Privacy Policy and Terms screens
- Daily challenge with vocabulary and grammar
- Favorites
- Local progress tracking with XP and streaks
- Light and dark mode
- No login, no cloud sync, no payments, no admin dashboard

## Backend Setup

Requirements:

- Java 21
- Maven 3.9+
- PostgreSQL 16+ or Docker

### 1. Start PostgreSQL

Option A: local PostgreSQL

- Create a database named `german_learning_app`
- Use username `postgres`
- Use password `postgres`

Option B: Docker Compose

```bash
docker compose up -d postgres
```

Option C: Docker Compose with backend included

```bash
docker compose up --build backend postgres
```

### 2. Backend config

The backend config file is:

- [backend/src/main/resources/application.yml](/Users/dipeshneupane/Downloads/Apps/German Learning App/backend/src/main/resources/application.yml)
- [backend/.env.example](/Users/dipeshneupane/Downloads/Apps/German Learning App/backend/.env.example)

Default values:

- `DB_URL=jdbc:postgresql://localhost:5432/german_learning_app`
- `DB_USERNAME=postgres`
- `DB_PASSWORD=postgres`
- `SERVER_PORT=8080`

### 3. Run backend

```bash
cd backend
mvn spring-boot:run
```

When the app starts, it seeds a bundled deterministic dataset:

- 35 vocabulary categories
- 1300 vocabulary entries covering A1 to B1 core vocabulary
- 30 grammar topics
- 300 grammar questions

Vocabulary data is loaded from:

- [backend/src/main/resources/seed/vocabulary-categories.csv](/Users/dipeshneupane/Downloads/Apps/German Learning App/backend/src/main/resources/seed/vocabulary-categories.csv)
- [backend/src/main/resources/seed/vocabulary-categories-extended.csv](/Users/dipeshneupane/Downloads/Apps/German Learning App/backend/src/main/resources/seed/vocabulary-categories-extended.csv)
- [backend/src/main/resources/seed/vocabulary-items.csv](/Users/dipeshneupane/Downloads/Apps/German Learning App/backend/src/main/resources/seed/vocabulary-items.csv)
- [backend/src/main/resources/seed/vocabulary-items-extended.csv](/Users/dipeshneupane/Downloads/Apps/German Learning App/backend/src/main/resources/seed/vocabulary-items-extended.csv)

This makes the vocabulary seed consistent across local runs and deployments. On startup, the backend inserts missing packaged entries into PostgreSQL, so a fresh deployment gets the same bundled dataset automatically.

### Backend container deployment

The backend now includes:

- [backend/Dockerfile](/Users/dipeshneupane/Downloads/Apps/German Learning App/backend/Dockerfile)
- [backend/.dockerignore](/Users/dipeshneupane/Downloads/Apps/German Learning App/backend/.dockerignore)
- [backend/docker-entrypoint.sh](/Users/dipeshneupane/Downloads/Apps/German Learning App/backend/docker-entrypoint.sh)

You can build and run it locally with:

```bash
cd backend
docker build -t german-learning-backend .
docker run --rm -p 8080:8080 \
  -e DB_URL=jdbc:postgresql://HOST:5432/german_learning_app \
  -e DB_USERNAME=postgres \
  -e DB_PASSWORD=postgres \
  -e CORS_ALLOWED_ORIGINS=http://localhost:3000,https://YOUR_WEB_DOMAIN \
  german-learning-backend
```

Recommended production environment variables:

- `DB_URL`
- `DB_USERNAME`
- `DB_PASSWORD`
- `SERVER_PORT`
- `CORS_ALLOWED_ORIGINS`

Example production values:

- `DB_URL=jdbc:postgresql://YOUR_DB_HOST:5432/german_learning_app`
- `DB_USERNAME=YOUR_DB_USER`
- `DB_PASSWORD=YOUR_DB_PASSWORD`
- `SERVER_PORT=8080`
- `CORS_ALLOWED_ORIGINS=https://YOUR_WEB_DOMAIN`

### Render deployment

The project now includes a Render Blueprint file:

- [render.yaml](/Users/dipeshneupane/Downloads/Apps/German Learning App/render.yaml)

What it sets up:

- one Docker-based Spring Boot web service
- one Docker-based Flutter web frontend service
- one Render Postgres database
- automatic database wiring through Render's `connectionString`
- a health check on `/api/v1/vocab/categories`

Important:

- the included Blueprint uses Render `free` plans to avoid unexpected cost while testing
- free services are fine for early setup, but they are not ideal for a monetized production launch because of resource limits and sleep/cold-start behavior
- before a real public launch, upgrade to a paid plan and set `CORS_ALLOWED_ORIGINS` to your deployed frontend domain

To use it on Render:

1. Push this project to GitHub.
2. In Render, create a new Blueprint instance from the repo.
3. When prompted, set:
   - `API_BASE_URL=https://YOUR_RENDER_BACKEND/api/v1`
   - `CORS_ALLOWED_ORIGINS=https://YOUR_RENDER_FRONTEND`
4. Let Render provision the database, backend, and frontend.
5. After deploy, open:
   - `https://YOUR_RENDER_BACKEND/api/v1/vocab/categories`
   - `https://YOUR_RENDER_FRONTEND`
6. If Render gives your frontend a different URL after the first deploy, update `CORS_ALLOWED_ORIGINS` in the backend service and redeploy it.

### Backend API Endpoints

- `GET /api/v1/vocab/categories`
- `GET /api/v1/vocab/categories/{id}`
- `GET /api/v1/vocab?categoryId={id}`
- `GET /api/v1/vocab/{id}`
- `GET /api/v1/grammar/topics`
- `GET /api/v1/grammar/topics/{id}`
- `GET /api/v1/grammar/questions?topicId={id}`
- `GET /api/v1/grammar/questions/{id}`

## Flutter Setup

Requirements:

- Flutter 3.32+

### Where to change API base URL

Update:

- [frontend/lib/config/app_config.dart](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/lib/config/app_config.dart)

Defaults:

- Android emulator: `http://10.0.2.2:8080/api/v1`
- Web: `http://localhost:8080/api/v1`

You can also override it at run time:

```bash
flutter run --dart-define=API_BASE_URL=http://YOUR_HOST:8080/api/v1
```

### Run Flutter on Android

```bash
cd frontend
flutter pub get
flutter run -d android
```

### Run Flutter on Web

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### Build Flutter Web for deployment

Build a release bundle with your deployed backend URL:

```bash
cd frontend
flutter build web --release \
  --dart-define=API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1
```

Environment example file:

- [frontend/.env.web.example](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/.env.web.example)

If you want Firebase analytics and crash reporting enabled in production, include the Firebase values too:

```bash
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

Deploy the generated static site from:

- [frontend/build/web](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/build/web)

For Netlify-style SPA routing, the project includes:

- [frontend/web/_redirects](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/web/_redirects)

### Production build command template

Use this exact structure when you are ready to build the production web app:

```bash
cd frontend
flutter build web --release \
  --dart-define=API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1 \
  --dart-define=FIREBASE_ENABLED=false
```

If Firebase is live in production, replace `false` and add the Firebase values shown above.

### Render frontend deployment

The frontend now includes:

- [frontend/Dockerfile](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/Dockerfile)
- [frontend/nginx.conf.template](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/nginx.conf.template)
- [frontend/docker-entrypoint.sh](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/docker-entrypoint.sh)
- [frontend/web/config.js](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/web/config.js)

This is the recommended Render deployment path for the Flutter web app because the container builds Flutter and injects `API_BASE_URL` at runtime.

Set this frontend environment variable on Render:

- `API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1`

The frontend reads that runtime value through:

- [frontend/lib/config/app_config.dart](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/lib/config/app_config.dart)

For local Docker testing:

```bash
docker compose up --build frontend backend postgres
```

## Local Progress Keys

The app stores local progress with `shared_preferences` using these keys:

- `learned_vocab_ids`
- `favorite_vocab_ids`
- `quiz_scores_by_topic`
- `grammar_quizzes_completed`
- `total_vocab_learned`
- `average_quiz_score`
- `xp_points`
- `current_streak`
- `last_daily_challenge_date`

No login is required and no cloud sync is used.

## Ads

Ad placeholders use test or placeholder identifiers only.

Where to replace later:

- [frontend/lib/config/app_config.dart](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/lib/config/app_config.dart)
- [frontend/lib/services/ad_service.dart](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/lib/services/ad_service.dart)
- [frontend/lib/widgets/placeholder_ad_banner.dart](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/lib/widgets/placeholder_ad_banner.dart)

Current placeholder setup:

- Mobile banner placeholder
- Mobile interstitial placeholder after quiz completion
- Web placeholder containers for future AdSense placement

## Policy Files

The project now includes launch-ready starter policy documents that you should customize with your real contact and business details before release:

- [PRIVACY_POLICY.md](/Users/dipeshneupane/Downloads/Apps/German Learning App/PRIVACY_POLICY.md)
- [TERMS.md](/Users/dipeshneupane/Downloads/Apps/German Learning App/TERMS.md)

The same content is also available inside the app from Settings:

- `Privacy Policy`
- `Terms of Use`

## Deployment Order

The safest rollout order is:

1. Deploy PostgreSQL
2. Deploy the Spring Boot backend and confirm `/api/v1/vocab/categories` responds
3. Deploy the Docker-based Render frontend and set `API_BASE_URL`
4. Confirm the backend `CORS_ALLOWED_ORIGINS` matches the frontend domain
5. Test live vocabulary, grammar, daily challenge, and local progress storage
6. Turn on Firebase telemetry
7. Replace ad placeholders only after policy pages and platform approval are ready

## Production Handoff

Quick command reference:

- [DEPLOYMENT_COMMANDS.md](/Users/dipeshneupane/Downloads/Apps/German Learning App/DEPLOYMENT_COMMANDS.md)

### Backend

1. Push the repo to GitHub.
2. Deploy PostgreSQL.
3. Deploy the backend using Render Blueprint or your own Docker host.
4. Set:
   - `DATABASE_URL` on Render or `DB_URL` / `DB_USERNAME` / `DB_PASSWORD` elsewhere
   - `CORS_ALLOWED_ORIGINS` to the final frontend domain
5. Verify:
   - `https://YOUR_BACKEND_DOMAIN/api/v1/vocab/categories`
   - `https://YOUR_BACKEND_DOMAIN/api/v1/grammar/topics`

### Web frontend

1. Deploy the Docker-based frontend service from [render.yaml](/Users/dipeshneupane/Downloads/Apps/German Learning App/render.yaml).
2. Set `API_BASE_URL=https://YOUR_BACKEND_DOMAIN/api/v1` on the frontend service.
3. Make sure the backend `CORS_ALLOWED_ORIGINS` includes the deployed frontend domain.
4. Open the deployed site and test:
   - Vocabulary categories
   - Flashcards
   - Grammar topics
   - Quiz results
   - Wrong-answer review
   - Privacy Policy
   - Terms of Use

If you prefer a non-Render static host, you can still build locally and deploy [frontend/build/web](/Users/dipeshneupane/Downloads/Apps/German Learning App/frontend/build/web) to Netlify, Vercel, Firebase Hosting, or another static host.

### Android

1. Replace placeholder branding assets later if needed.
2. Keep test ad IDs until you have real approved ad units.
3. Build and test a release APK or AAB on a physical device before store submission.

## Release Checklist

- Backend deployed with PostgreSQL and correct `CORS_ALLOWED_ORIGINS`
- Frontend deployed with the correct `API_BASE_URL`
- Android tested on a physical device
- Web tested in Chrome
- Privacy Policy page prepared
- Terms page prepared
- Firebase telemetry configured if desired
- Real AdMob IDs added later only after approval
- Real AdSense setup added later only after approval
- Manual QA completed for flashcards, grammar, favorites, progress reset, daily challenge, and dark mode

## Validation

Verified in this workspace:

- `flutter pub get`
- `flutter analyze`

Backend runtime depends on Java, Maven, and PostgreSQL availability in the deployment environment.
