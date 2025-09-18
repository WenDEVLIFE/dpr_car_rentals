import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/UserModel.dart';

abstract class UserRepository {
  Stream<List<UserModel>> getUsers();
  Future<void> addUser(UserModel user);
  Future<void> updateUser(String uid, UserModel user);
  Future<void> updateUserDetails(String uid, Map<String, dynamic> details);
  Future<void> deleteUser(String uid);
}

class UserRepositoryImpl extends UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<UserModel>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  @override
  Future<void> addUser(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  @override
  Future<void> updateUser(String uid, UserModel user) async {
    await _firestore.collection('users').doc(uid).update(user.toMap());
  }

  @override
  Future<void> updateUserDetails(
      String uid, Map<String, dynamic> details) async {
    await _firestore.collection('users').doc(uid).update(details);
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }
}
