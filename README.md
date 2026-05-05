# 🎓 Haramaya University Lost & Found App

A modern, cross-platform mobile application built with **Flutter & Firebase** that helps Haramaya University students report, track, and recover lost and found items across the campus.

---

## ✨ Features

### 🔐 Authentication
- **Google Sign-In** with mandatory account chooser (no auto-login to wrong account)
- **Email/Password** registration and login
- Persistent session with automatic profile syncing from Firestore
- Proper sign-out that clears cached Google sessions

### 📋 Feed & Discovery
- **Real-time feed** of all lost and found items using Firestore streams
- **Filter buttons** — All, Lost, Found — with client-side filtering (no Firestore index required)
- **Search bar** — search by title, location, category, or description
- Items ordered by most recent first

### 💬 Chat System
- **Real-time messaging** between users via Firestore `onSnapshot` listeners
- Auto-creates chat room when contacting a post owner
- Chat list shows **real user names** and **profile images**
- **Swipe to delete** chats with confirmation dialog
- Messages appear instantly — no refresh needed

### 📌 Save & Bookmark
- Save/unsave items from the feed
- Dedicated **Saved Items** tab with swipe-to-remove
- Persistent across sessions via Firestore subcollection

### 👤 Profile
- View your profile with name, email, and profile image
- **Edit Profile** screen to update name and photo
- View your own posted items
- Logout with full session cleanup

### 🖼️ Image Uploads
- **Cloudinary** integration for free, fast image hosting
- Unsigned upload preset — no server-side auth needed
- Supports item photos and profile pictures
- Bypasses Firebase Storage entirely

### 📱 Android Enhancements
- **Immersive fullscreen mode** — hides status bar and navigation buttons
- Auto-restores immersive mode when app resumes from background
- **Adaptive app icon** with proper foreground/background layers
- Supports display cutout (notch) devices

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter / Dart |
| **Auth** | Firebase Auth + Google Sign-In |
| **Database** | Cloud Firestore (real-time) |
| **Image Hosting** | Cloudinary (unsigned uploads) |
| **State Management** | Provider (ChangeNotifier) |
| **HTTP** | `http` package (for Cloudinary API) |
| **Caching** | `cached_network_image` |
| **Sharing** | `share_plus` |
| **Date Formatting** | `intl` |

---

## 📂 Project Structure

```
lib/
├── main.dart                    # App entry point, immersive mode setup
├── constants/
│   └── theme.dart               # Colors, spacing, radius, typography
├── models/
│   ├── post_model.dart          # Post data model (Firestore serialization)
│   ├── chat_model.dart          # Chat room data model
│   └── message_model.dart       # Message data model
├── navigation/
│   └── app_router.dart          # Auth-aware routing, bottom nav shell
├── providers/
│   └── auth_provider.dart       # Reactive auth state (ChangeNotifier)
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart    # Email/password + Google login
│   │   └── register_screen.dart # New user registration
│   ├── feed/
│   │   ├── feed_screen.dart     # Main feed with search & filters
│   │   ├── item_details_screen.dart  # Item detail view + contact owner
│   │   └── post_item_screen.dart     # Create new lost/found post
│   ├── chat/
│   │   ├── chat_list_screen.dart     # All conversations
│   │   └── chat_room_screen.dart     # Real-time messaging
│   ├── saved/
│   │   └── saved_screen.dart    # Bookmarked items
│   └── profile/
│       ├── profile_screen.dart  # User profile + own posts
│       └── edit_profile_screen.dart  # Edit name/photo
├── services/
│   ├── auth_service.dart        # Firebase Auth + Google Sign-In logic
│   ├── post_service.dart        # CRUD for posts collection
│   ├── chat_service.dart        # Chat rooms + messaging
│   ├── saved_posts_service.dart # Saved/bookmarked items
│   └── image_upload_service.dart # Cloudinary image uploads
└── widgets/
    ├── post_card.dart           # Reusable post card component
    ├── app_button.dart          # Styled button component
    └── app_input.dart           # Styled text input component
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.5+)
- Android Studio or physical Android device
- A Firebase project with **Auth** and **Firestore** enabled
- A [Cloudinary](https://cloudinary.com/) account (free tier)

### 1. Clone & Install

```bash
git clone <repository-url>
cd found_lost_flutter
flutter pub get
```

### 2. Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
2. Enable **Email/Password** and **Google** sign-in methods
3. Create a **Cloud Firestore** database
4. Download `google-services.json` and place it in `android/app/`
5. Register your app's **SHA-1** and **SHA-256** fingerprints for Google Sign-In

### 3. Cloudinary Setup

1. Create a free account at [cloudinary.com](https://cloudinary.com/)
2. Go to **Settings → Upload → Upload Presets**
3. Create an **Unsigned** upload preset
4. Update `lib/services/image_upload_service.dart` with your:
   - `cloudName` — from your Cloudinary dashboard
   - `uploadPreset` — from the preset you just created

### 4. Run

```bash
flutter run
```

---

## 🎨 Design System

| Token | Value | Usage |
|---|---|---|
| **Primary** | `#007AFF` | Buttons, links, active states |
| **Secondary** | `#34C759` | Found items, success states |
| **Danger** | `#FF3B30` | Lost items, errors, delete actions |
| **Warning** | `#FF9500` | Alerts, caution states |
| **Background** | `#F2F2F7` | Page backgrounds |
| **Surface** | `#FFFFFF` | Cards, inputs, nav bar |
| **Text Primary** | `#1C1C1E` | Headings, body text |
| **Text Secondary** | `#8E8E93` | Captions, hints |

---

## 📄 License

This project is developed for **Haramaya University** campus use.

---

> Built with ❤️ using Flutter & Firebase
