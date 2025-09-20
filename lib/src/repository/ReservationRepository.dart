import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ReservationModel.dart';
import '../models/CarModel.dart';
import '../models/ActivityModel.dart';
import 'ActivityRepository.dart';
import '../helpers/NotificationHelper.dart';

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
  final ActivityRepository _activityRepository = ActivityRepositoryImpl();

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

      // Get car details for notification
      final carDoc =
          await _firestore.collection('cars').doc(reservation.carId).get();
      String carName = 'car';
      if (carDoc.exists) {
        final carData = carDoc.data() as Map<String, dynamic>;
        carName = '${carData['Name'] ?? ''} ${carData['Model'] ?? ''}';
      }

      // Send notification to owner about new booking
      await NotificationHelper.sendNewBookingNotification(
        ownerId: reservation.ownerId,
        userName: reservation.fullName,
        carName: carName,
        reservationId: reservationWithId.id,
      );

      // Log activity
      await logActivity(ActivityModel(
        id: '',
        type: ActivityType.bookingCreated,
        title: 'New Booking Received',
        description:
            '${reservation.fullName} booked a car for ${reservation.durationInDays} days',
        userId: reservation.userId,
        userName: reservation.fullName,
        targetId: reservation.id,
        targetName: 'Car Booking',
        timestamp: DateTime.now(),
      ));
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
      // Get reservation details before updating
      final reservationDoc =
          await _firestore.collection('reservations').doc(reservationId).get();
      final reservationData = reservationDoc.data();
      final userName = reservationData?['FullName'] ?? 'Unknown User';
      final userId = reservationData?['UserID'] ?? '';
      final carId = reservationData?['CarID'] ?? '';

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

      // Get car details for notification
      String carName = 'car';
      if (carId.isNotEmpty) {
        final carDoc = await _firestore.collection('cars').doc(carId).get();
        if (carDoc.exists) {
          final carData = carDoc.data() as Map<String, dynamic>;
          carName = '${carData['Name'] ?? ''} ${carData['Model'] ?? ''}';
        }
      }

      // Send notification to user
      final statusString = status.toString().split('.').last;
      await NotificationHelper.sendBookingNotification(
        userId: userId,
        bookingTitle: carName,
        status: statusString,
        reason: rejectionReason,
        reservationId: reservationId,
      );

      // Log activity based on status
      ActivityType activityType;
      String activityTitle;
      String activityDescription;

      switch (status) {
        case ReservationStatus.approved:
          activityType = ActivityType.bookingApproved;
          activityTitle = 'Booking Approved';
          activityDescription = 'Booking for $userName was approved';
          break;
        case ReservationStatus.rejected:
          activityType = ActivityType.bookingRejected;
          activityTitle = 'Booking Rejected';
          activityDescription =
              'Booking for $userName was rejected${rejectionReason != null ? ': $rejectionReason' : ''}';
          break;
        case ReservationStatus.cancelled:
          activityType = ActivityType.bookingCancelled;
          activityTitle = 'Booking Cancelled';
          activityDescription = 'Booking for $userName was cancelled';
          break;
        default:
          return; // Don't log for other status changes
      }

      await logActivity(ActivityModel(
        id: '',
        type: activityType,
        title: activityTitle,
        description: activityDescription,
        userId: null,
        userName: 'Owner/Admin',
        targetId: reservationId,
        targetName: userName,
        timestamp: DateTime.now(),
        metadata: rejectionReason != null ? {'reason': rejectionReason} : null,
      ));
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

  Future<void> logActivity(ActivityModel activity) async {
    await _activityRepository.addActivity(activity);
  }
}
