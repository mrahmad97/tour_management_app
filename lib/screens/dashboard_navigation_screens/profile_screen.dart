import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/colors.dart';

import '../../constants/routes.dart';
import '../../main.dart';
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

  Future<void> handleSignOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).signOut();
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
        backgroundColor: AppColors.primaryColor,
        title: Text(
          widget.isManagerProfile ? 'Manager Profile' : 'Profile',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        automaticallyImplyLeading: kIsWeb ? false :true,
      iconTheme: IconThemeData(color: AppColors.surfaceColor),
      ),

      backgroundColor: AppColors.surfaceColor,
      body: userProfile == null
          ? const Center(child: Text('User not found.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.surfaceColor,
                      radius: 50,
                      backgroundImage: userProfile.imageURL != null &&
                              userProfile.imageURL!.isNotEmpty
                          ? NetworkImage(userProfile.imageURL!)
                          : const AssetImage('assets/get_started/mountains.png')
                              as ImageProvider, // Add photo URL handling here
                    ),
                    const SizedBox(height: 20),
                    Text(
                      userProfile.displayName != null
                          ? userProfile.displayName![0].toUpperCase() +
                              userProfile.displayName!.substring(1)
                          : 'Unknown',
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
                    const SizedBox(height: 10),
                    Text(
                      'Account Type: ${userProfile.userType != null ? userProfile.userType![0].toUpperCase() + userProfile.userType!.substring(1) : "N/A"}',
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: AppColors.surfaceColor),
                      onPressed: () async {
                        await handleSignOut(context);
                        NavigationService.navigatorKey.currentState
                            ?.pushNamed(AppRoutes.loginSignup);
                      },
                      child: Text('Sign out'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
