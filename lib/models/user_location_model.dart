class UserLocationModel {
  final String userId;
  final double latitude;
  final double longitude;
  final String username;
  final String groupId;

  UserLocationModel({
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.username,
    required this.groupId,
  });

  factory UserLocationModel.fromMap(String userId, Map<String, dynamic> map) {
    return UserLocationModel(
      userId: userId,
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      username: map['username'] ?? '',
      groupId: map['groupId'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'username': username,
      'groupId': groupId,
    };
  }
}
