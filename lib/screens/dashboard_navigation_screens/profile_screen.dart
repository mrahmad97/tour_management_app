import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  final String? groupId; // If null, display current user's profile
  final bool
      isManagerProfile; // Indicates whether to fetch the manager's profile

  const ProfileScreen({super.key, this.groupId, this.isManagerProfile = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? managerProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isManagerProfile && widget.groupId != null) {
      fetchManagerProfile();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fetch manager's profile based on 'createdBy' field in the group document
  Future<void> fetchManagerProfile() async {
    try {
      // Fetch the group document
      DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get();

      String? managerId = groupSnapshot['createdBy'];

      if (managerId != null) {
        // Fetch the manager's user details
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(managerId)
            .get();

        if (userSnapshot.exists) {
          setState(() {
            managerProfile = UserModel.fromMap(
              userSnapshot.id,
              userSnapshot.data() as Map<String, dynamic>,
            );
          });
        }
      }
    } catch (e) {
      print("Error fetching manager profile: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    // Display loading indicator while fetching manager's profile
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Determine which user data to display
    final userProfile = widget.isManagerProfile ? managerProfile : currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: userProfile == null
          ? const Center(child: Text('User not found.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: null, // Add photo URL handling here
                    child: const Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userProfile.displayName ?? 'No Name',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Email: ${userProfile.email}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Phone: ${userProfile.phoneNumber}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }
}
