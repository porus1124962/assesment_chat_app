# ChatBASE - Assessment Chat Application

** Flutter chat application showcasing clean architecture, state management with BLoC pattern, and real-time Firebase integration.**

> **App Name**: ChatBASE - A name related to CodeBase Tech.

---

## ⚠️ Important Notes

### GoogleServices Configuration
✅ **GoogleServices file included** - The `google-services` files are already configured for Firebase integration. This enables seamless Firebase authentication and Firestore functionality for Assessment check.

### Security Notice
⚠️ **Assessment App - Relaxed Security**: This is an assessment/demonstration application, so certain security constraints have been intentionally relaxed to showcase functionality cleanly:
- Firebase Security Rules are configured for ease of testing (not production-grade)
- Some validations are simplified for demonstration purposes
---

## 📋 Project Overview

The ChatBASE application is a comprehensive Flutter-based messaging platform designed to demonstrate best practices in mobile development. It features:

- ✅ Real-time messaging with Firebase Firestore
- ✅ Read receipts with delivery and read status ticks (✓ / ✓✓)
- ✅ User authentication and management
- ✅ Rich media support (images, videos, audio, files)
- ✅ Connectivity monitoring and offline support
- ✅ Dark mode/theme management
- ✅ Architectural best practices (Clean Architecture + BLoC)
- ✅ Comprehensive test coverage
- ✅ Cross-platform support (Android & iOS)

---

## 🏗️ Architecture Overview

This project implements **Clean Architecture** with **BLoC/Cubit** pattern for state management:

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│                  (Pages, Widgets, BLoCs, Cubits)             │
├─────────────────────────────────────────────────────────────┤
│                    APPLICATION LAYER                         │
│          (Cubits, BLoCs, State Management Logic)            │
├─────────────────────────────────────────────────────────────┤
│                    DOMAIN LAYER                              │
│         (Entities, Repository Interfaces, Use Cases)        │
├─────────────────────────────────────────────────────────────┤
│                    DATA LAYER                                │
│      (Repository Implementations, Models, DataSources)      │
├─────────────────────────────────────────────────────────────┤
│                 EXTERNAL (Firebase, Hive, etc.)             │
└─────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. **Presentation Layer** (`lib/presentation/`)
- UI Components (Pages, Widgets)
- State Management (BLoCs, Cubits)
- Theme Management
- Routing and Navigation

#### 2. **Domain Layer** (`lib/domain/`)
- Business Entity Definitions
- Abstract Repository Interfaces
- Business Rules

#### 3. **Data Layer** (`lib/data/`)
- Repository Implementations
- Data Models (Firebase serialization)
- DataSource Implementations
- Local Caching (Hive)

#### 4. **Core Layer** (`lib/core/`)
- Theme Configuration
- Utilities and Constants
- Shared Components

---

## 📂 Project Structure

```
assesment_chat_app/
├── lib/
│   ├── config/
│   │   ├── firebase_config.dart      # Firebase initialization
│   │   ├── hive_config.dart          # Local database setup
│   │   ├── router.dart               # GoRouter navigation
│   │   └── service_locator.dart      # Dependency injection
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   └── app_theme.dart        # Light/Dark theme definitions
│   │   └── utils/                    # Shared utilities
│   │
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── user.dart             # User entity
│   │   │   ├── chat.dart             # Chat entity
│   │   │   ├── message.dart          # Message entity
│   │   │   └── ...
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── chat_repository.dart
│   │       ├── message_repository.dart
│   │       └── ...
│   │
│   ├── data/
│   │   ├── datasources/
│   │   │   ├── remote/               # Firebase datasources
│   │   │   └── local/                # Hive local datasources
│   │   ├── models/
│   │   │   ├── user_model.dart       # with toJson/fromJson
│   │   │   ├── chat_model.dart
│   │   │   └── ...
│   │   └── repositories/
│   │       ├── auth_repository_impl.dart
│   │       ├── chat_repository_impl.dart
│   │       └── ...
│   │
│   ├── presentation/
│   │   ├── blocs/
│   │   │   ├── auth/
│   │   │   ├── connectivity/
│   │   │   └── theme/
│   │   │
│   │   ├── cubits/
│   │   │   ├── chat/
│   │   │   ├── user/
│   │   │   ├── message/
│   │   │   ├── connectivity/
│   │   │   └── ...
│   │   │
│   │   ├── pages/
│   │   │   ├── splash/
│   │   │   ├── auth/
│   │   │   ├── chat/
│   │   │   ├── conversations/
│   │   │   └── ...
│   │   │
│   │   └── widgets/
│   │       ├── message_bubble.dart
│   │       ├── user_tile.dart
│   │       └── ...
│   │
│   ├── app.dart                      # App widget with providers
│   ├── main.dart                     # Entry point
│   └── firebase_options.dart         # Firebase config
│
├── test/
│   ├── auth_cubit_test.dart          # Unit tests
│   ├── chat_cubit_test.dart
│   ├── user_list_cubit_test.dart
│   └── widget_test.dart
│
├── android/
├── ios/
├── pubspec.yaml                      # Dependencies
├── firebase.json                     # Firebase settings
│
└── README.md                         # This file
```

---

## 🛠️ Technology Stack

### Core Framework
- **Flutter**: v3.10.0+
- **Dart**: SDK ^3.10.0

### State Management
- **flutter_bloc**: ^8.1.6 - BLoC/Cubit pattern implementation
- **bloc_test**: ^9.1.0 - Testing BLoCs and Cubits

