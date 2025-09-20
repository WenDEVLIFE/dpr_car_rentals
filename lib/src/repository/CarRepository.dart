import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/CarModel.dart';
import '../helpers/NotificationHelper.dart';

abstract class CarRepository {
  Stream<List<CarModel>> getAllCars();
  Stream<List<CarModel>> getCarsByOwner(String ownerId);
  Stream<List<CarModel>> getPendingCars();
  Stream<List<CarModel>> getActiveCars();
  Future<void> addCar(CarModel car);
  Future<void> updateCar(String carId, CarModel car);
  Future<void> deleteCar(String carId);
  Future<void> approveCar(String carId);
  Future<void> rejectCar(String carId, String reason);
  Future<String?> uploadCarPhoto(String carId, File photo);
  Future<String?> updateCarPhoto(
      String carId, File newPhoto, String? oldPhotoUrl);
  Future<void> deleteCarPhoto(String photoUrl);
}

class CarRepositoryImpl extends CarRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Stream<List<CarModel>> getAllCars() {
    return _firestore.collection('cars').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CarModel.fromDocument(doc)).toList();
    });
  }

  @override
  Stream<List<CarModel>> getCarsByOwner(String ownerId) {
    return _firestore
        .collection('cars')
        .where('OwnerID', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CarModel.fromDocument(doc)).toList();
    });
  }

  @override
  Stream<List<CarModel>> getPendingCars() {
    return _firestore
        .collection('cars')
        .where('Status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CarModel.fromDocument(doc)).toList();
    });
  }

  @override
  Stream<List<CarModel>> getActiveCars() {
    return _firestore
        .collection('cars')
        .where('Status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CarModel.fromDocument(doc)).toList();
    });
  }

  @override
  Future<void> addCar(CarModel car) async {
    final docRef = _firestore.collection('cars').doc();
    final carWithId = car.copyWith(id: docRef.id);
    await docRef.set(carWithId.toMap());
  }

  @override
  Future<void> updateCar(String carId, CarModel car) async {
    await _firestore.collection('cars').doc(carId).update(car.toMap());
  }

  @override
  Future<void> deleteCar(String carId) async {
    // Get car data first to delete photo if exists
    final carDoc = await _firestore.collection('cars').doc(carId).get();
    if (carDoc.exists) {
      final car = CarModel.fromDocument(carDoc);
      if (car.photoUrl != null) {
        await deleteCarPhoto(car.photoUrl!);
      }
    }

    await _firestore.collection('cars').doc(carId).delete();
  }

  @override
  Future<void> approveCar(String carId) async {
    // Get car details before updating
    final carDoc = await _firestore.collection('cars').doc(carId).get();
    if (carDoc.exists) {
      final carData = carDoc.data() as Map<String, dynamic>;
      final ownerId = carData['OwnerID'] as String?;
      final carName = '${carData['Name'] ?? ''} ${carData['Model'] ?? ''}';

      // Update car status
      await _firestore.collection('cars').doc(carId).update({
        'Status': 'active',
        'UpdatedAt': Timestamp.now(),
      });

      // Send notification to owner
      if (ownerId != null) {
        await NotificationHelper.sendCarApprovalNotification(
          ownerId: ownerId,
          carName: carName,
          approved: true,
        );
      }
    } else {
      await _firestore.collection('cars').doc(carId).update({
        'Status': 'active',
        'UpdatedAt': Timestamp.now(),
      });
    }
  }

  @override
  Future<void> rejectCar(String carId, String reason) async {
    // Get car details before updating
    final carDoc = await _firestore.collection('cars').doc(carId).get();
    if (carDoc.exists) {
      final carData = carDoc.data() as Map<String, dynamic>;
      final ownerId = carData['OwnerID'] as String?;
      final carName = '${carData['Name'] ?? ''} ${carData['Model'] ?? ''}';

      // Update car status
      await _firestore.collection('cars').doc(carId).update({
        'Status': 'rejected',
        'RejectionReason': reason,
        'UpdatedAt': Timestamp.now(),
      });

      // Send notification to owner
      if (ownerId != null) {
        await NotificationHelper.sendCarApprovalNotification(
          ownerId: ownerId,
          carName: carName,
          approved: false,
          rejectionReason: reason,
        );
      }
    } else {
      await _firestore.collection('cars').doc(carId).update({
        'Status': 'rejected',
        'RejectionReason': reason,
        'UpdatedAt': Timestamp.now(),
      });
    }
  }

  @override
  Future<String?> uploadCarPhoto(String carId, File photo) async {
    try {
      final ref = _storage.ref().child('car_photos/$carId.jpg');
      final uploadTask = ref.putFile(photo);
      final snapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading car photo: $e');
      return null;
    }
  }

  @override
  Future<String?> updateCarPhoto(
      String carId, File newPhoto, String? oldPhotoUrl) async {
    try {
      // Delete old photo if it exists
      if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
        await deleteCarPhoto(oldPhotoUrl);
      }

      // Upload new photo
      return await uploadCarPhoto(carId, newPhoto);
    } catch (e) {
      print('Error updating car photo: $e');
      return null;
    }
  }

  @override
  Future<void> deleteCarPhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting car photo: $e');
    }
  }
}
