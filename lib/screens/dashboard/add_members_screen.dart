import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tour_management_app/screens/global_components/responsive_widget.dart';
import 'package:provider/provider.dart' as provider;

import '../../constants/colors.dart';
import '../../functions/fetch_users.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class AddMembersScreen extends StatefulWidget {
  final String groupId;

  const AddMembersScreen({super.key, required this.groupId});

  @override
  State<AddMembersScreen> createState() => _AddMembersScreenState();
}

class _AddMembersScreenState extends State<AddMembersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> selectedUserIds = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Edit Members',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addMembersToGroup(widget.groupId, selectedUserIds);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Done',
              style: TextStyle(color: AppColors.surfaceColor),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.surfaceColor,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by email',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {}); // Updates the UI when the search query changes
              },
            ),
            Expanded(
              child: ResponsiveWidget(
                largeScreen: _buildUserList(context),
                mediumScreen: _buildUserList(context),
                smallScreen: _buildUserList(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(BuildContext context) {
    final currentUserId =
        provider.Provider.of<UserProvider>(context, listen: false).user?.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Group data not found.'));
        }

        List<String> groupMembers =
        List<String>.from(snapshot.data!['members'] ?? []);
        selectedUserIds = List<String>.from(groupMembers);

        return _buildUserListContent(context, currentUserId);
      },
    );
  }

  Widget _buildUserListContent(BuildContext context, String? currentUserId) {
    return FutureBuilder<List<UserModel>>(
      future: fetchAllUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('No users found.'));
        }

        final users = snapshot.data!
            .where((user) => user.email
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()))
            .toList();

        if (users.isEmpty) {
          return const Center(child: Text('No users match the search query.'));
        }

        return SingleChildScrollView(
          child: Column(
            children: users.map((user) {
              final isCurrentMember = selectedUserIds.contains(user.uid);

              return ListTile(
                title: Text(user.uid == currentUserId
                    ? 'You'
                    : user.displayName ?? 'Unknown'),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: Icon(
                    isCurrentMember
                        ? Icons.remove_circle_outline
                        : Icons.add,
                    color: isCurrentMember ? Colors.red : null,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isCurrentMember) {
                        selectedUserIds.remove(user.uid);
                      } else {
                        selectedUserIds.add(user.uid);
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<void> _addMembersToGroup(
      String groupId, List<String> selectedUserIds) async {
    if (selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No members selected to add.')),
      );
      return;
    }

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
