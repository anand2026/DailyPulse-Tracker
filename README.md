# DailyPulse - Personal Wellness Tracker

## Project Overview

DailyPulse is a Flutter-based mobile application designed to help users track their daily emotional state and mental wellness. In today's fast-paced world, it's easy to lose touch with our emotions. DailyPulse provides a simple, intuitive interface for logging daily moods, viewing historical patterns, and gaining insights into emotional well-being through analytics.

The app combines local data persistence with cloud synchronization, ensuring that user data is always available even without an internet connection, while also providing the security of cloud backup through Firebase.

## Features

### Core Features
- **Mood Logging**: Select from 5 distinct mood types (Great, Good, Okay, Bad, Terrible) with emoji representations
- **Daily Notes**: Add optional text notes to provide context for each mood entry
- **Date Selection**: Log moods for current or past dates
- **Mood History**: View all past mood entries with calendar integration
- **Analytics Dashboard**: Visualize mood patterns with statistics and charts
- **Local Storage**: All data persisted locally using SQLite
- **Firebase Integration**: Authentication and cloud backup with Firestore

### Bonus Features Implemented
- ✅ Calendar Integration: Visual calendar showing mood entries by date
- ✅ Mood Trends/Graph: Pie chart visualization of mood distribution
- ✅ Dark Mode Toggle: Automatic theme switching based on system preferences
- ✅ Firebase Authentication: Email/password authentication with signup/login
- ✅ Cloud Firestore: Mood entries synced to cloud for backup

## Technical Stack

- **Framework**: Flutter SDK 3.9.2
- **State Management**: Riverpod (flutter_riverpod 2.4.9)
- **Navigation**: go_router 13.0.0
- **Local Storage**:
  - sqflite 2.3.0 (complex data)
  - shared_preferences 2.2.2 (simple key-value pairs)
- **Firebase**:
  - firebase_core 2.24.2
  - firebase_auth 4.16.0
  - cloud_firestore 4.14.0
- **UI Components**:
  - table_calendar 3.0.9 (calendar view)
  - fl_chart 0.66.0 (analytics charts)
  - font_awesome_flutter 10.6.0 (icons)
  - intl 0.19.0 (date formatting)

## Architecture

The app follows a simplified clean architecture pattern as defined in CLAUDE.md:

```
lib/
  app/                      # App-level configuration
    theme.dart             # Theme colors and styling
    router.dart            # Navigation routing
    route_endpoints.dart   # Route path constants
  core/                    # Core utilities
    database_helper.dart   # SQLite database setup
  features/                # Feature modules
    auth/                  # Authentication feature
      models/              # User model
      services/            # Auth service
      presentation/        # Login & signup screens
    mood_tracker/          # Mood tracking feature
      models/              # MoodEntry model
      services/            # Mood service
      presentation/        # All mood-related screens
```

### Key Design Decisions

1. **Local-First Architecture**: All data is stored locally first, then synced to Firebase
2. **Nullable Fields**: All model fields are nullable to prevent crashes on schema changes
3. **Separation of Concerns**: Clear separation between models, services, and presentation layers
4. **Theme Consistency**: All UI components use centralized theme colors from app/theme.dart
5. **Generic Error Handling**: Services use generic exceptions for consistency

