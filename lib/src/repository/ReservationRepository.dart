import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ReservationModel.dart';

abstract class ReservationRepository {
  Stream<List<ReservationModel>> getAllReservations();
  Stream<List<ReservationModel>> getReservationsByUser(String userId);
  Stream<List<ReservationModel>> getReservationsByOwner(String ownerId);
  Stream<List<ReservationModel>> getReservationsByStatus(
      ReservationStatus status);
  Stream<List<ReservationModel>> getReservationsByOwnerAndStatus(
      String ownerId, ReservationStatus status);
  Future<ReservationModel?> getReservationById(String reservationId);
  Future<List<ReservationModel>> getUserActiveReservations(String userId);
  Future<bool> hasUserActiveReservation(String userId);
  Future<bool> isCarAvailable(
      String carId, DateTime startDate, DateTime endDate,
      {String? excludeReservationId});
  Future<void> addReservation(ReservationModel reservation);
  Future<void> updateReservation(
      String reservationId, ReservationModel reservation);
  Future<void> updateReservationStatus(
      String reservationId, ReservationStatus status,
      {String? rejectionReason});
  Future<void> deleteReservation(String reservationId);
}

class ReservationRepositoryImpl extends ReservationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ReservationModel>> getAllReservations() {
    return _firestore
        .collection('reservations')
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReservationModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Stream<List<ReservationModel>> getReservationsByUser(String userId) {
    return _firestore
        .collection('reservations')
        .where('UserID', isEqualTo: userId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReservationModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Stream<List<ReservationModel>> getReservationsByOwner(String ownerId) {
    return _firestore
        .collection('reservations')
        .where('OwnerID', isEqualTo: ownerId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReservationModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Stream<List<ReservationModel>> getReservationsByStatus(
      ReservationStatus status) {
    return _firestore
        .collection('reservations')
        .where('Status', isEqualTo: status.toString().split('.').last)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReservationModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Stream<List<ReservationModel>> getReservationsByOwnerAndStatus(
      String ownerId, ReservationStatus status) {
    return _firestore
        .collection('reservations')
        .where('OwnerID', isEqualTo: ownerId)
        .where('Status', isEqualTo: status.toString().split('.').last)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReservationModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Future<ReservationModel?> getReservationById(String reservationId) async {
    try {
      final doc =
          await _firestore.collection('reservations').doc(reservationId).get();
      if (doc.exists) {
        return ReservationModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting reservation by ID: $e');
      return null;
    }
  }

  @override
  Future<List<ReservationModel>> getUserActiveReservations(
      String userId) async {
    try {
      final snapshot = await _firestore
          .collection('reservations')
          .where('UserID', isEqualTo: userId)
          .where('Status', whereIn: ['pending', 'approved', 'inUse']).get();

      return snapshot.docs
          .map((doc) => ReservationModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error getting user active reservations: $e');
      return [];
    }
  }

  @override
  Future<bool> hasUserActiveReservation(String userId) async {
    try {
      final activeReservations = await getUserActiveReservations(userId);
      return activeReservations.isNotEmpty;
    } catch (e) {
      print('Error checking user active reservation: $e');
      return false;
    }
  }

  @override
  Future<bool> isCarAvailable(
      String carId, DateTime startDate, DateTime endDate,
      {String? excludeReservationId}) async {
    try {
      Query query = _firestore
          .collection('reservations')
          .where('CarID', isEqualTo: carId)
          .where('Status', whereIn: ['pending', 'approved', 'inUse']);

      final snapshot = await query.get();

      for (var doc in snapshot.docs) {
        if (excludeReservationId != null && doc.id == excludeReservationId) {
          continue;
        }

        final reservation = ReservationModel.fromDocument(doc);

        // Check if dates overlap
        bool hasOverlap = startDate
                .isBefore(reservation.endDate.add(const Duration(days: 1))) &&
            endDate.isAfter(
                reservation.startDate.subtract(const Duration(days: 1)));

        if (hasOverlap) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking car availability: $e');
      return false;
    }
  }

  @override
  Future<void> addReservation(ReservationModel reservation) async {
    try {
      final docRef = _firestore.collection('reservations').doc();
      final reservationWithId = reservation.copyWith(id: docRef.id);
      await docRef.set(reservationWithId.toMap());
    } catch (e) {
      print('Error adding reservation: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateReservation(
      String reservationId, ReservationModel reservation) async {
    try {
      await _firestore
          .collection('reservations')
          .doc(reservationId)
          .update(reservation.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      print('Error updating reservation: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateReservationStatus(
      String reservationId, ReservationStatus status,
      {String? rejectionReason}) async {
    try {
      final updateData = {
        'Status': status.toString().split('.').last,
        'UpdatedAt': Timestamp.now(),
      };

      if (rejectionReason != null) {
        updateData['RejectionReason'] = rejectionReason;
      }

      await _firestore
          .collection('reservations')
          .doc(reservationId)
          .update(updateData);
    } catch (e) {
      print('Error updating reservation status: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteReservation(String reservationId) async {
    try {
      await _firestore.collection('reservations').doc(reservationId).delete();
    } catch (e) {
      print('Error deleting reservation: $e');
      rethrow;
    }
  }
}
