import 'package:geolocator/geolocator.dart';
class LocationLink {
  Future<String?> generateLocationLink() async {
    try {
      // Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Generate Google Maps link
      final locationLink =
          'https://www.google.com/maps?q=${position.latitude},${position
          .longitude}';

      return locationLink;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
