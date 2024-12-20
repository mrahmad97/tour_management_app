import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class RealtimeDatabaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Start listening for location updates
  void startUpdatingLocation(String userId, String? username, String groupId) {
    // Set user as "online" in Firebase
    _setUserOnline(userId);
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    // Listen to location stream
    Geolocator.getPositionStream(
      locationSettings: locationSettings
    ).listen((position) {
      if (position != null) {
        _updateLocationInDatabase(userId, username??"Unknown", groupId, position);
      } else {
        print('Error fetching location');
      }
    });
  }

  // Set the user as online
  void _setUserOnline(String userId) {
    final presenceRef = _databaseRef.child('presence/$userId');
    presenceRef.set(true); // Mark user as online

    // Set a listener to remove user from the presence node when offline
    presenceRef.onDisconnect().set(false);
  }

  // Update location in Firebase
  Future<void> _updateLocationInDatabase(
      String userId,
      String username,
      String groupId,
      Position position,
      ) async {
    try {
      await _databaseRef.child('users/$userId/location').set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'username': username,
        'groupId': groupId,
      });
      print('Location updated: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Failed to update location in database: $e');
    }
  }

  // Stop updating location and mark the user as offline
  void stopUpdatingLocation(String userId) {
    _setUserOffline(userId);
  }

  // Set the user as offline
  void _setUserOffline(String userId) {
    final presenceRef = _databaseRef.child('presence/$userId');
    presenceRef.set(false); // Mark user as offline
  }
}
