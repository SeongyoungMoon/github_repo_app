# GitHub Repository Search App

A Flutter application for searching GitHub repositories via REST API, viewing repository details, and managing local bookmarks.

## Key Implementation Details

### Search & Repository List

* Integrated GitHub REST API to fetch public repositories based on search queries.
* Added an `errorBuilder` fallback in the avatar widget to show a default icon when network image loading fails, preventing UI breaks.

### Repository Details

* Parsed key repository metadata including repository name, description, stargazers, forks, and subscribers count (`watchers`).

### Bookmark Persistence

* Utilized `SharedPreferences` to manage bookmarked repositories and persist state across app restarts.

### Automated Testing

* Wrote widget tests for key components (`SearchItemTile`) to verify UI rendering and interactions.
* Added integration tests against a live public repository (`SeongyoungMoon/github_repo_app`) to validate API responses and data parsing.

## Getting Started

### Prerequisites

* Flutter SDK (Latest Stable version recommended)
* Dart SDK

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Run the App

```bash
# Debug Mode
flutter run

# Release Mode
flutter run --release
```

### 3. Build APK

```bash
flutter build apk --release
```

> Output APK location: `build/app/outputs/flutter-apk/app-release.apk`

## Testing & Analysis

```bash
# Static Code Analysis
flutter analyze

# Run All Tests
flutter test
```

---

Thank you for reviewing this project! Feedback is always welcome.