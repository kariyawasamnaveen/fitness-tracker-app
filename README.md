# Leveling Fitness

A premium, modern Flutter fitness tracking application designed to help users log workouts, maintain daily streaks, and visualize their progress. Built with a modular architecture and a robust tech stack, this app delivers a seamless and highly responsive user experience.

## ✨ Key Features
- **Authentication**: Secure email/password and Google Sign-In powered by Firebase Auth.
- **Fitness Tracking**: Log daily workouts, maintain activity streaks, and earn dynamic fitness level badges.
- **Google Fit Integration**: Automatically sync step counts and activity data via the Health API.
- **Premium Subscriptions**: In-app purchases handled via RevenueCat to unlock advanced analytics and features.
- **Customizable Profile**: Track weight, height, and goals with metric/imperial unit toggling.
- **Local Notifications**: Daily customizable workout reminders driven by `flutter_local_notifications`.
- **App Security**: Built-in App Lock feature using local biometrics.

## 🛠 Tech Stack
- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: [Provider](https://pub.dev/packages/provider) (Decoupled multi-provider architecture)
- **Backend/Database**: [Firebase](https://firebase.google.com/) (Auth, Cloud Firestore)
- **In-App Purchases**: [RevenueCat](https://www.revenuecat.com/) (`purchases_flutter`)
- **Health Data**: `health` package for Google Fit integration
- **Security**: `flutter_dotenv` for environment variable injection, `local_auth` for biometrics

## 📂 Folder Structure
```text
lib/
├── models/         # Strongly-typed data models (UserProfile, FitnessProgress)
├── providers/      # State management (AuthProvider, SettingsProvider, FitnessDataProvider)
├── screens/        # UI Views (HomeScreen, LoginScreen, SettingsScreen, ProfileScreen, etc.)
├── utils/          # Helper classes (DateUtility, NotificationService, LegalTexts)
├── widgets/        # Reusable UI components (EliteTextField, PrimaryActionButton, CustomPainters)
└── main.dart       # App entry point and Provider injection configuration
```

## 🚀 Setup & Installation

Follow these steps to run the project locally:

1. **Clone the repository**
   ```bash
   git clone https://github.com/kariyawasamnaveen/fitness-tracker-app.git
   cd fitness-tracker-app
   ```

2. **Configure Environment Variables**
   Create a `.env` file in the root directory of the project and add your API keys:
   ```env
   # RevenueCat API Keys
   REVENUECAT_APPLE_KEY=your_apple_api_key_here
   REVENUECAT_GOOGLE_KEY=your_google_api_key_here
   ```

3. **Install Dependencies**
   Fetch all required packages:
   ```bash
   flutter pub get
   ```

4. **Run the App**
   Connect your physical device or launch an emulator, then run:
   ```bash
   flutter run
   ```

## 📸 Screenshots

*(Replace the placeholder links below with actual screenshot URLs once available)*

| Home Dashboard | Settings | Profile |
| :---: | :---: | :---: |
| <img src="https://via.placeholder.com/250x500.png?text=Home+Screen" width="250"/> | <img src="https://via.placeholder.com/250x500.png?text=Settings+Screen" width="250"/> | <img src="https://via.placeholder.com/250x500.png?text=Profile+Screen" width="250"/> |

---
*Developed by [Naveen Kariyawasam](https://github.com/kariyawasamnaveen)*
