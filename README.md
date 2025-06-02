# Resbite App


## Architecture

The app is built with a clean architecture approach, using:

- **Flutter** for the UI framework
- **Firebase** for authentication
- **Supabase** for database and storage
- **Riverpod** for state management
- **Freezed** for immutable data models
  
## Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Firebase project with Authentication enabled
- Supabase project

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/resbite_app.git
   cd resbite_app
   ```

2. Copy the appropriate `.env` template and fill in secrets:
    ```bash
   # For development:
   cp .env.example .env
   # For testing with shared credentials:
   cp .env.testing .env
    ```
   ```
   # Environment
   ENVIRONMENT=development
   
   # Firebase
   FIREBASE_API_KEY=YOUR_FIREBASE_API_KEY
   FIREBASE_APP_ID=YOUR_FIREBASE_APP_ID
   FIREBASE_MESSAGING_SENDER_ID=YOUR_FIREBASE_MESSAGING_SENDER_ID
   FIREBASE_PROJECT_ID=YOUR_FIREBASE_PROJECT_ID
   FIREBASE_STORAGE_BUCKET=YOUR_FIREBASE_STORAGE_BUCKET
   
   # Supabase
   SUPABASE_URL=YOUR_SUPABASE_URL
   SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
   ```

3. Add Firebase configuration files:
   - For iOS: Add `GoogleService-Info.plist` to `ios/Runner/`
   - For Android: Add `google-services.json` to `android/app/`

4. Install dependencies:
   ```bash
   flutter pub get
   ```

5. Generate the necessary files for the Freezed models:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

6. Run the app:
   ```bash
   flutter run
   ```

## Features

- **Authentication**: Email/password authentication with Firebase
- **Activities**: Browse activities by category
- **Resbites**: Create and join activity events
- **Profiles**: View and edit user profiles
- **Offline support**: Basic offline functionality with data caching

## License

This project is proprietary and confidential.
