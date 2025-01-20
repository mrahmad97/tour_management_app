import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../constants/colors.dart';
import '../../../functions/push_notification_service.dart';
import '../../../models/group_route.dart';
import '../../../providers/user_provider.dart';

class AddRouteScreen extends StatefulWidget {
  final String? groupId;
  final RouteModel? route;

  const AddRouteScreen({super.key, this.groupId, this.route});

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _headingController = TextEditingController();
  final TextEditingController _typeOfStopController = TextEditingController();
  final TextEditingController _startingFromController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _endingAtController = TextEditingController();

  DateTime? _selectedStartingTime;
  DateTime? _selectedEndingTime;
  DateTime? _selectedStartingDate;
  DateTime? _selectedEndingDate;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.route != null) {
      _headingController.text = widget.route!.heading;
      _typeOfStopController.text = widget.route!.typeOfStop;
      _startingFromController.text = widget.route!.startingFrom;
      _descriptionController.text = widget.route!.description;
      _endingAtController.text = widget.route!.endingAt;
      _selectedStartingTime = widget.route!.startingTime;
      _selectedEndingTime = widget.route!.endingTime;
    }
  }

  @override
  void dispose() {
    _headingController.dispose();
    _typeOfStopController.dispose();
    _startingFromController.dispose();
    _descriptionController.dispose();
    _endingAtController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required BuildContext context,
    required String label,
    required Function(DateTime?) onDatePicked,
  }) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    onDatePicked(pickedDate);
  }

  Future<void> _pickStartingTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(_selectedStartingTime ?? DateTime.now()),
    );

    setState(() {
      _selectedStartingTime = DateTime(
        _selectedStartingDate?.year ?? DateTime.now().year,
        _selectedStartingDate?.month ?? DateTime.now().month,
        _selectedStartingDate?.day ?? DateTime.now().day,
        pickedTime?.hour ?? DateTime.now().hour,
        pickedTime?.minute ?? DateTime.now().minute,
      );
    });
  }

  Future<void> _pickEndingTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.fromDateTime(_selectedEndingTime ?? DateTime.now()),
    );

    setState(() {
      _selectedEndingTime = DateTime(
        _selectedEndingTime?.year ?? DateTime.now().year,
        _selectedEndingTime?.month ?? DateTime.now().month,
        _selectedEndingTime?.day ?? DateTime.now().day,
        pickedTime?.hour ?? DateTime.now().hour,
        pickedTime?.minute ?? DateTime.now().minute,
      );
    });
  }

  Future<void> _submitRoute() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedStartingTime == null ||
        _selectedEndingTime == null ||
        _selectedStartingDate == null ||
        _selectedEndingDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select all date and time fields.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final String createdBy = userProvider.user?.uid ?? 'Unknown';

      final routesRef = FirebaseFirestore.instance.collection('routes');

      if (widget.route != null) {
        await routesRef.doc(widget.route!.id).update({
          'heading': _headingController.text,
          'typeOfStop': _typeOfStopController.text,
          'startingTime': _selectedStartingTime,
          'endingTime': _selectedEndingTime,
          'startingFrom': _startingFromController.text,
          'description': _descriptionController.text,
          'endingAt': _endingAtController.text,
        });
      } else {
        final querySnapshot =
            await routesRef.where('groupId', isEqualTo: widget.groupId).get();

        final int currentOrderIndex = querySnapshot.docs.length;

        final newRoute = RouteModel(
          groupId: widget.groupId ?? '',
          heading: _headingController.text,
          typeOfStop: _typeOfStopController.text,
          startingTime: _selectedStartingTime!,
          endingTime: _selectedEndingTime!,
          startingFrom: _startingFromController.text,
          description: _descriptionController.text,
          endingAt: _endingAtController.text,
          createdAt: DateTime.now(),
          createdBy: createdBy,
          orderIndex: currentOrderIndex,
        );

        await routesRef.add(newRoute.toMap());
        await sendGroupUpdateNotification(widget.groupId);
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.route != null
              ? 'Route updated successfully'
              : 'Route added successfully'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'This field is required' : null,
      ),
    );
  }

  Widget _buildDatePickerRow(
      String label, DateTime? selectedDate, Function(DateTime?) onDatePicked) {
    return Row(
      children: [
        Expanded(
          child: Text(
            selectedDate == null
                ? '$label: No date selected'
                : '$label: ${selectedDate.toLocal().toString().split(' ')[0]}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: () => _pickDate(
              context: context, label: label, onDatePicked: onDatePicked),
          child: Text('Pick $label'),
        ),
      ],
    );
  }

  Widget _buildTimePickerRow(
      String label, DateTime? selectedTime, VoidCallback pickTime) {
    return Row(
      children: [
        Expanded(
          child: Text(
            selectedTime == null
                ? '$label: No time selected'
                : '$label: ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        ElevatedButton(
          onPressed: pickTime,
          child: Text('Pick $label'),
        ),
      ],
    );
  }

  Future<void> sendGroupUpdateNotification(String? groupId) async {
    try {
      if (groupId == null) return;

      final groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .get();

      final groupMembers = List<String>.from(groupSnapshot['members']);
      final managerUid = groupSnapshot['createdBy'];
      groupMembers.remove(managerUid);

      final tokens = await Future.wait(groupMembers.map((userId) async {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        return userDoc['fcmToken'];
      }));

      if (tokens.isNotEmpty) {
        await sendNotificationToUsers(tokens, groupId);
      }
    } catch (e) {
      print('Error sending group update notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route != null ? 'Edit Route' : 'Add Route'),
        automaticallyImplyLeading: !kIsWeb,
        iconTheme: IconThemeData(color: AppColors.surfaceColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_headingController, 'Heading', 'Enter heading'),
              _buildTextField(
                  _typeOfStopController, 'Type of Stop', 'Enter type of stop'),
              _buildTextField(_startingFromController, 'Starting From',
                  'Enter starting point'),
              _buildTextField(
                  _endingAtController, 'Ending At', 'Enter ending point'),
              _buildTextField(
                  _descriptionController, 'Description', 'Enter description'),
              const SizedBox(height: 16),
              _buildTimePickerRow(
                  'Starting Time', _selectedStartingTime, _pickStartingTime),
              const SizedBox(height: 16),
              _buildDatePickerRow('Starting Date', _selectedStartingDate,
                  (date) {
                setState(() {
                  _selectedStartingDate = date;
                });
              }),
              const SizedBox(height: 16),
              _buildTimePickerRow(
                  'Ending Time', _selectedEndingTime, _pickEndingTime),
              const SizedBox(height: 16),
              _buildDatePickerRow('Ending Date', _selectedEndingDate, (date) {
                setState(() {
                  _selectedEndingDate = date;
                });
              }),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRoute,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.route != null ? 'Update Route' : 'Add Route'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
