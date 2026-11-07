# Celebratio

Celebratio is a Flutter app for organizing celebrations with friends. Create
events, coordinate gifts, and keep track of upcoming celebrations in one
place.

## Features

- **Authentication** with email sign-in, account creation, and password reset
- **Event management** — create, edit, delete, publish, and browse events
- **Event discovery** — view a friend's events and filter events by past,
  current, or upcoming dates
- **Gift coordination** — add gifts to events, browse gift details, and filter
  gifts by availability or pledge status
- **Gift pledges** — pledge gifts for friends and track incoming and outgoing
  gifts
- **Friends** — add friends by email, search your friend list, and view their
  upcoming events
- **Notifications** — receive Firebase Cloud Messaging notifications and
  enable or disable them from your profile
- **Offline-first support** — store events and gifts locally with SQLite and
  synchronize changes with Firestore when connectivity returns
- **Introductory onboarding** for new users

## Tech stack

- Flutter and Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- SQLite via `sqflite`
- Provider for application state management

## Getting started

### Prerequisites

- Flutter SDK
- Dart SDK compatible with the version in `pubspec.yaml`
- A configured Firebase project for the target platform

### Run locally

```bash
flutter pub get
flutter run
```

Run the test suite with:

```bash
flutter test
```

Firebase platform configuration is provided through the generated
`lib/firebase_options.dart` file. Make sure the required Firebase services and
platform credentials are configured before running the app.
