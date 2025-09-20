import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ActivityModel.dart';

abstract class ActivityRepository {
  Stream<List<ActivityModel>> getAllActivities();
  Stream<List<ActivityModel>> getRecentActivities({int limit = 10});
  Future<void> addActivity(ActivityModel activity);
  Future<void> deleteOldActivities({int olderThanDays = 30});
}

class ActivityRepositoryImpl extends ActivityRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ActivityModel>> getAllActivities() {
    return _firestore
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Stream<List<ActivityModel>> getRecentActivities({int limit = 10}) {
    return _firestore
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ActivityModel.fromDocument(doc))
          .toList();
    });
  }

  @override
  Future<void> addActivity(ActivityModel activity) async {
    try {
      final docRef = _firestore.collection('activities').doc();
      final activityWithId = activity.copyWith(id: docRef.id);
      await docRef.set(activityWithId.toMap());
    } catch (e) {
      print('Error adding activity: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteOldActivities({int olderThanDays = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: olderThanDays));
      final snapshot = await _firestore
          .collection('activities')
          .where('timestamp', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error deleting old activities: $e');
      rethrow;
    }
  }
}
