import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/functions/push_notification_service.dart';
import 'package:tour_management_app/main.dart';
import 'package:tour_management_app/screens/dashboard/user_home.dart';
import 'package:tour_management_app/screens/global_components/responsive_widget.dart';
import '../../constants/routes.dart';
import '../../functions/fetch_groups.dart';
import '../../functions/fetch_users.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../create_group_screen/create_group_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> handleSignOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).signOut();
  }

  // List to track reselected users
  List<String> reselectedUserIds = [];

  @override
  Widget build(BuildContext context) {
    // Use listen: true to rebuild when the user changes

    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: ResponsiveWidget(
              largeScreen: _buildLargeScreen(context),
              mediumScreen: _buildMediumScreen(context),
              smallScreen: _buildSmallScreen(context)),
        ),
      ),
    );
  }

  Widget _buildLargeScreen(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitle(context),
        Row(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 1 / 2,
                height: MediaQuery.of(context).size.height,
                child: _buildGroupTiles(context)),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.surfaceColor),
                  onPressed: () {
                    NavigationService.navigatorKey.currentState
                        ?.push(MaterialPageRoute(
                      builder: (context) => CreateGroupScreen(),
                    ));
                  },
                  child: Text('Create Group'),
                ),
                Center(
                  child: userProvider.user != null
                      ? Text('Welcome, ${userProvider.user!.displayName}')
                      : Text('No user signed in'),
                ),
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
          ],
        ),
      ],
    );
  }

  Widget _buildMediumScreen(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitle(context),
        Row(
          children: [
            SizedBox(
                width: MediaQuery.of(context).size.width * 1 / 2,
                height: MediaQuery.of(context).size.height,
                child: _buildGroupTiles(context)),
            Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.surfaceColor),
                  onPressed: () {
                    NavigationService.navigatorKey.currentState
                        ?.push(MaterialPageRoute(
                      builder: (context) => CreateGroupScreen(),
                    ));
                  },
                  child: Text('Create Group'),
                ),
                Center(
                  child: userProvider.user != null
                      ? Text('Welcome, ${userProvider.user!.displayName}')
                      : Text('No user signed in'),
                ),
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
          ],
        ),
      ],
    );
  }

  Widget _buildSmallScreen(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildTitle(context),
        _buildGroupTiles(context),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.surfaceColor),
          onPressed: () {
            NavigationService.navigatorKey.currentState?.push(MaterialPageRoute(
              builder: (context) => CreateGroupScreen(),
            ));
          },
          child: Text('Create Group'),
        ),
        Center(
          child: userProvider.user != null
              ? Text('Welcome, ${userProvider.user!.displayName}')
              : Text('No user signed in'),
        ),
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
    );
  }

  Widget _buildGroupTiles(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: fetchGroupsCreatedByUser(context), // Fetch the groups
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('No groups found.'));
        } else {
          final groups = snapshot.data!;

          return SizedBox(
            height: 400,
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];

                return ListTile(
                  title: Text(group.name),
                  subtitle: Text(group.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.group_add),
                        onPressed: () {
                          _showUserSelectionDialog(context, group);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to the UserDashboardScreen with the group.id
                    NavigationService.navigatorKey.currentState
                        ?.push(MaterialPageRoute(
                      builder: (context) => UserHome(
                        groupId: group.id,
                      ),
                    ));
                    // getToken();
                  },
                );
              },
            ),
          );
        }
      },
    );
  }

  void _showUserSelectionDialog(BuildContext context, Group group) async {
    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).user?.uid;

    // Fetch the latest group data from Firestore
    DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(group.id)
        .get();
    List<String> groupMembers =
        List<String>.from(groupSnapshot['members'] ?? []);

    // Initialize the selectedUserIds with the latest members
    List<String> selectedUserIds = List<String>.from(groupMembers);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Members'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400.0, // Fixed height for the dialog
                child: FutureBuilder<List<UserModel>>(
                  future: fetchAllUsers(), // Fetch all users
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }

                    final users = snapshot.data!;

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isSelected = selectedUserIds.contains(user.uid);

                        return ListTile(
                          title: Text(
                            user.uid == currentUserId
                                ? 'You'
                                : (user.displayName ?? 'Unknown'),
                          ),
                          subtitle: Text(user.email),
                          trailing: isSelected
                              ? const Icon(Icons.check,
                                  color: Colors.green) // Tick icon if selected
                              : IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setDialogState(() {
                                      if (isSelected) {
                                        selectedUserIds.remove(user.uid);
                                        reselectedUserIds.remove(user.uid);
                                      } else {
                                        selectedUserIds.add(user.uid);
                                        if (!reselectedUserIds
                                            .contains(user.uid)) {
                                          reselectedUserIds.add(user.uid);
                                        }
                                      }
                                    });
                                  },
                                ),
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedUserIds.isNotEmpty ||
                        reselectedUserIds.isNotEmpty) {
                      selectedUserIds.addAll(reselectedUserIds);
                      _addMembersToGroup(
                          group.id, selectedUserIds.toSet().toList());
                    }
                    final tokens =
                        await Future.wait(groupMembers.map((userId) async {
                      final userDoc = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .get();
                      return userDoc[
                          'fcmToken']; // Get the FCM token for each user
                    }));
                    await sendMemberNotificationToUsers(tokens, group.id);
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Add Members'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addMembersToGroup(
      String groupId, List<String> selectedUserIds) async {
    try {
      // Update the group document with the new members
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
        'members': selectedUserIds,
      });

      print('Members added to group successfully!');
    } catch (e) {
      print('Error adding members: $e');
    }
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Manager Dashboard',
      style: TextStyle(
          fontSize: ResponsiveWidget.isSmallScreen(context) ? 16 : 20,
          fontWeight: FontWeight.bold),
    );
  }
}
