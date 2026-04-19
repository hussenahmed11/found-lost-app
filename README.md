# Haramaya University Lost & Found App 🎓📱

Welcome to the **Haramaya University Lost & Found** app! This is a modern, cross-platform mobile application built with Flutter & Firebase. It empowers students to safely report, track, and recover lost and found items across the campus.

## ✨ Features

- **Google Student Sign-In:** Secure authentication using Google Sign-In with real-time Firebase profile syncing.
- **5-Tab Navigation System:** A highly responsive, safe-area-aware custom bottom navigation bar that seamlessly integrates with Android system gestures.
- **Lost & Found Feed:** A unified feed to see recently posted lost and found items in real-time using Firestore streams.
- **Save/Bookmark System:** Users can save items and view them later in their dedicated "Saved Items" tab with swipe-to-dismiss functionality.
- **Cloudinary Image Hosting:** Instantly upload item photos and profile pictures using a custom integration with Cloudinary (bypassing Firebase Storage limits).
- **Interactive App Icon:** Custom interactive 'FL' smart 3D glassmorphism logo integrated into the native Android platform.
- **Real-Time Messaging:** Built-in chat system allowing finders to message owners privately, fetching real user names and dynamic avatars.
- **Cross-Platform:** Codebase is structured to easily compile to both Android and iOS.

---

## 🛠️ Tech Stack & Architecture

- **Flutter / Dart:** Core UI framework and application logic.
- **Firebase Auth & Google Sign-In:** One-click student login and session management.
- **Cloud Firestore:** Real-time NoSQL database for feed posts, saved item references, user profiles, and private messages.
- **Cloudinary:** Lightning fast, unsigned image uploads for item photos and profile avatars.
- **Provider:** Robust state management ensuring fast localized UI updates.
- **Native Routing:** Stateful `IndexedStack` routing allowing users to switch tabs without losing reading position.

### 📂 Project Structure

```text
lib/
├── config/             # Environment & backend configurations
├── constants/          # Application-wide themes, colors, and layout metrics
├── models/             # Data serialization classes (Post, Chat, Message)
├── navigation/         # Centralized AppRouter and bottom tab orchestrator
├── providers/          # AuthProvider for reactive profile state
├── screens/
│   ├── auth/           # Haramaya branded Login
│   ├── chat/           # Chat list tracking and real-time private messaging
│   ├── feed/           # Main item feed and post creation wizard
│   ├── saved/          # Swipeable saved items view
│   └── profile/        # User profile, statistics, and editing
├── services/           # External API calls (Firestore, Cloudinary)
├── widgets/            # Reusable UI components
└── main.dart           # App entry point & System UI Edge-to-Edge binding
```

---

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version 3.x)
- Android Studio / XCode for device emulation

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Images (Cloudinary)
By default, the app uses Cloudinary for free image uploads. In `lib/services/image_upload_service.dart`, ensure your `cloudName` and `uploadPreset` are correctly defined.

### 3. Firebase Configuration
The Android runner uses a `google-services.json` file inside `android/app/` with the registered SHA-1 and SHA-256 fingerprints for Google Sign-In.

### 4. Run the App
Connect a physical device or run an emulator, then:
```bash
flutter run
```

---

## 📝 Design Philosophy

We prioritized a **vibrant, highly accessible premium UI**, replacing generic browser-default colors with an attractive Haramaya University theme map:
- **Navigation:** Native Android system buttons are styled beautifully and pushed behind a clean App background.
- **Lost Items** are highlighted with a distinct Red (`#FF3B30`).
- **Found Items** are highlighted with a calming Green (`#34C759`).
- Standard UI actions follow a strong guiding Blue primary color (`#007AFF`).

The visual hierarchy separates form from background gracefully using subtle drop shadows, rounded cards, and smooth transitions.
