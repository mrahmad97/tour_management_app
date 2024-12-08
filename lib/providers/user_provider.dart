import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // Set user details and notify listeners
  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  // Set loading state and notify listeners
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Fetch user data from Firestore and update _user
  Future<void> fetchUserData() async {
    setLoading(true);
    try {
      if (_user != null) {
        // Get the user data from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();

        if (userDoc.exists) {
          // Assuming the data is stored as a map in Firestore
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

          // Update user with additional data (e.g., name, userType)
          _user = _user!.copyWith(
            displayName: data['name'],
            userType: data['userType'],
            phoneNumber: data['phoneNumber'] ?? 'Unknown',
          );

          // Notify listeners to update the app UI
          notifyListeners();
        }
      }
    } catch (error) {
      print('Error fetching user data: $error');
    } finally {
      setLoading(false);
    }
  }

  // Sign out user
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    setUser(null); // Reset user details after signing out
  }
}
