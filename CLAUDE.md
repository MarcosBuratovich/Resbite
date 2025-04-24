# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build/Test Commands
- Run the app: `flutter run`
- Run all tests: `flutter test`
- Run a single test: `flutter test test/path_to_test_file.dart`
- Analyze code: `flutter analyze`
- Format code: `dart format lib`
- Generate code: `flutter pub run build_runner build --delete-conflicting-outputs`
- Install dependencies: `flutter pub get`

## Project Structure
- **Architecture**: Firebase Auth + Supabase Database
- **Flutter SDK Version**: 3.7.2 or higher
- **State Management**: Riverpod
- **Key Packages**: firebase_auth, supabase_flutter, flutter_riverpod, freezed

## Code Style Guidelines
- **Imports**: Group imports (Flutter, third-party, project) with blank lines between
- **Formatting**: Follow Dart formatting conventions (dartfmt)
- **State Management**: Use Riverpod providers in services/app_state.dart
- **Error Handling**: Use try-catch with logging via AppLogger (utils/logger.dart)
- **Naming**: 
  - Classes: PascalCase
  - Variables/methods: camelCase
  - Constants: camelCase or SCREAMING_SNAKE_CASE for globals
- **Architecture**: Follow screen/service/model separation
- **Models**: Define models with Freezed for immutability
- **Database**: Use services/database_service.dart for Supabase interactions
- **UI**: Use Material 3 with theme defined in config/theme.dart
- **Environment**: Use .env file and Env class for configuration