## Setup Instructions

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- iOS Simulator / Android Emulator / Physical Device
- Firebase project (for authentication and cloud features)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd "DailyPulse Tracker"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup** (Required for auth and cloud features)

   For iOS:
   ```bash
   cd ios
   pod install
   cd ..
   ```

   For Android: Update `android/app/google-services.json`

   **Note**: You'll need to set up a Firebase project and download the configuration files:
   - iOS: `GoogleService-Info.plist` in `ios/Runner/`
   - Android: `google-services.json` in `android/app/`

   Then run:
   ```bash
   flutterfire configure
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Build Commands

- **Debug build**: `flutter run`
- **Release build (Android)**: `flutter build apk --release`
- **Release build (iOS)**: `flutter build ios --release`

## Usage

1. **Sign Up / Login**: Create an account or login with existing credentials
2. **Log Mood**: Select your current mood with emoji and optionally add a note
3. **View History**: Browse past mood entries with calendar integration
4. **Analytics**: View mood statistics, distribution charts, and trends

## Emotion Logic

### Mood Types
The app categorizes emotions into 5 distinct types:

1. **Great** 😄 (Green) - Extremely positive mood
2. **Good** 🙂 (Light Green) - Positive mood
3. **Okay** 😐 (Yellow) - Neutral mood
4. **Bad** 😔 (Orange) - Negative mood
5. **Terrible** 😢 (Red) - Extremely negative mood

### Analytics Calculations
- **Positive Days**: Count of "Great" and "Good" moods
- **Negative Days**: Count of "Bad" and "Terrible" moods
- **Completion Rate**: Percentage of positive days out of total entries
- **Most Common Mood**: The mood type with the highest frequency
- **Mood Distribution**: Pie chart showing percentage breakdown of all mood types

## UI/UX Choices

### Design Philosophy
- **Minimalist**: Clean, uncluttered interface focused on core functionality
- **Emotional Colors**: Each mood has a distinct color representing its emotional tone
- **Consistent Theming**: Dark and light modes with automatic system detection
- **Intuitive Navigation**: Bottom navigation bar for quick access to main features

### Color Palette
- **Primary**: #6C63FF (Purple) - Calming and trustworthy
- **Great**: #4CAF50 (Green) - Positive and energizing
- **Good**: #8BC34A (Light Green) - Optimistic
- **Okay**: #FFC107 (Yellow) - Neutral
- **Bad**: #FF9800 (Orange) - Warning
- **Terrible**: #F44336 (Red) - Intense negative

### Layout
- **Card-based**: Information grouped in cards for better visual separation
- **Emoji-first**: Large, prominent emoji displays for quick mood identification
- **Responsive**: Adapts to different screen sizes and orientations

## Data Privacy

- All mood data is stored locally on the device by default
- Firebase Authentication uses industry-standard security
- Cloud Firestore data is user-isolated (each user can only access their own data)
- No analytics or tracking beyond Firebase's built-in authentication
- Users have full control over their data

## Future Enhancements

Potential features for future versions:
- Export mood data to CSV/PDF
- Reminders to log daily moods
- Mood insights with AI-powered suggestions
- Social features (optional mood sharing)
- Integration with health apps
- Customizable mood categories
- Streak tracking and achievements

## Contributing

This project was created as part of a Flutter internship assessment. For any issues or suggestions, please refer to the project guidelines.

## License

This project is created for educational purposes as part of a Flutter internship assessment.

---

## Screenshots

### Authentication
<div align="center">
  <img src="https://github.com/anand2026/DailyPulse-Tracker/blob/main/images/Screenshot_1761235103.png" width="250" alt="Login Screen"/>
  <img src="https://github.com/anand2026/DailyPulse-Tracker/blob/main/images/Screenshot_1761235107.png" width="250" alt="Signup Screen"/>
</div>

### Mood Tracking
<div align="center">
  <img src="https://github.com/anand2026/DailyPulse-Tracker/blob/main/images/Screenshot_1761235134.png" width="250" alt="Mood Logger"/>
  <img src="https://github.com/anand2026/DailyPulse-Tracker/blob/main/images/Screenshot_1761235137.png" width="250" alt="Mood History"/>
</div>

### Analytics & Features
<div align="center">
  <img src="https://github.com/anand2026/DailyPulse-Tracker/blob/main/images/Screenshot_1761235143.png" width="250" alt="Analytics Dashboard"/>
  <img src="https://github.com/anand2026/DailyPulse-Tracker/blob/main/images/Screenshot_1761235198.png" width="250" alt="Calendar View"/>
</div>

---

**Built with ❤️ using Flutter**