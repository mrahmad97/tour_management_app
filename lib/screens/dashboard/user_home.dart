import 'package:flutter/material.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/constants/routes.dart';


class UserHome extends StatefulWidget {
  final String? groupId;

  const UserHome({super.key, this.groupId});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  List<Map<String, dynamic>> getFeatures(BuildContext context) {
    return [
      {
        'title': 'Chat',
        'navigateTo': () => Navigator.of(context).pushNamed(
          AppRoutes.chat,
          arguments: widget.groupId,
        ),
        'icon': Icons.chat,
      },
      {
        'title': 'Live Location',
        'navigateTo': () =>
            Navigator.of(context).pushNamed(AppRoutes.liveLocation),
        'icon': Icons.location_on,
      },
      {
        'title': 'Group Members',
        'navigateTo': () => Navigator.of(context).pushNamed(
          AppRoutes.groupMembers,
          arguments: widget.groupId,
        ),
        'icon': Icons.group,
      },
      {
        'title': 'Route',
        'navigateTo': () => Navigator.of(context).pushNamed(
          AppRoutes.routeDisplay,
          arguments: widget.groupId,
        ),
        'icon': Icons.map,
      },
      {
        'title': 'Emergency Contact',
        'navigateTo': () =>
            Navigator.of(context).pushNamed(AppRoutes.emergencyContact),
        'icon': Icons.contact_phone,
      },
      {
        'title': 'Profile',
        'navigateTo': () => Navigator.of(context).pushNamed(
          AppRoutes.profile,
          arguments: {'groupId': widget.groupId},
        ),
        'icon': Icons.person,
      },
      {
        'title': 'Expense',
        'navigateTo': () => Navigator.of(context).pushNamed(
          AppRoutes.addExpense,
          arguments: widget.groupId,
        ),
        'icon': Icons.attach_money,
      },
      {
        'title': 'Manager Details',
        'navigateTo': () => Navigator.of(context).pushNamed(
          AppRoutes.managerDetails,
          arguments: widget.groupId,
        ),
        'icon': Icons.business_center,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final groupId = widget.groupId;

    final features = getFeatures(context);
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            groupId == null
                ? const Text(
              'You are not present in any group, kindly contact your manager.',
            )
                : const SizedBox(),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: features.length,
                itemBuilder: (context, index) {
                  final feature = features[index];
                  return GestureDetector(
                    onTap: feature['navigateTo'],
                    child: SizedBox(
                      width: 120,
                      height: 120,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                feature['icon'],
                                size: 40,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                feature['title'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
