import 'package:firebase_database/firebase_database.dart';
import '../models/user_location_model.dart';
import 'dart:async';

class FetchRealtimeService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  StreamSubscription? _streamSubscription;

  void startFetchingUsers(
      String? groupId,
      String currentUserId,
      Function(List<UserLocationModel>, UserLocationModel?) onUpdate,
      ) {
    _streamSubscription = _databaseRef.child('users').onValue.listen((event) {
      final usersData = event.snapshot.value;

      if (usersData is Map<Object?, Object?>) {
        List<UserLocationModel> filteredUsers = [];
        UserLocationModel? currentUserData;

        usersData.forEach((key, value) {
          if (key is String && value is Map<Object?, Object?>) {
            final locationData = value['location'] as Map<Object?, Object?>?;

            if (locationData != null &&
                locationData['groupId'] == groupId &&
                locationData['latitude'] != null &&
                locationData['longitude'] != null) {
              final user = UserLocationModel.fromMap(
                key,
                {
                  'latitude': locationData['latitude'],
                  'longitude': locationData['longitude'],
                  'username': locationData['username'] ?? '',
                  'groupId': locationData['groupId'] ?? '',
                },
              );
              filteredUsers.add(user);

              if (key == currentUserId) {
                currentUserData = user;
              }
            }
          }
        });

        // Print statements to debug user data
        print('Filtered Users Data: ${filteredUsers.map((e) => e.toJson()).toList()}');
        print('Current User Data: ${currentUserData?.toJson()}');

        onUpdate(filteredUsers, currentUserData);
      }
    }, onError: (error) {
      print('Error listening to user updates: $error');
    });
  }

  void stopFetchingUsers() {
    _streamSubscription?.cancel();
  }
}
