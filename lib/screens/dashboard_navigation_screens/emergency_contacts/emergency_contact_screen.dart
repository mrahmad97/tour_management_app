import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/providers/user_provider.dart';

import '../../../constants/colors.dart';
import '../../../models/emergency_contact_model.dart';
import 'add_emergency_contacts.dart';

class EmergencyContactsScreen extends StatefulWidget {
  @override
  _EmergencyContactsScreenState createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  @override
  Widget build(BuildContext context) {
    final user =
        Provider.of<UserProvider>(context).user!; // Get current user ID

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency Contacts',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.surfaceColor,
      body: Column(
        children: [
          SizedBox(height: 10,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                foregroundColor: AppColors.surfaceColor,
                backgroundColor: AppColors.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEmergencyContactScreen(
                    userId: user.uid, // Pass current user ID
                  ),
                ),
              );
            },
            child: Text('Add Emergency Contact'),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('emergencyContacts')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No emergency contacts found.'));
                }

                final contacts = snapshot.data!.docs.map((doc) {
                  return EmergencyContact.fromMap(
                      doc.id, doc.data() as Map<String, dynamic>);
                }).toList();

                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        tileColor: AppColors.cardBackgroundColor,
                        title: Text(contact.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact: ${contact.contactNumber}'),
                            Text('Relation: ${contact.relation}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
