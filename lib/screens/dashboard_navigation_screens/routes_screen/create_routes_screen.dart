import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../functions/push_notification_service.dart';
import '../../../models/group_route.dart';
import '../../../providers/user_provider.dart';

class AddRouteScreen extends StatefulWidget {
  final String? groupId; // The ID of the group to which the route belongs

  const AddRouteScreen({super.key, this.groupId});

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for each field
  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeOfStopController = TextEditingController();
  final TextEditingController _totalTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  DateTime? _selectedTime;

  bool _isSubmitting = false;

  @override
  void dispose() {
    // Dispose controllers to free resources
    _headingController.dispose();
    _nameController.dispose();
    _typeOfStopController.dispose();
    _totalTimeController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  // Function to pick a time
  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final now = DateTime.now();
      setState(() {
        _selectedTime = DateTime(
          now.year,
          now.month,
          now.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // Function to submit the route data
  Future<void> _submitRoute() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time for the stop')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String createdBy = userProvider.user?.uid ?? 'Unknown';

      // Get the current number of routes to set the orderIndex
      final routesRef = FirebaseFirestore.instance.collection('routes');
      final querySnapshot = await routesRef
          .where('groupId', isEqualTo: widget.groupId)
          .get();

      final int currentOrderIndex = querySnapshot.docs.length;

      // Create a new route
      final newRoute = RouteModel(
        groupId: widget.groupId ?? '',
        heading: _headingController.text,
        name: _nameController.text,
        typeOfStop: _typeOfStopController.text,
        time: _selectedTime!,
        totalTime: _totalTimeController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        purpose: _purposeController.text,
        createdAt: DateTime.now(),
        createdBy: createdBy,
        orderIndex: currentOrderIndex,
      );

      // Add the route to Firestore
      await routesRef.add(newRoute.toMap());

      // Fetch the members' FCM tokens in the group, except the manager
      await sendGroupUpdateNotification(widget.groupId);

      // Clear the form after submission
      _formKey.currentState!.reset();
      _selectedTime = null;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Route added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding route: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupId = widget.groupId;
    print('group id on add route ${groupId}');
    return Scaffold(
      appBar: AppBar(title: const Text('Add Route')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_headingController, 'Heading', 'Enter heading'),
              _buildTextField(_nameController, 'Name', 'Enter name'),
              _buildTextField(_typeOfStopController, 'Type of Stop', 'Enter type of stop'),
              _buildTextField(_totalTimeController, 'Total Time', 'Enter total time spent'),
              _buildTextField(_locationController, 'Location', 'Enter location'),
              _buildTextField(_descriptionController, 'Description', 'Enter description'),
              _buildTextField(_purposeController, 'Purpose', 'Enter purpose'),

              const SizedBox(height: 16),
              // Time picker field
              Row(
                children: [
                  Text(
                    _selectedTime == null
                        ? 'No time selected'
                        : 'Time: ${_selectedTime!.hour}:${_selectedTime!.minute}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _pickTime,
                    child: const Text('Pick Time'),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              // Submit button
              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRoute,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  // Fetch and send group update notification
  Future<void> sendGroupUpdateNotification(String? groupId) async {
    try {
      if (groupId == null) return;

      // Fetch the group members (excluding the manager)
      final groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      final groupMembers = List<String>.from(groupSnapshot['members']);

      // Remove the manager from the list (assuming manager's UID is stored in group data)
      final managerUid = groupSnapshot['createdBy'];  // Assuming the manager UID is stored
      groupMembers.remove(managerUid);

      // Fetch FCM tokens of the group members (excluding the manager)
      final tokens = await Future.wait(groupMembers.map((userId) async {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        return userDoc['fcmToken']; // Get the FCM token for each user
      }));

      // Send FCM notifications to the users (excluding the manager)
      if (tokens.isNotEmpty) {
        await sendNotificationToUsers(tokens);
      }
    } catch (e) {
      print('Error sending group update notification: $e');
    }
  }

//   Future<void> sendNotificationToUsers(List<dynamic> tokens) async {
//     try {
//       // Define the FCM notification payload
//       final message = {
//         "registration_ids": tokens,
//         "notification": {
//           "title": "New Route Added",
//           "body": "A new route has been added to your group. Check it out!"
//         },
//         "priority": "high",
//       };
//
//       // Send the notification via Firebase Cloud Messaging (FCM)
//       final response = await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'firebase-adminsdk-gzl21@tour-management-app-29401.iam.gserviceaccount.com', // Replace with your Firebase server key
//         },
//         body: json.encode(message),
//       );
//
//       if (response.statusCode == 200) {
//         print('Notification sent successfully!');
//       } else {
//         print('Failed to send notification: ${response.body}');
//       }
//     } catch (e) {
//       print('Error sending notification: $e');
//     }
//   }
}
