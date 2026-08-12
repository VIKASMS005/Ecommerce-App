# ShopEzee

A Flutter shopping app built with Firebase and Google Maps/Places APIs — product browsing, cart, checkout, order history, and address selection via map/autocomplete.

## Tech stack

 - Flutter (state management via provider)
 - Firebase Authentication — email/password login
 - Firebase Realtime Database — products, orders, and saved addresses
 - Cloud Firestore — map/location data (GeoPoint for address picking)
 - Firebase Storage — product images (camera/gallery upload)
 - Google Maps & Places API — address autocomplete and map picking

## Features

 - Firebase authentication
 - Product browsing, cart, and order checkout
 - Order history with expandable order details
 - Saved delivery addresses with map-based selection
 - Product image upload via device camera or gallery
 - Google Places autocomplete for address search
   
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

## Environment setup (recommended)

1. Copy `.env.example` to `.env` in the project root:

```powershell
copy .env.example .env
```

2. Fill in the keys in `.env` using values from your Firebase console and Google Cloud.

3. Keep `.env` and `android/app/google-services.json` private — they are ignored by git.
