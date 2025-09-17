import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String uid;
  final String email;
  final String fullName;
  final String role;
  UserModel({required this.uid, required this.email, required this.fullName, required this.role});

  factory UserModel.FromDocumentSnapshot(DocumentSnapshot doc){
    return UserModel(
      uid: doc.id,
      email: doc['Email'],
      fullName: doc['FullName'],
      role: doc['Role'],
    );
  }
}