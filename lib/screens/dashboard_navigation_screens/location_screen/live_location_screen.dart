import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/strings.dart';
import 'package:tour_management_app/functions/generate_location_link.dart';
import 'package:tour_management_app/models/user_location_model.dart';
import 'package:tour_management_app/providers/location_provider.dart';
import '../../../constants/colors.dart';
import 'package:flutter/services.dart'; // To access clipboard

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  late MapboxMap mapboxMap;
  bool _debugLoggingEnabled = false;
  double _iconBottom = 70.0; // Initial position of the movable icon
  double _iconRight = 30.0;

  @override
  void initState() {
    super.initState();
    _debugLoggingEnabled = true; // Enable logging for debugging

    // Set your Mapbox access token
    MapboxOptions.setAccessToken(Strings.ACCESS_TOKEN);
  }

  Future<void> _initializeLocations() async {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);

    // Get the list of all user locations
    List<UserLocationModel>? allLocations = locationProvider.usersLocation;

    if (allLocations == null || allLocations.isEmpty) {
      print("No location data available.");
      return;
    }

    print("Total user locations retrieved: ${allLocations.length}");

    // Prepare GeoJSON data for all user locations
    String features = allLocations
        .map((location) {
          final longitude = location.longitude;
          final latitude = location.latitude;
          final userName =
              location.username ?? "Unknown"; // Default name if null

          // Skip if coordinates are null
          if (longitude == null || latitude == null) {
            print("Skipped a location due to missing coordinates.");
            return '';
          }

          print(
              "Processed location for user: $userName at [$longitude, $latitude]");

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
        })
        .where((feature) => feature.isNotEmpty)
        .join(',');

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
      iconImage: "marker-icon",
      // Customize with your own marker icon
      textField: "{title}",
      textSize: 12,
      // Adjust text size
      textOffset: [0, 1.5],
      // Offset text above the marker
      iconAllowOverlap: true,
      // Allow icons to overlap (for clustering)
      textAllowOverlap: true, // Allow text to overlap
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
        automaticallyImplyLeading: kIsWeb ? false : true,
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          SizedBox(
            child: MapWidget(
              onMapCreated: _onMapCreated,
              textureView:
                  true, // Ensures compatibility with non-AppCompat themes
            ),
          ),
          Positioned(
            bottom: _iconBottom,
            right: _iconRight,
            child: GestureDetector(
              onTap: () {
                // Move the camera to the current user location
                final locationProvider =
                    Provider.of<LocationProvider>(context, listen: false);
                final currentUserLocation =
                    locationProvider.currentUserLocation;

                if (currentUserLocation != null) {
                  _moveCameraToUserLocation(
                    latitude: currentUserLocation.latitude,
                    longitude: currentUserLocation.longitude,
                    username: "Current User",
                  );
                }
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primaryColor,
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    final allLocations = locationProvider.usersLocation ?? [];
    final LocationLink _locationLink = LocationLink();
    bool isLoading = false;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
            ),
            child: Column(
              children: [
                Text(
                  "Users",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() { isLoading = true; });
                    final link = await _locationLink.generateLocationLink();
                    setState(() { isLoading = false; });
                    if (link != null) {
                      _showCopyDialog(context, link);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to generate location link')),
                      );
                    }
                  },
                  child: isLoading ? CircularProgressIndicator() : Text('Share Location'),
                )

              ],
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
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: false);
    final currentUserLocation = locationProvider.currentUserLocation;

    if (currentUserLocation != null) {
      _moveCameraToUserLocation(
        latitude: currentUserLocation.latitude,
        longitude: currentUserLocation.longitude,
        username: "Current User",
      );
    }
  }
  // Function to show the dialog with the generated location link and Copy button
  void _showCopyDialog(BuildContext context, String locationLink) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Location Link"),
          content: SelectableText(
            locationLink,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Copy the link to clipboard
                Clipboard.setData(ClipboardData(text: locationLink));
                Navigator.of(context).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location link copied to clipboard')),
                );
              },
              child: Text("Copy"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
