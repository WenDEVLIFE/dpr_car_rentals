import 'package:cloud_firestore/cloud_firestore.dart';
import '../bloc/FeedbackState.dart';

abstract class FeedbackRepository {
  Stream<List<FeedbackItem>> getFeedbacks();
  Future<void> addFeedback(FeedbackItem feedback);
  Future<void> updateFeedback(String feedbackId, Map<String, dynamic> updates);
  Future<void> deleteFeedback(String feedbackId);
  Future<void> markFeedbackAsRead(String feedbackId);
}

class FeedbackRepositoryImpl extends FeedbackRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<FeedbackItem>> getFeedbacks() {
    return _firestore.collection('feedbacks').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => FeedbackItem.fromMap(doc.data()))
          .toList();
    });
  }

  @override
  Future<void> addFeedback(FeedbackItem feedback) async {
    await _firestore
        .collection('feedbacks')
        .doc(feedback.id)
        .set(feedback.toMap());
  }

  @override
  Future<void> updateFeedback(
      String feedbackId, Map<String, dynamic> updates) async {
    await _firestore.collection('feedbacks').doc(feedbackId).update(updates);
  }

  @override
  Future<void> deleteFeedback(String feedbackId) async {
    await _firestore.collection('feedbacks').doc(feedbackId).delete();
  }

  @override
  Future<void> markFeedbackAsRead(String feedbackId) async {
    await _firestore
        .collection('feedbacks')
        .doc(feedbackId)
        .update({'isRead': true});
  }
}
