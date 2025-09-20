import 'package:flutter_test/flutter_test.dart';
import 'package:dpr_car_rentals/src/models/NotificationModel.dart';
import 'package:dpr_car_rentals/src/repository/NotificationRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Set up Firebase mocks
  setUpAll(() async {
    // Initialize Firebase with mock data
    await Firebase.initializeApp(
      name: 'test',
      options: const FirebaseOptions(
        apiKey: 'test',
        appId: 'test',
        messagingSenderId: 'test',
        projectId: 'test',
      ),
    );
  });

  group('Notification Functionality', () {
    late NotificationRepository repository;

    setUp(() {
      repository = NotificationRepositoryImpl();
    });

    test('Notification model can be created and converted to map', () {
      final notification = NotificationModel(
        id: 'test_id',
        userId: 'user_123',
        title: 'Test Notification',
        message: 'This is a test notification',
        type: NotificationType.chatMessage,
        timestamp: DateTime.now(),
      );

      final map = notification.toMap();
      expect(map['userId'], 'user_123');
      expect(map['title'], 'Test Notification');
      expect(map['message'], 'This is a test notification');
      expect(map['type'], 'chatMessage');
    });

    test('Notification repository can be instantiated', () {
      expect(repository, isNotNull);
      expect(repository, isA<NotificationRepositoryImpl>());
    });
  });
}
