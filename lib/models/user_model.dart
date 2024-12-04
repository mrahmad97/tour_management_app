class UserModel {
  final String uid;
  final String? displayName;
  final String email;
  final String? userType;

  UserModel({
    required this.uid,
    this.displayName,
    required this.email,
    this.userType,
  });

  // This method allows us to create a new instance with modified values (like a copy constructor)
  UserModel copyWith({
    String? displayName,
    String? email,
    String? userType,
  }) {
    return UserModel(
      uid: this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      userType: userType ?? this.userType,
    );
  }
}
