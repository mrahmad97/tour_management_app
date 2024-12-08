import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../models/group_route.dart';
import '../../../providers/user_provider.dart';

class AddRouteScreen extends StatefulWidget {
  final String? groupId; // The ID of the group to which the route belongs

  const AddRouteScreen({Key? key, this.groupId}) : super(key: key);

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
}