### Firebase Services
- **firebase_core**: ^3.0.0 - Firebase initialization
- **firebase_auth**: ^5.0.0 - Authentication
- **cloud_firestore**: ^5.0.0 - Real-time database
- **firebase_storage**: ^12.0.0 - File storage

### Data Persistence
- **hive**: ^2.2.3 - Local NoSQL database
- **hive_flutter**: ^1.1.0 - Flutter integration
- **shared_preferences**: ^2.2.2 - Key-value storage

### Networking & Serialization
- **dio**: ^5.7.0 - for downloading/loading Media
- **json_annotation**: ^4.8.1 - JSON serialization
- **json_serializable**: ^6.7.1 - Code generation

### Navigation
- **go_router**: ^14.0.0 - Declarative routing

### Dependency Injection
- **get_it**: ^7.6.0 - Service locator pattern

### Utility Libraries
- **equatable**: ^2.0.5 - Value equality
- **uuid**: ^4.0.0 - UUID generation
- **intl**: ^0.19.0 - Internationalization
- **crypto**: ^3.0.0 - Hashing utilities/ Used for hashing long urls in hive
- **path**: ^1.9.0 - Path manipulation

### Media Handling
- **image_picker**: ^1.1.2 - Device image/video picker
- **file_picker**: ^10.3.10 - File selection
- **flutter_image_compress**: ^2.3.0 - Image compression
- **video_compress**: ^3.1.4 - Video compression
- **flutter_video_thumbnail_plus**: ^1.0.6 - Video thumbnails
- **just_audio**: ^0.9.40 - Audio playback
- **mime**: ^2.0.0 - MIME type detection

### Connectivity
- **connectivity_plus**: ^6.0.5 - Network connectivity monitoring

### File Management
- **path_provider**: ^2.1.4 - System paths
- **open_filex**: ^4.6.0 - Open files with apps

### Linting & Code Quality
- **flutter_lints**: ^6.0.0 - Lint rules

### Testing
- **mocktail**: ^1.0.0 - Mocking utilities

---

## 🎯 Core Features

### 1. **Authentication & User Management**
- User registration and login with Firebase Auth
- User profile management
- User search
- User listing with caching

**Component**: `AuthCubit`, `AuthRepository`

---

### 2. **Real-Time Messaging**
- Send and receive messages in real-time
- Message persistence with Firestore
- Message threading/grouping
- Read receipts with visual indicators
  - **Single Check ✓** - Message delivered to recipient
  - **Double Check ✓✓** - Message read by recipient
- Typing indicators (optional)

**Components**: `MessageCubit`, `ChatCubit`, `MessageRepository`, `ChatRepository`

---

### 3. **Rich Media Support**
- Image sharing with compression
- Video sharing with compression and thumbnails
- Audio message recording and playback
- File sharing (documents, PDFs, etc.)
- Media thumbnail generation

**Features**:
- Automatic image compression to optimize storage
- Video preview with thumbnails
- Audio playback with visual controls
- MIME type detection for proper file handling

---

### 4. **Conversation Management**
- List of active conversations
- Conversation ordering by last message
- Conversation archiving/deletion
- Conversation search

**Component**: `UserListCubit`, `UserRepository`

---

### 5. **Connectivity Management**
- Real-time connectivity status monitoring
- Offline detection with visual indicator
- Connection retry mechanism
- Offline message queuing (optional)

**Component**: `ConnectivityCubit`, `ConnectivityStatus`

**UI Indication**: Red banner at bottom showing "No connectivity" with Refresh button

---

### 6. **Theme Management**
- Light and Dark theme support
- System theme detection
- User preference persistence
- Theme transition animations

**Component**: `ThemeBloc`, `ThemeState`, `AppTheme`

**Configuration**: `lib/core/theme/app_theme.dart`

---

### 7. **Local Caching & Offline Support**
- Hive-based local database for users and messages
- Automatic sync when connection restored
- Cache invalidation strategies
- Data encryption support (optional)

**Configuration**: `lib/config/hive_config.dart`

---

## 📊 State Management Hierarchy

### BLoC Pattern (Application-wide states)
- **ThemeBloc** - Global theme state management
- **AuthBloc** - Authentication state

### Cubit Pattern (Feature-specific states)
- **ConnectivityCubit** - Connectivity monitoring
- **UserListCubit** - User list and conversation partners
- **ChatCubit** - Chat room state
- **MessageCubit** - Message operations
- **AuthCubit** - User authentication

### State Management Benefits
✅ Separation of concerns
✅ Easy testing
✅ Reactive UI updates
✅ Reproducible bug fixes
✅ Time-travel debugging

---
### Configuration Files

- **`lib/config/firebase_config.dart`** - Firebase initialization
- **`lib/config/hive_config.dart`** - Local database setup
- **`lib/config/service_locator.dart`** - Dependency injection
- **`lib/config/router.dart`** - Route definitions

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/auth_cubit_test.dart

# Run with verbose output
flutter test --verbose
```

### Test Files Location
```
test/
├── auth_cubit_test.dart
├── chat_cubit_test.dart
├── message_bubble_widget_test.dart
├── model_timestamp_parsing_test.dart
├── user_list_cubit_test.dart
├── user_tile_widget_test.dart
└── widget_test.dart
```

### Testing Framework
- **flutter_test**: Built-in testing
- **bloc_test**: BLoC-specific testing utilities
- **mocktail**: Mocking library for clean tests

### Test Coverage Areas
✅ Authentication flow
✅ Message CRUD operations
✅ User list filtering
✅ Widget rendering
✅ State transitions
✅ Error handling
✅ Connectivity states

---


