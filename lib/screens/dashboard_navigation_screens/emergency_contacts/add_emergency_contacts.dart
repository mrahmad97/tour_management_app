import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/screens/global_components/custom_text_field.dart';
import '../../../models/emergency_contact_model.dart';

class AddEmergencyContactScreen extends StatefulWidget {
  final String userId;

  const AddEmergencyContactScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _AddEmergencyContactScreenState createState() =>
      _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<AddEmergencyContactScreen> {
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter name.';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter number.';
    }
    return null;
  }

  final _formKey = GlobalKey<FormState>();
  late String name, contactNumber, relation;

  // Submit the form to Firebase
  Future<void> _addEmergencyContact() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final emergencyContact = EmergencyContact(
        userId: widget.userId,
        name: name,
        contactNumber: contactNumber,
        relation: relation,
      );

      try {
        await FirebaseFirestore.instance
            .collection('emergencyContacts')
            .add(emergencyContact.toMap());
        Navigator.pop(context); // Go back to the previous screen after saving
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Emergency Contact',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: kIsWeb ? false : true,
        iconTheme: IconThemeData(color: AppColors.surfaceColor),

      ),
      backgroundColor: AppColors.surfaceColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle('Name'),
              CustomTextFormField(
                validation: _validateName,
                keyboardType: TextInputType.name,
                onSaved: (value) {
                  name = value!;
                },
                hintKey: 'Enter name',
              ),
              _buildTitle('Phone Number'),
              CustomTextFormField(
                validation: _validateNumber,
                keyboardType: TextInputType.phone,
                onSaved: (value) {
                  contactNumber = value!;
                },
                hintKey: 'Enter emergency phone number',
              ),
              _buildTitle('Relation'),
              CustomTextFormField(
                keyboardType: TextInputType.text,
                onSaved: (value) {
                  relation = value!;
                },
                hintKey: 'Enter relation',
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.surfaceColor,
                      backgroundColor: AppColors.primaryColor),
                  onPressed: _addEmergencyContact,
                  child: Text('Save Emergency Contact'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, color: AppColors.primaryColor),
    );
  }
}
