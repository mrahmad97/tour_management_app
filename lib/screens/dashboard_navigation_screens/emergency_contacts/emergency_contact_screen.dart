import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/functions/generate_location_link.dart';
import 'package:tour_management_app/providers/user_provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final LocationLink _locationLink = LocationLink();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency Contacts',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        automaticallyImplyLeading: kIsWeb ? false :true,
        iconTheme: IconThemeData(color: AppColors.surfaceColor),

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
                      elevation: 4,
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
                        trailing: IconButton(
                          onPressed: () async {
                            final link = await _locationLink.generateLocationLink(); // Fetch location link
                            final phoneNumber = contact.contactNumber;
                            final message = 'Here is my live location: $link';

                            final Uri smsUri = Uri.parse('sms:$phoneNumber?body=$message');
                            if (await canLaunch(smsUri.toString())) {
                              await launch(smsUri.toString());
                            } else {
                              print('Could not launch SMS');
                            }
                          },
                          icon: Icon(Icons.share_location),
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
