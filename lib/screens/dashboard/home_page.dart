import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/main.dart';
import 'package:tour_management_app/screens/dashboard/add_members_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();

  Future<void> handleSignOut(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).signOut();
    NavigationService.navigatorKey.currentState
        ?.pushNamed(AppRoutes.loginSignup);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manager Dashboard',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.surfaceColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsiveWidget(
            largeScreen: _buildLargeScreen(context),
            mediumScreen: _buildSmallScreen(context),
            smallScreen: _buildSmallScreen(context),
          ),
        ),
      ),
    );
  }

  Widget _buildLargeScreen(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.height,
          child: _buildGroupTiles(context),
        ),
        _buildUserInfoSection(context, userProvider),
      ],
    );
  }

  Widget _buildSmallScreen(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Column(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.5,
          child: _buildGroupTiles(context),
        ),
        _buildUserInfoSection(context, userProvider),
      ],
    );
  }

  Widget _buildUserInfoSection(
      BuildContext context, UserProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.surfaceColor,
          ),
          onPressed: () {
            NavigationService.navigatorKey.currentState?.push(
              MaterialPageRoute(
                  builder: (context) => const CreateGroupScreen()),
            );
          },
          child: const Text('Create Group'),
        ),
        Text(
          userProvider.user != null
              ? 'Welcome, ${userProvider.user!.displayName}'
              : 'No user signed in',
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.surfaceColor,
          ),
          onPressed: () => handleSignOut(context),
          child: const Text('Sign out'),
        ),
      ],
    );
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
        }

        final groups = snapshot.data!;
        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(10),
                child: ListTile(
                  title: Text(group.name),
                  subtitle: Text(group.description),
                  tileColor: AppColors.cardBackgroundColor,
                  trailing: IconButton(
                      icon: const Icon(Icons.group_add),
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                AddMembersScreen(groupId: group.id),
                          ))),
                  onTap: () {
                    NavigationService.navigatorKey.currentState?.push(
                      MaterialPageRoute(
                        builder: (context) => UserHome(groupId: group.id),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserSelectionDialog(BuildContext context, Group group) async {
    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).user?.uid;

    DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(group.id)
        .get();
    List<String> groupMembers =
        List<String>.from(groupSnapshot['members'] ?? []);

    List<String> selectedUserIds = List<String>.from(groupMembers);
    FocusNode _focusNode = FocusNode();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Members'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search by email',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: _focusNode.hasFocus
                          ? MediaQuery.of(context).size.height * 1 / 4
                          : MediaQuery.of(context).size.height * 1 / 3,
                      child: FutureBuilder<List<UserModel>>(
                        future: fetchAllUsers(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (snapshot.data == null ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('No users found.'));
                          }

                          final users = snapshot.data!
                              .where((user) => user.email
                                  .toLowerCase()
                                  .contains(
                                      _searchController.text.toLowerCase()))
                              .toList();

                          if (users.isEmpty) {
                            return const Center(
                                child:
                                    Text('No users match the search query.'));
                          }

                          return ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final isCurrentMember =
                                  selectedUserIds.contains(user.uid);

                              return ListTile(
                                title: Text(user.uid == currentUserId
                                    ? 'You'
                                    : user.displayName ?? 'Unknown'),
                                subtitle: Text(user.email),
                                trailing: isCurrentMember
                                    ? IconButton(
                                        icon: const Icon(
                                            Icons.remove_circle_outline,
                                            color: Colors.red),
                                        onPressed: () {
                                          setDialogState(() {
                                            selectedUserIds.remove(user.uid);
                                          });
                                        },
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () {
                                          setDialogState(() {
                                            if (!selectedUserIds
                                                .contains(user.uid)) {
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
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
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

  Future<void> _addMembersToGroup(
      String groupId, List<String> selectedUserIds) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .update({
        'members': selectedUserIds,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Members updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating members: $e')),
      );
    }
  }
}
