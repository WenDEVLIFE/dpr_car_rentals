class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role;
  final String? phoneNumber;
  final String? driverLicenseNumber;
  final String? paymentPreference;
  final String? address;
  final String? bankName;
  final String? bankAccountNumber;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.driverLicenseNumber,
    this.paymentPreference,
    this.address,
    this.bankName,
    this.bankAccountNumber,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['UserID'] ?? '',
      email: map['Email'] ?? '',
      fullName: map['FullName'] ?? '',
      role: map['Role'] ?? 'user',
      phoneNumber: map['PhoneNumber']?.toString(),
      driverLicenseNumber: map['DriverLicenseNumber']?.toString(),
      paymentPreference: map['PaymentPreference']?.toString(),
      address: map['Address']?.toString(),
      bankName: map['BankName']?.toString(),
      bankAccountNumber: map['BankAccountNumber']?.toString(),
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
      'PhoneNumber': phoneNumber,
      'DriverLicenseNumber': driverLicenseNumber,
      'PaymentPreference': paymentPreference,
      'Address': address,
      'BankName': bankName,
      'BankAccountNumber': bankAccountNumber,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? role,
    String? phoneNumber,
    String? driverLicenseNumber,
    String? paymentPreference,
    String? address,
    String? bankName,
    String? bankAccountNumber,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      paymentPreference: paymentPreference ?? this.paymentPreference,
      address: address ?? this.address,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
