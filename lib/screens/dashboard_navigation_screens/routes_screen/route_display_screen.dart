import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/providers/user_provider.dart';
import 'package:tour_management_app/screens/dashboard_navigation_screens/routes_screen/create_routes_screen.dart';

import '../../../models/group_route.dart';

class RouteDisplayScreen extends StatefulWidget {
  final String? groupId;

  const RouteDisplayScreen({super.key, this.groupId});

  @override
  State<RouteDisplayScreen> createState() => _RouteDisplayScreenState();
}

class _RouteDisplayScreenState extends State<RouteDisplayScreen> {
  @override
  Widget build(BuildContext context) {
    final groupId = widget.groupId;
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Display Screen'),
      ),
      body: Column(
        children: [
          // Add Routes Button (only for managers)
          if (user.userType == 'manager')
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddRouteScreen(groupId: groupId),
                ));
              },
              child: const Text('Add Routes'),
            ),

          const SizedBox(height: 10),

          // Display Routes List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('routes')
                  .where('groupId', isEqualTo: groupId)
                  .orderBy('orderIndex')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}'); // Print the error to the console
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No routes found.'));
                }

                // Convert documents to RouteModel
                final routes = snapshot.data!.docs.map((doc) {
                  return RouteModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  itemCount: routes.length,
                  itemBuilder: (context, index) {
                    final route = routes[index];
                    return _buildRouteTile(route);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Route tile widget
  Widget _buildRouteTile(RouteModel route) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        title: Text(route.heading, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${route.name}'),
            Text('Type: ${route.typeOfStop}'),
            Text('Time: ${route.time.toLocal()}'),
            Text('Location: ${route.location}'),
            Text('Duration: ${route.totalTime}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info),
          onPressed: () {
            _showRouteDetails(route);
          },
        ),
      ),
    );
  }

  // Show detailed route information in a dialog
  void _showRouteDetails(RouteModel route) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(route.heading),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Name: ${route.name}'),
              Text('Type of Stop: ${route.typeOfStop}'),
              Text('Time: ${route.time.toLocal()}'),
              Text('Total Time: ${route.totalTime}'),
              Text('Location: ${route.location}'),
              Text('Description: ${route.description}'),
              Text('Purpose: ${route.purpose}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
