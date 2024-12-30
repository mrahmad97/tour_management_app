import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/constants/routes.dart';
import 'package:tour_management_app/screens/dashboard_navigation_screens/emergency_contacts/emergency_contact_screen.dart';
import 'package:tour_management_app/screens/dashboard_navigation_screens/location_screen/web_location_screen.dart';
import 'package:tour_management_app/screens/global_components/responsive_widget.dart';
import '../../functions/fetch_realtime_service.dart';
import '../../functions/realtime_location_service.dart';
import '../../main.dart';
import '../../providers/location_provider.dart';
import '../../providers/user_provider.dart';
import '../dashboard_navigation_screens/chat_screen.dart';
import '../dashboard_navigation_screens/expense_screen/Expense_screen.dart';
import '../dashboard_navigation_screens/group_members_screen.dart';
import '../dashboard_navigation_screens/profile_screen.dart';
import '../dashboard_navigation_screens/routes_screen/route_display_screen.dart';

class UserHome extends StatefulWidget {
  final String? groupId;

  const UserHome({super.key, this.groupId});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;

  List<Map<String, dynamic>> getFeatures(BuildContext context) {
    return [
      {
        'title': 'Chat',
        'navigateTo': () =>
            NavigationService.navigatorKey.currentState?.pushNamed(
              AppRoutes.chat,
              arguments: widget.groupId,
            ),
        'image': 'assets/chat .png',
        'icon': Icons.chat,
      },
      {
        'title': 'Live Location',
        'navigateTo': () => NavigationService.navigatorKey.currentState
            ?.pushNamed(AppRoutes.liveLocation),
        'image': 'assets/map.png',
        'icon': Icons.location_on,
      },
      {
        'title': 'Group Members',
        'navigateTo': () =>
            NavigationService.navigatorKey.currentState?.pushNamed(
              AppRoutes.groupMembers,
              arguments: widget.groupId,
            ),
        'image': 'assets/group.png',
        'icon': Icons.group,
      },
      {
        'title': 'Route',
        'navigateTo': () =>
            NavigationService.navigatorKey.currentState?.pushNamed(
              AppRoutes.routeDisplay,
              arguments: widget.groupId,
            ),
        'image': 'assets/route.png',
        'icon': Icons.map,
      },
      {
        'title': 'Emergency Contact',
        'navigateTo': () => NavigationService.navigatorKey.currentState
            ?.pushNamed(AppRoutes.emergencyContact),
        'image': 'assets/emergency_contact.png',
        'icon': Icons.contact_phone,
      },
      {
        'title': 'Profile',
        'navigateTo': () =>
            NavigationService.navigatorKey.currentState?.pushNamed(
              AppRoutes.profile,
              arguments: {'groupId': widget.groupId},
            ),
        'image': 'assets/profile.png',
        'icon': Icons.person,
      },
      {
        'title': 'Expense',
        'navigateTo': () =>
            NavigationService.navigatorKey.currentState?.pushNamed(
              AppRoutes.addExpense,
              arguments: widget.groupId,
            ),
        'image': 'assets/expense.png',
        'icon': Icons.attach_money,
      },
      {
        'title': 'Manager Details',
        'navigateTo': () =>
            NavigationService.navigatorKey.currentState?.pushNamed(
              AppRoutes.managerDetails,
              arguments: widget.groupId,
            ),
        'image': 'assets/manager.png',
        'icon': Icons.business_center,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    final userProvider =
        provider.Provider.of<UserProvider>(context, listen: false);
    if (!kIsWeb) {
      final FetchRealtimeService _fetchRealtimeService = FetchRealtimeService();
      final RealtimeDatabaseService _realtimeDatabaseService =
          RealtimeDatabaseService();

      if (widget.groupId != null) {
        _realtimeDatabaseService.startUpdatingLocation(
          userProvider.user!.uid,
          userProvider.user!.displayName,
          widget.groupId!,
        );
      }
      final locationProvider =
          provider.Provider.of<LocationProvider>(context, listen: false);

      // Start fetching users based on groupId and currentUserId
      _fetchRealtimeService.startFetchingUsers(
        widget.groupId,
        userProvider.user!.uid,
        (updatedUsers, currentUser) {
          locationProvider.updateUsersLocation(updatedUsers);
          locationProvider.updateCurrentUserLocation(currentUser);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Dashboard',
          style: TextStyle(color: AppColors.surfaceColor),
        ),
        backgroundColor: AppColors.primaryColor,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: AppColors.surfaceColor,
      body: SafeArea(
        child: ResponsiveWidget(
          largeScreen: _buildLargeScreen(context),
          mediumScreen: _buildMediumScreen(context),
          smallScreen: _buildSmallScreen(context),
        ),
      ),
    );
  }

  Widget _buildLargeScreen(BuildContext context) {
    final groupId = widget.groupId;

    return Column(
      children: [
        if (groupId == null) _buildWarning(context),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildListItems(context)),
              Expanded(
                flex: 4,
                child: SideScreen(
                  features: getFeatures(context),
                  selectedIndex: _selectedIndex,
                  groupId: widget.groupId,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediumScreen(BuildContext context) {
    return _buildGridItems(context);
  }

  Widget _buildSmallScreen(BuildContext context) {
    final user = provider.Provider.of<UserProvider>(context).user;
    final name = user?.displayName;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 1 / 4,
            width: MediaQuery.of(context).size.width,
            color: AppColors.categoryBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/tours.png'),
                Text(
                  'Welcome $name',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.surfaceColor),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          _buildListItemsMobile(context),
        ],
      ),
    );
  }

  Widget _buildGridItems(BuildContext context) {
    final features = getFeatures(context);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveWidget.isSmallScreen(context) ? 2 : 3,
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
              color: AppColors.cardBackgroundColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: Image.asset(
                        feature['image'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItemsMobile(BuildContext context) {
    final features = getFeatures(context);

    return Column(
      children: features.map((feature) {
        return GestureDetector(
          onTap: feature['navigateTo'],
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: AppColors.cardBackgroundColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Feature Image
                  SizedBox(
                    height: 60,
                    width: 60,
                    child: Image.asset(feature['image']),
                  ),
                  const SizedBox(width: 16),
                  // Feature Title
                  Expanded(
                    child: Text(
                      feature['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWarning(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'You are not present in any group, kindly contact your manager.',
        style: TextStyle(
          fontSize: ResponsiveWidget.isSmallScreen(context) ? 16 : 20,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildListItems(BuildContext context) {
    final features = getFeatures(context);

    return ListView.builder(
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            color: _selectedIndex == index
                ? AppColors.iconColor
                : Colors.transparent,
            child: Row(
              children: [
                Icon(
                  feature['icon'],
                  size: 25,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    feature['title'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SideScreen extends StatelessWidget {
  final List<Map<String, dynamic>> features;
  final int selectedIndex;
  final String? groupId;

  const SideScreen(
      {super.key,
      required this.features,
      required this.selectedIndex,
      this.groupId});

  @override
  Widget build(BuildContext context) {
    // Use the selected index to dynamically build the target page
    final targetWidget = _buildTargetScreen(selectedIndex);

    return Scaffold(
      body: targetWidget,
    );
  }

  Widget _buildTargetScreen(int index) {
    switch (index) {
      case 0:
        return ChatScreen(groupId: groupId);
      case 1:
        return WebLocationScreen();
      case 2:
        return GroupMembersScreen(groupId: groupId);
      case 3:
        return RouteDisplayScreen(groupId: groupId);
      case 4:
        return EmergencyContactsScreen();
      case 5:
        return ProfileScreen(groupId: groupId);
      case 6:
        return AddExpenseScreen(groupId: groupId);
      case 7:
        return ProfileScreen(
          groupId: groupId,
          isManagerProfile: true,
        );
      default:
        return Center(child: Text('Feature not implemented'));
    }
  }
}
