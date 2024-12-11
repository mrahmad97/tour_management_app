import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget largeScreen;
  final Widget mediumScreen;
  final Widget smallScreen;

  const ResponsiveWidget({
    Key? key,
    required this.largeScreen,
    required this.mediumScreen,
    required this.smallScreen,
  }) : super(key: key);

  // Helper method to determine if the screen size is small
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 500;
  }

  // Helper method to determine if the screen size is large
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 1000;
  }

  // Helper method to determine if the screen size is medium
  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 500 &&
        MediaQuery.of(context).size.width <= 1000;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1000) {
          return largeScreen; // Render for large screens
        } else if (constraints.maxWidth >= 500) {
          return mediumScreen; // Render for medium screens
        } else {
          return smallScreen; // Render for small screens
        }
      },
    );
  }
}
