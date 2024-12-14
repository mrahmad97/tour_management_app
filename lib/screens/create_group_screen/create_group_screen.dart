import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/functions/create_group.dart';
import 'package:tour_management_app/screens/global_components/custom_text_field.dart';
import '../../functions/fetch_users.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isLoading = false;
  bool showUserSelection = false;
  List<String> selectedUserIds = []; // List to store selected user IDs

  Future<List<UserModel>> _fetchUsers() async {
    return await fetchAllUsers(); // Replace with your actual function to fetch users
  }

  // Function to show the user selection modal
  void _showUserSelectionDialog() {
    // Assuming you have a UserProvider to get the current user's UID
    final currentUserId =
        Provider.of<UserProvider>(context, listen: false).user?.uid;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Members'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return SizedBox(
                width: double.maxFinite,
                height: 400.0,
                // Set a fixed height for the dialog's content area
                child: FutureBuilder<List<UserModel>>(
                  future: _fetchUsers(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const Center(child: Text('No users found'));
                    }

                    final users = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final isSelected = selectedUserIds.contains(user.uid);
                        final isCreator = user.uid == currentUserId;

                        return ListTile(
                          title: Text(
                            isCreator ? 'You' : (user.displayName ?? 'Unknown'),
                          ),
                          subtitle: Text(user.email),
                          trailing: isCreator
                              ? null
                              : IconButton(
                                  icon: Icon(
                                    isSelected ? Icons.check : Icons.add,
                                    color: isSelected ? Colors.green : null,
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      if (isSelected) {
                                        selectedUserIds.remove(user.uid);
                                      } else {
                                        selectedUserIds.add(user.uid);
                                      }
                                    });
                                    print(
                                        'Selected User IDs: $selectedUserIds');
                                  },
                                ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                print('Selected User IDs: $selectedUserIds');
                // Handle selected user IDs (e.g., save to the form)
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildForm(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle('Group Name'),
          const SizedBox(height: 5),
          CustomTextFormField(
            hintKey: 'Enter your group name',
            controller: groupNameController,
          ),
          _buildTitle('Description'),
          const SizedBox(height: 5),
          CustomTextFormField(
            hintKey: 'Enter your group description',
            controller: descriptionController,
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.surfaceColor),
              onPressed: _showUserSelectionDialog, // Show the modal dialog
              child: const Text('Add Members'),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.surfaceColor),
              onPressed: isLoading
                  ? null
                  : () async {
                setState(() {
                  isLoading =true;
                });
                      await createGroup(
                          groupName: groupNameController.text,
                          description: descriptionController.text,
                          createdBy: userProvider.user!.uid,
                          memberIds: selectedUserIds);
                      setState(() {
                        isLoading = false;
                      });

                      Navigator.of(context).pop();

                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Group'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 14, color: AppColors.primaryColor),
    );
  }
}
