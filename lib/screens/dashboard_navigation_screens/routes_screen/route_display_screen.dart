import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/providers/user_provider.dart';
import 'package:tour_management_app/screens/dashboard_navigation_screens/routes_screen/create_routes_screen.dart';
import 'package:intl/intl.dart';

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
    final user = Provider
        .of<UserProvider>(context)
        .user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Routes',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        automaticallyImplyLeading: kIsWeb ? false :true,
        iconTheme: IconThemeData(color: AppColors.surfaceColor),

        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.surfaceColor,
      body: groupId == null
          ? Center(
        child: Text('An Error occured'),
      )
          : Column(
        children: [
          // Add Routes Button (only for managers)
          user.userType == 'manager'
              ? Column(
            children: [
              SizedBox(height: 10,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.surfaceColor,
                    backgroundColor: AppColors.primaryColor),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        AddRouteScreen(groupId: groupId),
                  ));
                },
                child: const Text('Add Routes'),
              ),
            ],
          )
              : SizedBox(),

          SizedBox(height: 10),

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
                  print(
                      'Error: ${snapshot
                          .error}'); // Print the error to the console
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No routes found.'));
                }

                // Convert documents to RouteModel
                final routes = snapshot.data!.docs.map((doc) {
                  return RouteModel.fromMap(
                      doc.id, doc.data() as Map<String, dynamic>);
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
    final user = Provider
        .of<UserProvider>(context)
        .user!;
    return Card(
      color: AppColors.cardBackgroundColor,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Material(
        elevation: 4,
        child: ListTile(
          tileColor: AppColors.cardBackgroundColor,
          title: Text(route.heading,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${route.typeOfStop}'),
              Text('Starting Time: ${DateFormat('HH:mm').format(
                  route.startingTime)}'),
              Text('Starting Date: ${DateFormat('dd:MM:yy').format(
                  route.startingTime)}'),
              Text('Starting Location: ${route.startingFrom}'),
              Text('Ending Location: ${route.endingAt}'),
              Text('Ending Time: ${DateFormat('HH:mm').format(
                  route.endingTime)}'),
              Text('Ending Date: ${DateFormat('dd:MM:yy').format(
                  route.endingTime)}'),
              user.userType == 'manager'
                  ?Center(
                    child: TextButton(onPressed: () {
                                    Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        AddRouteScreen(groupId: route.groupId, route: route,),));
                                  }, child: Text('Edit')),
                  ) : SizedBox(),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              _showRouteDetails(route);
            },
          ),
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
          backgroundColor: AppColors.surfaceColor,
          title: Text(route.heading),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Type: ${route.typeOfStop}'),
              Text('Starting Time: ${DateFormat('HH:mm').format(
                  route.startingTime)}'),
              Text('Starting Date: ${DateFormat('dd:MM:yy').format(
                  route.startingTime)}'),
              Text('Starting Location: ${route.startingFrom}'),
              Text('Ending Location: ${route.endingAt}'),
              Text('Ending Time: ${DateFormat('HH:mm').format(
                  route.endingTime)}'),
              Text('Ending Date: ${DateFormat('dd:MM:yy').format(
                  route.endingTime)}'),
              Text('Description: ${route.description}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
