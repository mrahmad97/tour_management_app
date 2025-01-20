import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/models/user_model.dart';
import 'package:tour_management_app/providers/user_provider.dart';

class GroupMembersScreen extends StatefulWidget {
  final String? groupId;

  const GroupMembersScreen({super.key, this.groupId});

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  Future<List<UserModel>> fetchGroupMembers() async {
    try {
      // Fetch the group document to get the list of member IDs
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      List<String> memberIds =
          List<String>.from(groupSnapshot['members'] ?? []);

      if (memberIds.isEmpty) {
        return [];
      }

      // Handle Firestore's limitation on 'whereIn' query length (max 10)
      List<UserModel> members = [];
      for (int i = 0; i < memberIds.length; i += 10) {
        final batchIds = memberIds.sublist(
          i,
          i + 10 > memberIds.length ? memberIds.length : i + 10,
        );

        QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();

        // Map Firestore data to UserModel
        members.addAll(usersSnapshot.docs.map((doc) {
          return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        }).toList());
      }

      return members;
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Group Members',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: kIsWeb ? false :true,
        iconTheme: IconThemeData(color: AppColors.surfaceColor),

      ),

      backgroundColor: AppColors.surfaceColor,
      body: SafeArea(
        child: FutureBuilder<List<UserModel>>(
          future: fetchGroupMembers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No users found.'));
            }

            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Card(
                  color: AppColors.cardBackgroundColor,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceColor,
                      radius: 30,
                      backgroundImage: user.imageURL != null &&
                              user.imageURL!.isNotEmpty
                          ? NetworkImage(user.imageURL!)
                          : const AssetImage('assets/get_started/mountains.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      user.uid == currentUser?.uid
                          ? 'You'
                          : (user.displayName != null
                              ? user.displayName![0].toUpperCase() +
                                  user.displayName!.substring(1)
                              : 'Unknown'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${user.email}'),
                        Text('Phone: ${user.phoneNumber ?? "N/A"}'),
                        Text(
                            'User Type: ${user.userType != null ? user.userType![0].toUpperCase() + user.userType!.substring(1) : "N/A"}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
