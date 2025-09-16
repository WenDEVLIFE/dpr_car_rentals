# dpr_car_rentals

This system is made for our client to help his car business rental more smooth and flexible

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Setup Instructions

### Environment Variables
1. Create a `.env` file in the `assets/env/` directory
2. Copy the contents from `.env.example` and fill in your credentials

### Gmail SMTP Setup
To enable email verification during registration:
1. Enable 2-factor authentication on your Gmail account
2. Generate an App Password:
   - Go to your Google Account settings
   - Navigate to Security > 2-Step Verification > App passwords
   - Generate a new app password for "Mail"
3. Add your credentials to the `.env` file:
   ```
   GOOGLE_EMAIL=your_email@gmail.com
   GOOGLE_APP_PASSWORD=your_generated_app_password
   ```

### Firebase Setup
1. Create a Firebase project at https://console.firebase.google.com/
2. Add your Android and iOS app configurations
3. Download the `google-services.json` and `GoogleService-Info.plist` files
4. Place them in the appropriate directories:
   - Android: `android/app/`
   - iOS: `ios/Runner/`
5. Add your Firebase configuration to the `.env` file

## Running the Application
```bash
flutter pub get
flutter run
```