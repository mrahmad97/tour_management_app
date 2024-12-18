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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: ResponsiveWidget(
            largeScreen: _buildLargeScreen(context),
            mediumScreen: _buildMediumScreen(context),
            smallScreen: _buildSmallScreen(context),
          ),
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
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: MediaQuery.of(context).size.height,
              child: _buildGroupTiles(context),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.surfaceColor,
                  ),
                  onPressed: () {
                    NavigationService.navigatorKey.currentState?.push(
                      MaterialPageRoute(builder: (context) => CreateGroupScreen()),
                    );
                  },
                  child: const Text('Create Group'),
                ),
                Center(
                  child: userProvider.user != null
                      ? Text('Welcome, ${userProvider.user!.displayName}')
                      : const Text('No user signed in'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.surfaceColor,
                  ),
                  onPressed: () async {
                    await handleSignOut(context);
                    NavigationService.navigatorKey.currentState?.pushNamed(AppRoutes.loginSignup);
                  },
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediumScreen(BuildContext context) {
    return _buildLargeScreen(context);
  }

  Widget _buildSmallScreen(BuildContext context) {
    return _buildLargeScreen(context);
  }

  Widget _buildGroupTiles(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: fetchGroupsCreatedByUser(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('No groups found.'));
        } else {
          final groups = snapshot.data!;

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];

              return ListTile(
                title: Text(group.name),
                subtitle: Text(group.description),
                trailing: IconButton(
                  icon: const Icon(Icons.group_add),
                  onPressed: () {
                    _showUserSelectionDialog(context, group);
                  },
                ),
                onTap: () {
                  NavigationService.navigatorKey.currentState?.push(
                    MaterialPageRoute(builder: (context) => UserHome(groupId: group.id)),
                  );
                },
              );
            },
          );
        }
      },
    );
  }

  void _showUserSelectionDialog(BuildContext context, Group group) async {
    final currentUserId = Provider.of<UserProvider>(context, listen: false).user?.uid;

    DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(group.id)
        .get();
    List<String> groupMembers = List<String>.from(groupSnapshot['members'] ?? []);

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
                height: 400.0,
                child: FutureBuilder<List<UserModel>>(
                  future: fetchAllUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No users found.'));
                    }

                    final users = snapshot.data!;

                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isCurrentMember = selectedUserIds.contains(user.uid);

                        return ListTile(
                          title: Text(user.uid == currentUserId ? 'You' : (user.displayName ?? 'Unknown')),
                          subtitle: Text(user.email),
                          trailing: isCurrentMember
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check, color: Colors.green),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () {
                                  setDialogState(() {
                                    selectedUserIds.remove(user.uid);
                                  });
                                },
                              ),
                            ],
                          )
                              : IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setDialogState(() {
                                if (!selectedUserIds.contains(user.uid)) {
                                  selectedUserIds.add(user.uid);
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
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await _addMembersToGroup(group.id, selectedUserIds);
                    Navigator.pop(context);
                  },
                  child: const Text('Update Members'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addMembersToGroup(String groupId, List<String> selectedUserIds) async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': selectedUserIds,
      });
      print('Members updated successfully!');
    } catch (e) {
      print('Error updating members: $e');
    }
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'Manager Dashboard',
      style: TextStyle(
        fontSize: ResponsiveWidget.isSmallScreen(context) ? 16 : 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
