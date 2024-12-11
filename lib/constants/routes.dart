import 'package:flutter/material.dart';
import 'package:tour_management_app/screens/dashboard/user_home.dart';
import 'package:tour_management_app/screens/get_started/get_started_page.dart';
import 'package:tour_management_app/screens/loginSignup/loginSignup_page.dart';
import '../screens/dashboard/home_page.dart';
import '../screens/dashboard_navigation_screens/chat_screen.dart';
import '../screens/dashboard_navigation_screens/emergency_contacts/emergency_contact_screen.dart';
import '../screens/dashboard_navigation_screens/expense_screen/Expense_screen.dart';
import '../screens/dashboard_navigation_screens/group_members_screen.dart';
import '../screens/dashboard_navigation_screens/live_location_screen.dart';
import '../screens/dashboard_navigation_screens/profile_screen.dart';
import '../screens/dashboard_navigation_screens/routes_screen/route_display_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String liveLocation = '/liveLocation';
  static const String groupMembers = '/groupMembers';
  static const String profile = '/profile';
  static const String getStarted = '/getStarted';
  static const String loginSignup = '/loginSignup';
  static const String chat = '/chat';
  static const String routeDisplay = '/routeDisplay';
  static const String emergencyContact = '/emergencyContact';
  static const String addExpense = '/addExpense';
  static const String managerDetails = '/managerDetails';
  static const String userHome = '/userHome';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginSignup:
        return MaterialPageRoute(builder: (_) => LoginSignupPage());
      case getStarted:
        return MaterialPageRoute(builder: (_) => const GetStartedPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case liveLocation:
        return MaterialPageRoute(builder: (_) => const LiveLocationScreen());
      case groupMembers:
        final groupId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => GroupMembersScreen(groupId: groupId),
        );
      case profile:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(
            groupId: args?['groupId'],
            isManagerProfile: args?['isManagerProfile'] ?? false,
          ),
        );
      case chat:
        final groupId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(groupId: groupId),
        );
      case userHome:
        final groupId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => UserHome(groupId: groupId),
        );
      case routeDisplay:
        final groupId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => RouteDisplayScreen(groupId: groupId),
        );
      case emergencyContact:
        return MaterialPageRoute(builder: (_) => EmergencyContactsScreen());
      case addExpense:
        final groupId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AddExpenseScreen(groupId: groupId),
        );
      case managerDetails:
        final groupId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(groupId: groupId, isManagerProfile: true),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found')),
      ),
    );
  }
}
