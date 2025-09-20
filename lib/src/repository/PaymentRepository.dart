import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/PaymentModel.dart';

abstract class PaymentRepository {
  Stream<List<PaymentModel>> getAllPayments();
  Stream<List<PaymentModel>> getPaymentsByUser(String userId);
  Stream<List<PaymentModel>> getPaymentsByOwner(String ownerId);
  Stream<List<PaymentModel>> getPaymentsByStatus(PaymentStatus status);
  Future<PaymentModel?> getPaymentById(String paymentId);
  Future<PaymentModel?> getPaymentByReservationId(String reservationId);
  Future<void> addPayment(PaymentModel payment);
  Future<void> updatePayment(String paymentId, PaymentModel payment);
  Future<void> updatePaymentStatus(String paymentId, PaymentStatus status);
  Future<void> deletePayment(String paymentId);
}

class PaymentRepositoryImpl extends PaymentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<PaymentModel>> getAllPayments() {
    return _firestore
        .collection('payments')
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Stream<List<PaymentModel>> getPaymentsByUser(String userId) {
    return _firestore
        .collection('payments')
        .where('UserID', isEqualTo: userId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Stream<List<PaymentModel>> getPaymentsByOwner(String ownerId) {
    return _firestore
        .collection('payments')
        .where('OwnerID', isEqualTo: ownerId)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Stream<List<PaymentModel>> getPaymentsByStatus(PaymentStatus status) {
    return _firestore
        .collection('payments')
        .where('Status', isEqualTo: status.toString().split('.').last)
        .orderBy('CreatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Future<PaymentModel?> getPaymentById(String paymentId) async {
    try {
      final doc = await _firestore.collection('payments').doc(paymentId).get();
      if (doc.exists) {
        return PaymentModel.fromDocument(doc);
      }
      return null;
    } catch (e) {
      print('Error getting payment by ID: $e');
      return null;
    }
  }

  @override
  Future<PaymentModel?> getPaymentByReservationId(String reservationId) async {
    try {
      final snapshot = await _firestore
          .collection('payments')
          .where('ReservationID', isEqualTo: reservationId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return PaymentModel.fromDocument(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting payment by reservation ID: $e');
      return null;
    }
  }

  @override
  Future<void> addPayment(PaymentModel payment) async {
    try {
      final docRef = _firestore.collection('payments').doc();
      final paymentWithId = payment.copyWith(id: docRef.id);
      await docRef.set(paymentWithId.toMap());
    } catch (e) {
      print('Error adding payment: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePayment(String paymentId, PaymentModel payment) async {
    try {
      await _firestore
          .collection('payments')
          .doc(paymentId)
          .update(payment.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      print('Error updating payment: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePaymentStatus(
      String paymentId, PaymentStatus status) async {
    try {
      await _firestore.collection('payments').doc(paymentId).update({
        'Status': status.toString().split('.').last,
        'UpdatedAt': Timestamp.now(),
      });
    } catch (e) {
      print('Error updating payment status: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    try {
      await _firestore.collection('payments').doc(paymentId).delete();
    } catch (e) {
      print('Error deleting payment: $e');
      rethrow;
    }
  }
}
