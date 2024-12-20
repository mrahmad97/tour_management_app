import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/strings.dart';
import 'package:tour_management_app/models/user_location_model.dart';
import 'package:tour_management_app/providers/location_provider.dart';

import '../../../constants/colors.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  late MapboxMap mapboxMap;
  bool _debugLoggingEnabled = false;

  @override
  void initState() {
    super.initState();
    _debugLoggingEnabled = true; // Enable logging for debugging

    // Set your Mapbox access token
    MapboxOptions.setAccessToken(Strings.ACCESS_TOKEN);
  }

  Future<void> _initializeLocations() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);

    // Get the list of all user locations
    List<UserLocationModel>? allLocations = locationProvider.usersLocation;

    if (allLocations == null || allLocations.isEmpty) {
      print("No location data available.");
      return;
    }

    print("Total user locations retrieved: ${allLocations.length}");

    // Prepare GeoJSON data for all user locations
    String features = allLocations.map((location) {
      final longitude = location.longitude;
      final latitude = location.latitude;
      final userName = location.username ?? "Unknown"; // Default name if null

      // Skip if coordinates are null
      if (longitude == null || latitude == null) {
        print("Skipped a location due to missing coordinates.");
        return '';
      }

      print("Processed location for user: $userName at [$longitude, $latitude]");
      return '''
      {
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [$longitude, $latitude]
        },
        "properties": {
          "title": "$userName"
        }
      }
    ''';
    }).where((feature) => feature.isNotEmpty).join(',');

    // Wrap in a FeatureCollection
    String geoJsonData = '''
    {
      "type": "FeatureCollection",
      "features": [$features]
    }
  ''';

    // Create a GeoJSON source with all locations
    final geoJsonSource = GeoJsonSource(
      id: "user_locations_source",
      data: geoJsonData,
    );

    // Add the source to the map style
    await mapboxMap.style.addSource(geoJsonSource);

    // Add a SymbolLayer for user locations
    final symbolLayer = SymbolLayer(
      id: "user_locations_symbol_layer",
      sourceId: "user_locations_source",
      iconImage: "marker-icon", // Customize with your own marker icon
      textField: "{title}",
      textSize: 12, // Adjust text size
      textOffset: [0, 1.5], // Offset text above the marker
    );

    await mapboxMap.style.addLayer(symbolLayer);

    print("Displayed ${allLocations.length} user locations on the map.");
  }

  Future<void> _moveCameraToUserLocation({
    double? latitude,
    double? longitude,
    String? username,
  }) async {
    if (latitude == null || longitude == null) {
      print("Invalid location coordinates.");
      return;
    }

    // Move the camera to the provided location
    await mapboxMap.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(
            longitude,
            latitude,
          ),
        ),
        zoom: 14.0, // Adjust zoom level
      ),
    );

    if (_debugLoggingEnabled) {
      print(
          "Moved camera to ${username ?? 'user'} location: ($latitude, $longitude)");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: AppColors.surfaceColor),
        title: const Text(
          "Live Location",
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      drawer: _buildDrawer(context),
      body: SizedBox(
        child: MapWidget(
          onMapCreated: _onMapCreated,
          textureView: true, // Ensures compatibility with non-AppCompat themes
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final allLocations = locationProvider.usersLocation ?? [];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: const Text(
              "Users",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          for (var user in allLocations)
            ListTile(
              title: Text(user.username ?? "Unknown"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                _moveCameraToUserLocation(
                  latitude: user.latitude,
                  longitude: user.longitude,
                  username: user.username,
                );
              },
            ),
        ],
      ),
    );
  }

  void _onMapCreated(MapboxMap map) {
    setState(() {
      mapboxMap = map;
    });

    if (_debugLoggingEnabled) {
      print("Mapbox Debug Logging Enabled");
    }

    // Initialize all locations after the map is created
    _initializeLocations();

    // Move camera to the current user location
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final currentUserLocation = locationProvider.currentUserLocation;

    if (currentUserLocation != null) {
      _moveCameraToUserLocation(
        latitude: currentUserLocation.latitude,
        longitude: currentUserLocation.longitude,
        username: "Current User",
      );
    }
  }
}
