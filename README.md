# ShopEzee

A Flutter shopping app demo that uses Firebase and Google Maps/Places APIs.

## Features

- Firebase authentication
- Firestore database
- Firebase storage
- Google Maps and Places autocomplete
- Product browsing, cart, and order checkout

## Setup

1. Install Flutter SDK and required tools.
2. Open the project in VS Code or Android Studio.
3. Copy `.env.example` to `.env`.
   - `copy .env.example .env`
4. Replace the placeholder values in `.env` with your own API keys.

## Environment variables

The app loads API keys from `.env` using `flutter_dotenv`.

- `GOOGLE_API_KEY`
- `FIREBASE_API_KEY_WEB`
- `FIREBASE_API_KEY_ANDROID`
- `FIREBASE_API_KEY_IOS`
- `FIREBASE_API_KEY_MACOS`
- `FIREBASE_API_KEY_WINDOWS`

## Run

```bash
flutter pub get
flutter run
```

## Notes

- Do not commit `.env`.
- Commit `.env.example` instead.
- `android/app/google-services.json` is ignored in this repo to keep Firebase config private.
