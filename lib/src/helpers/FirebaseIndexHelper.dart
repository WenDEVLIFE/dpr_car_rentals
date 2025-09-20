class FirebaseIndexHelper {
  static const String projectId = 'dprcarrental-7987e';

  /// Print Firebase index creation links to console when index errors occur
  static void handleIndexError(
    dynamic error,
    String queryDescription, {
    String? collection,
    List<String>? fields,
    String? orderBy,
  }) {
    final errorString = error.toString();

    // Check if it's a Firestore index error
    if (errorString.contains('index') ||
        errorString.contains('composite') ||
        errorString.contains('FAILED_PRECONDITION') ||
        errorString.contains('requires an index')) {
      print('\n🔥🔥🔥 FIREBASE INDEX REQUIRED 🔥🔥🔥');
      print('📍 Query: $queryDescription');
      print('⚠️  Error: $errorString');

      // Generate specific index links based on common queries
      _printIndexLinks(queryDescription);

      if (collection != null && fields != null) {
        print('\n📋 Manual Index Creation:');
        print('Collection: $collection');
        print('Fields:');
        for (String field in fields) {
          print('  • $field');
        }
        if (orderBy != null) {
          print('Order by: $orderBy');
        }
      }

      print(
          '🔗 General Firebase Console: https://console.firebase.google.com/project/$projectId/firestore/indexes');
      print('===============================================\n');
    }
  }

  static void _printIndexLinks(String queryDescription) {
    print('\n🔗 CLICK THESE LINKS TO CREATE INDEXES:');

    switch (queryDescription.toLowerCase()) {
      case 'getreservationsbyownerandstatus':
      case 'owner bookings by status':
        print('👤 Owner Reservations by Status:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoKCgZPd25lcklEEAEaCgoGU3RhdHVzEAEaDAoIQ3JlYXRlZEF0EAI');
        break;

      case 'getreservationsbyuser':
      case 'user bookings':
        print('👤 User Reservations:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoKCgZVc2VySUQQARoMCghDcmVhdGVkQXQQAg');
        break;

      case 'getreservationsbystatus':
      case 'reservations by status':
        print('📊 All Reservations by Status:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoKCgZTdGF0dXMQARoMCghDcmVhdGVkQXQQAg');
        break;

      case 'getuseractivereviews':
      case 'user active reservations':
        print('✅ User Active Reservations:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoKCgZVc2VySUQQARoKCgZTdGF0dXMQAQ');
        break;

      case 'getcaravailability':
      case 'car availability check':
        print('🚗 Car Availability Check:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoICgRDYXJJRBABCgpCCFN0YXR1cw');
        break;

      case 'getpaymentsByowner':
      case 'owner payments':
        print('💰 Owner Payments:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3BheW1lbnRzL2luZGV4ZXMvXxABGgoKBk93bmVySUQQARoMCghDcmVhdGVkQXQQAg');
        break;

      case 'getpaymentsbyuser':
      case 'user payments':
        print('💳 User Payments:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3BheW1lbnRzL2luZGV4ZXMvXxABGgoKBlVzZXJJRBABGgwKCENyZWF0ZWRBdBAC');
        break;

      case 'getcarsbyowner':
      case 'owner cars':
        print('🚗 Owner Cars:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2NhcnMvaW5kZXhlcy9fEAEaCgoGT3duZXJJRBABGgwKCENyZWF0ZWRBdBAC');
        break;

      case 'getactivecars':
      case 'active cars':
        print('✅ Active Cars:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2NhcnMvaW5kZXhlcy9fEAEaCgoGU3RhdHVzEAEaDAoIQ3JlYXRlZEF0EAI');
        break;

      case 'getusernotifications':
      case 'user notifications':
        print('🔔 User Notifications:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL25vdGlmaWNhdGlvbnMvaW5kZXhlcy9fEAEaCgoHVXNlcklEEAEaDAoIdGltZXN0YW1wEAI');
        break;

      case 'getunreadcount':
      case 'unread notifications':
        print('🔔 Unread Notifications:');
        print(
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL25vdGlmaWNhdGlvbnMvaW5kZXhlcy9fEAEaCgoHVXNlcklEEAEaCgoHaXNSZWFkEAE');
        break;

      default:
        print('🔧 Common Indexes:');
        print(
            'General reservations: https://console.firebase.google.com/project/$projectId/firestore/indexes');
        break;
    }
  }

  /// Print all required indexes for the booking system
  static void printAllRequiredIndexes() {
    print('\n🔥 ALL REQUIRED FIREBASE INDEXES FOR BOOKING SYSTEM 🔥');
    print('Copy and paste these URLs to create all necessary indexes:\n');

    final indexes = [
      {
        'name': '👤 Owner Reservations by Status',
        'description': 'Required for owner booking management tabs',
        'url':
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoKCgZPd25lcklEEAEaCgoGU3RhdHVzEAEaDAoIQ3JlYXRlZEF0EAI'
      },
      {
        'name': '👤 User Reservations',
        'description': 'Required for user booking history',
        'url':
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoKCgZVc2VySUQQARoMCghDcmVhdGVkQXQQAg'
      },
      {
        'name': '📊 Reservations by Status',
        'description': 'Required for admin dashboard',
        'url':
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3Jlc2VydmF0aW9ucy9pbmRleGVzL18QARoKCgZTdGF0dXMQARoMCghDcmVhdGVkQXQQAg'
      },
      {
        'name': '💰 Owner Payments',
        'description': 'Required for owner payment history',
        'url':
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3BheW1lbnRzL2luZGV4ZXMvXxABGgoKBk93bmVySUQQARoMCghDcmVhdGVkQXQQAg'
      },
      {
        'name': '💳 User Payments',
        'description': 'Required for user payment history',
        'url':
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL3BheW1lbnRzL2luZGV4ZXMvXxABGgoKBlVzZXJJRBABGgwKCENyZWF0ZWRBdBAC'
      },
      {
        'name': '🚗 Owner Cars',
        'description': 'Required for owner car management',
        'url':
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL2NhcnMvaW5kZXhlcy9fEAEaCgoGT3duZXJJRBABGgwKCENyZWF0ZWRBdBAC'
      },
      {
        'name': '🔔 User Notifications',
        'description': 'Required for notification system',
        'url':
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL25vdGlmaWNhdGlvbnMvaW5kZXhlcy9fEAEaCgoHVXNlcklEEAEaDAoIdGltZXN0YW1wEAI'
      },
      {
        'name': '🔔 Unread Notifications',
        'description': 'Required for unread notification count',
        'url':
            'https://console.firebase.google.com/v1/r/project/$projectId/firestore/indexes?create_composite=Clhwcm9qZWN0cy9kcHJjYXJyZW50YWwtNzk4N2UvZGF0YWJhc2VzLyhkZWZhdWx0KS9jb2xsZWN0aW9uR3JvdXBzL25vdGlmaWNhdGlvbnMvaW5kZXhlcy9fEAEaCgoHVXNlcklEEAEaCgoHaXNSZWFkEAE'
      },
    ];

    for (int i = 0; i < indexes.length; i++) {
      final index = indexes[i];
      print('${i + 1}. ${index['name']}');
      print('   ${index['description']}');
      print('   ${index['url']}\n');
    }

    print(
        '🎯 Quick Setup: Open each URL above in your browser and click "Create Index"');
    print('⏱️  Index creation usually takes 1-5 minutes');
    print('========================================\n');
  }
}
