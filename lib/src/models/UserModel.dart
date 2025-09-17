class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['UserID'] ?? '',
      email: map['Email'] ?? '',
      fullName: map['FullName'] ?? '',
      role: map['Role'] ?? 'user',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'UserID': uid,
      'Email': email,
      'FullName': fullName,
      'Role': role,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
