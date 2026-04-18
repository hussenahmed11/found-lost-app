# Campus Lost & Found 📱🎓

Welcome to the **Campus Lost & Found** app! This is a modern, cross-platform mobile application built with Flutter & Firebase. It allows students to report, track, and recover lost and found items across the campus.

*Note: This project was successfully migrated from a React Native/Expo architecture to a clean, scalable Flutter architecture.*

## ✨ Features

- **User Authentication:** Secure explicit email/password registration and login.
- **Lost & Found Feed:** A unified feed to see recently posted lost and found items.
- **Item Categorization:** Tags such as Electronics, Bags, IDs, and location tagging.
- **Post Creation:** Add new items with image uploads using your device's camera or gallery.
- **Real-Time Messaging:** Built-in chat system allowing finders to message owners privately.
- **Matching Algorithm:** Behind-the-scenes logic tracking similarities to find potential matches between reported "Lost" and "Found" items.
- **Cross-Platform:** Codebase is structured to easily compile to both Android and iOS.

---

## 🛠️ Tech Stack & Architecture

- **Flutter / Dart:** Core UI framework and application logic.
- **Firebase Auth:** User authentication and session management.
- **Cloud Firestore:** Real-time NoSQL database for posts, user profiles, active chats, and private messages.
- **Firebase Storage:** Cloud storage for uploading pictures of items.
- **Provider:** Robust state management (handles auth state and profile initialization).
- **Native Routing:** Direct Material Navigation using named routes (`/login`, `/item-details`, `/chat-room`).

### 📂 Project Structure

```text
lib/
├── config/             # Environment & backend configurations
├── constants/          # Application-wide themes, colors, and layout metrics
├── models/             # Data serialization classes (Post, Chat, Message)
├── navigation/         # Centralized AppRouter and bottom tab orchestrator
├── providers/          # ChangeNotifier classes for state management
├── screens/
│   ├── auth/           # Login and Registration flows
│   ├── chat/           # Chat list tracking and real-time private messaging
│   ├── feed/           # Main item feed and post creation wizard
│   └── profile/        # User profile, statistics, and logout
├── services/           # Controller singletons for external API calls (Firebase)
├── utils/              # Helper functions and business algorithms
├── widgets/            # Reusable UI components (Buttons, Inputs, Cards)
└── main.dart           # App entry point & Firebase initialization
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

### 2. Firebase Configuration
The Android runner uses a `google-services.json` file inside `android/app/`. If you want to configure this for iOS:
1. Go to the [Firebase Console](https://console.firebase.google.com).
2. Register an iOS app ensuring the bundle ID matches.
3. Download the `GoogleService-Info.plist` and place it in the `ios/Runner/` folder via Xcode.

### 3. Run the App
Connect a physical device or run an emulator, then:
```bash
flutter run
```

---

## 📝 Design Philosophy

We prioritized a **vibrant, highly accessible UI**, replacing generic browser-default colors with an attractive theme map: 
- **Lost Items** are highlighted with a distinct Red (`#FF3B30`).
- **Found Items** are highlighted with a calming Green (`#34C759`).
- Standard UI actions follow a strong guiding Blue primary color (`#007AFF`).

The visual hierarchy separates form from background gracefully using subtle drop shadows, rounded cards, and smooth transitions.
