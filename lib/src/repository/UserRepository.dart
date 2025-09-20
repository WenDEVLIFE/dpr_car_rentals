import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/UserModel.dart';
import '../models/ActivityModel.dart';
import 'ActivityRepository.dart';

abstract class UserRepository {
  Stream<List<UserModel>> getUsers();
  Future<void> addUser(UserModel user);
  Future<void> updateUser(String uid, UserModel user);
  Future<void> updateUserDetails(String uid, Map<String, dynamic> details);
  Future<void> deleteUser(String uid);
  Future<void> logActivity(ActivityModel activity);
}

class UserRepositoryImpl extends UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ActivityRepository _activityRepository = ActivityRepositoryImpl();

  @override
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> addUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());

    // Log activity
    await logActivity(ActivityModel(
      id: '',
      type: ActivityType.userAdded,
      title: 'User Added',
      description: '${user.fullName} was added to the system',
      userId: null,
      userName: 'Admin',
      targetId: null,
      targetName: user.fullName,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<void> updateUser(String uid, UserModel user) async {
    final oldUser = await _firestore.collection('users').doc(uid).get();
    final oldUserData = oldUser.data();

    await _firestore.collection('users').doc(uid).update(user.toMap());

    // Log activity
    await logActivity(ActivityModel(
      id: '',
      type: ActivityType.userUpdated,
      title: 'User Updated',
      description: '${user.fullName} profile was updated',
      userId: null,
      userName: 'Admin',
      targetId: null,
      targetName: user.fullName,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<void> updateUserDetails(
      String uid, Map<String, dynamic> details) async {
    await _firestore.collection('users').doc(uid).update(details);
  }

  @override
  Future<void> deleteUser(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();
    final userName = userData?['FullName'] ?? 'Unknown User';

    await _firestore.collection('users').doc(uid).delete();

    // Log activity
    await logActivity(ActivityModel(
      id: '',
      type: ActivityType.userDeleted,
      title: 'User Deleted',
      description: '$userName was deleted from the system',
      userId: null,
      userName: 'Admin',
      targetId: uid,
      targetName: userName,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Future<void> logActivity(ActivityModel activity) async {
    await _activityRepository.addActivity(activity);
  }
}
