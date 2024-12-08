import 'package:flutter/material.dart';
import 'package:tour_management_app/screens/get_started/get_started_page.dart';
import 'package:tour_management_app/screens/loginSignup/loginSignup_page.dart';
import '../screens/dashboard/home_page.dart';
import '../screens/dashboard_navigation_screens/group_members_screen.dart';
import '../screens/dashboard_navigation_screens/live_location_screen.dart';
import '../screens/dashboard_navigation_screens/profile_screen.dart';

class AppRoutes {
  static const String home = '/home';
  static const String liveLocation = '/liveLocation';
  static const String groupMembers = '/groupMembers';
  static const String profile = '/profile';
  static const String getStarted = '/getStarted';
  static const String loginSignup = '/loginSignup';

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
        return MaterialPageRoute(builder: (_) => const GroupMembersScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
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
