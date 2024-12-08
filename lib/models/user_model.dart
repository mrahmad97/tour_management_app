class UserModel {
  final String uid;
  final String? displayName;
  final String email;
  final String? userType;
  final String phoneNumber;

  UserModel({
    required this.uid,
    this.displayName,
    required this.email,
    required this.userType,
    required this.phoneNumber,
  });

  // Factory method to create a UserModel from Firestore data
  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      displayName: data['name'] as String?,
      email: data['email'] as String? ?? '',
      userType: data['userType'] as String?,
      phoneNumber: data['phoneNumber'] as String? ?? 'Unknown',
    );
  }
  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? userType,
    String? phoneNumber,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }


  @override
  String toString() {
    return 'UserModel{uid: $uid, displayName: $displayName, email: $email, userType: $userType, phoneNumber: $phoneNumber}';
  }
}
