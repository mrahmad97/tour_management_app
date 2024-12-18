import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter/foundation.dart';  // Import for checking platform

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  late MapboxMap mapboxMap;
  bool _debugLoggingEnabled = false; // Default is false for runtime

  @override
  void initState() {
    super.initState();

    // Conditionally set _debugLoggingEnabled based on the platform
    if (!kIsWeb) {
      _debugLoggingEnabled = true; // Enable logging for non-web platforms (Android, iOS)
      // Set your Mapbox access token directly in this screen
      String ACCESS_TOKEN = "pk.eyJ1IjoibXJhaG1hZDk3IiwiYSI6ImNtNG9wamdjbDAyemQybG93bDRrZzJ6cXQifQ.BD_o-PtzJEsrxbj9ktjF4A"; // Replace with your actual token
      MapboxOptions.setAccessToken(ACCESS_TOKEN);
    }


  }

  @override
  Widget build(BuildContext context) {
    // Check if the app is running on the web using kIsWeb
    if (kIsWeb) {
      return Scaffold(
        body: Center(
          child: Text("Maps are not supported on the web."),
        ),
      );
    }

    // For non-web platforms, display the map
    return Scaffold(
      body: MapWidget(
        onMapCreated: _onMapCreated,
      ),
    );
  }

  void _onMapCreated(MapboxMap map) {
    mapboxMap = map;

    // Use the _debugLoggingEnabled flag in the setup
    if (_debugLoggingEnabled) {
      // Optionally enable logging if needed
      print("Mapbox Debug Logging Enabled");
    }

    // Set camera or other map configurations
    mapboxMap.setCamera(
      CameraOptions(
        center: Point(coordinates: Position(-122.4194, 37.7749)),
        zoom: 12,
      ),
    );
  }
}
