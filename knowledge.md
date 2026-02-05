# Project knowledge

This file gives Codebuff context about your project: goals, commands, conventions, and gotchas.

## Overview
Void Space is a Flutter mobile app for saving and organizing notes, links, images, and documents. It features AI-powered summaries, local Hive storage, and comprehensive share sheet integration.

## Quickstart
- Setup: `flutter pub get`
- Generate Hive adapters: `flutter packages pub run build_runner build --delete-conflicting-outputs`
- Dev: `flutter run`
- Test: `flutter test`
- Analyze: `flutter analyze`
- Build Android: `flutter build apk`
- Build iOS: `flutter build ios`

## Architecture
- Key directories:
  - `lib/app/` - App entry point and routing (VoidApp, routes)
  - `lib/data/` - Data layer (models with Hive adapters, database with Hive box, stores)
  - `lib/services/` - Business logic (AI, haptics, link metadata, security, share bridge)
  - `lib/ui/` - UI screens and widgets organized by feature (home, profile, share, splash)
- Data flow: UI → VoidStore → VoidDatabase (Hive Box) → Local Hive storage
- Model: `VoidItem` - core entity with Hive TypeAdapter, fields: id, type, content, title, summary, imageUrl, createdAt, tags, embedding

## Conventions
- Formatting/linting: Uses `flutter_lints` package, run `flutter analyze`
- Patterns to follow:
  - Static methods on stores/services (e.g., `VoidStore.all()`, `VoidStore.add()`)
  - Dark theme only (`ThemeMode.dark`)
  - Feature-based folder structure under `lib/ui/`
  - Hive adapters auto-generated using `build_runner`
- Things to avoid:
  - Don't await store init in main() - app starts immediately
  - Avoid light theme styles (app is dark-mode only)
  - When adding new fields to VoidItem, regenerate adapters with build_runner

## Key Dependencies
- `hive` / `hive_flutter` - Local key-value storage (replaced sqflite)
- `build_runner` / `hive_generator` - Auto-generate Hive TypeAdapters
- `google_fonts` - Typography
- `flutter_staggered_grid_view` - Masonry grid layout
- `url_launcher` - Opening links
- `local_auth` - Biometric authentication
- `path_provider` - File system paths (for persistent file storage)

## Platform Notes
- Android: Has custom ShareHandlerActivity for receiving shared content (text, images, documents, videos)
  - Supports: text/plain, image/*, application/*, text/*, video/*
  - Shared files are copied to app documents directory for persistent access
  - Uses MethodChannel to pass file paths/metadata to Flutter
- iOS: Standard Flutter setup
- Desktop: Uses Hive native storage

## Database Notes
- Using Hive instead of SQLite for simpler, faster local storage
- Box name: 'void_items'
- TypeId for VoidItem: 0 (assigned in @HiveType annotation)
- Search: Client-side filtering on title/summary/content/tags (no SQL)
- Migration: Started fresh with Hive, no SQLite migration script needed

## File Share Notes
- Shared files are copied from cache to app documents directory
- File types detected based on MIME type (image, pdf, document, file)
- File path stored in VoidItem.content field
- Images: path also stored in imageUrl field for preview
- Metadata: filename as title, type and size as summary
