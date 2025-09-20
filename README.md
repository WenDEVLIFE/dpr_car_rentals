# DPR Car Rentals - Comprehensive Car Rental Management System

This is a full-featured car rental management system built with Flutter and Firebase, designed to streamline car rental business operations for owners, users, and administrators.

## Table of Contents
- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [User Roles](#user-roles)
- [Getting Started](#getting-started)
- [Setup Instructions](#setup-instructions)
- [Firebase Configuration](#firebase-configuration)
- [Running the Application](#running-the-application)
- [System Components](#system-components)
- [Notification System](#notification-system)
- [Testing](#testing)
- [Deployment](#deployment)

## Overview

DPR Car Rentals is a comprehensive mobile application that connects car owners with potential renters, providing a seamless platform for car rental transactions. The system includes features for user registration, car listing, booking management, payment processing, real-time chat, and notifications.

## System Architecture

The application follows a clean architecture pattern with separation of concerns:

```
lib/
├── src/
│   ├── bloc/              # Business Logic Components (BLoC pattern)
│   ├── models/            # Data models
│   ├── repository/        # Data access layer
│   ├── helpers/           # Utility functions and helpers
│   ├── services/          # External service integrations
│   ├── views/             # UI screens organized by user role
│   │   ├── admin/         # Admin-specific views
│   │   ├── owner/         # Car owner-specific views
│   │   └── user/          # End user-specific views
│   └── widget/            # Reusable UI components
└── main.dart             # Application entry point
```

## Key Features

### User Management
- Role-based authentication (User, Owner, Admin)
- Email verification during registration
- Profile management
- Session handling

### Car Management
- Car listing with detailed information
- Photo gallery with zoom capability
- Car status tracking (Available, Rented, Maintenance)
- Owner car inventory management

### Booking System
- Car search and filtering
- Reservation creation and management
- Status tracking (Pending, Approved, Rejected, Completed)
- Booking history

### Payment Processing
- Integrated payment workflows
- Transaction history
- Earnings tracking for owners

### Communication
- Real-time chat between users and owners
- Message history and notifications
- Unread message tracking

### Notifications
- Real-time notification system
- Multiple notification types (Chat, Booking, Car Approval)
- Unread count badges
- Notification history

### Admin Dashboard
- User and owner management
- Car approval workflows
- Booking oversight
- System analytics

## Technology Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Flutter BLoC
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **Real-time Features**: Firestore snapshots
- **UI Components**: Material Design
- **Email Service**: Gmail SMTP
- **Payment Integration**: [Specify payment provider if applicable]

## User Roles

### 1. End User
- Browse and search available cars
- View car details and photos
- Book cars with preferred dates
- Chat with car owners
- Manage bookings
- Receive notifications
- Make payments

### 2. Car Owner
- List cars for rent
- Manage car availability and pricing
- Review and respond to booking requests
- Chat with potential renters
- Process payments
- Track earnings
- Receive notifications

### 3. Administrator
- Manage user accounts
- Approve/reject car listings
- Monitor system activity
- View analytics and reports
- Handle disputes

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio or VS Code
- Firebase account
- Gmail account for email verification

### Environment Variables
1. Create a `.env` file in the root directory
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

## Firebase Configuration

### Project Setup
1. Create a Firebase project at https://console.firebase.google.com/
2. Add your Android and iOS app configurations
3. Download the `google-services.json` and `GoogleService-Info.plist` files
4. Place them in the appropriate directories:
   - Android: `android/app/`
   - iOS: `ios/Runner/`
5. Add your Firebase configuration to the `.env` file

### Required Firebase Indexes

The system requires several Firestore composite indexes for optimal performance. These are automatically printed to the console when the app starts:

1. **Owner Reservations by Status**
   - Collection: reservations
   - Fields: OwnerID (Ascending), Status (Ascending), CreatedAt (Descending)

2. **User Reservations**
   - Collection: reservations
   - Fields: UserID (Ascending), CreatedAt (Descending)

3. **Reservations by Status**
   - Collection: reservations
   - Fields: Status (Ascending), CreatedAt (Descending)

4. **Owner Payments**
   - Collection: payments
   - Fields: OwnerID (Ascending), CreatedAt (Descending)

5. **User Payments**
   - Collection: payments
   - Fields: UserID (Ascending), CreatedAt (Descending)

6. **Owner Cars**
   - Collection: cars
   - Fields: OwnerID (Ascending), CreatedAt (Descending)

7. **User Notifications**
   - Collection: notifications
   - Fields: UserID (Ascending), Timestamp (Descending)

8. **Unread Notifications**
   - Collection: notifications
   - Fields: UserID (Ascending), IsRead (Ascending)

## Running the Application

```bash
# Install dependencies
flutter pub get

# Run the application
flutter run
```

### Development Commands

```bash
# Hot reload
flutter run --hot

# Run tests
flutter test

# Build for release
flutter build apk  # Android
flutter build ios  # iOS
```

## System Components

### Authentication System
- Firebase Authentication integration
- Email/password registration and login
- Role-based access control
- Session management

### Car Management
- CRUD operations for car listings
- Image upload and management
- Car status tracking
- Search and filtering capabilities

### Booking Workflow
1. User searches and selects a car
2. User submits booking request
3. Owner reviews and approves/rejects request
4. User makes payment
5. Booking completion and feedback

### Chat System
- Real-time messaging between users and owners
- Message history persistence
- Unread message tracking
- Notification integration

### Payment System
- Transaction processing
- Payment history tracking
- Earnings calculation for owners
- Revenue reporting

## Notification System

The notification system provides real-time alerts for important events:

### Notification Types
- **Chat Messages**: New messages from other users
- **Car Approvals**: Admin approval/rejection of car listings
- **Booking Status**: Updates on booking requests
- **New Bookings**: Notifications to owners about new booking requests
- **System Alerts**: General system notifications

### Implementation Details
- Built with Flutter BLoC for state management
- Firebase Firestore for data storage
- Real-time updates using Firestore snapshots
- Unread count tracking with badges
- Notification history with read/unread status

### Firebase Indexes for Notifications
The system automatically prints setup URLs for required Firebase indexes:
- User Notifications index for retrieving notifications by user and timestamp
- Unread Notifications index for counting unread notifications

## Testing

### Unit Tests
Run unit tests to verify individual component functionality:
```bash
flutter test
```

### Integration Tests
Integration tests verify the interaction between components.

### UI Tests
Widget tests ensure UI components render correctly.

## Deployment

### Android
1. Update `android/app/build.gradle` with your app details
2. Generate signing key
3. Build release APK:
   ```bash
   flutter build apk --release
   ```

### iOS
1. Update `ios/Runner.xcworkspace` with your app details
2. Configure signing in Xcode
3. Build for release:
   ```bash
   flutter build ios --release
   ```

### Firebase Deployment
1. Set up Firebase Hosting (if using web version)
2. Deploy Firestore security rules
3. Configure Firebase Functions (if applicable)

## Troubleshooting

### Common Issues

1. **Firebase Index Errors**
   - Solution: Click the automatically generated index URLs printed to the console

2. **Authentication Failures**
   - Verify Firebase configuration files
   - Check environment variables

3. **Notification Not Showing**
   - Ensure NotificationBloc is properly provided
   - Check Firebase index requirements

### Debugging Tools
- Use DebugHelper functions for system diagnostics
- Check console logs for error messages
- Verify Firebase rules in Firebase Console

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

## License

This project is proprietary and confidential. All rights reserved.

## Support

For support, contact the development team or refer to the project documentation.