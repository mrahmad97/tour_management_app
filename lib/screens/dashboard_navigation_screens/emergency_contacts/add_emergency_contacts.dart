import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/emergency_contact_model.dart';

class AddEmergencyContactScreen extends StatefulWidget {
  final String userId;

  const AddEmergencyContactScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _AddEmergencyContactScreenState createState() =>
      _AddEmergencyContactScreenState();
}

class _AddEmergencyContactScreenState extends State<AddEmergencyContactScreen> {
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
        await FirebaseFirestore.instance.collection('emergencyContacts').add(emergencyContact.toMap());
        Navigator.pop(context); // Go back to the previous screen after saving
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Emergency Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  name = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a contact number.';
                  }
                  return null;
                },
                onSaved: (value) {
                  contactNumber = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Relation'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the relation.';
                  }
                  return null;
                },
                onSaved: (value) {
                  relation = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addEmergencyContact,
                child: Text('Save Emergency Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
