import 'package:flutter/material.dart';
import '../models/user_location_model.dart';

class LocationProvider extends ChangeNotifier {
  List<UserLocationModel> _usersLocation = [];
  UserLocationModel? _currentUserLocation;

  List<UserLocationModel> get usersLocation => _usersLocation;
  UserLocationModel? get currentUserLocation => _currentUserLocation;

  void updateUsersLocation(List<UserLocationModel> updatedUsers) {
    _usersLocation = updatedUsers;
    notifyListeners();
  }

  void updateCurrentUserLocation(UserLocationModel? user) {
    _currentUserLocation = user;
    notifyListeners();
  }
}
