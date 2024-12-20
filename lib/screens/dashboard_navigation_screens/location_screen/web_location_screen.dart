import 'package:flutter/material.dart';
import 'package:tour_management_app/constants/colors.dart';

class WebLocationScreen extends StatelessWidget {
  const WebLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Location', style: TextStyle(color: AppColors.surfaceColor)),
        backgroundColor: AppColors.primaryColor,
      ),
      backgroundColor: AppColors.surfaceColor,
      body: Center(child: Text('Maps are not available for web.'),),
    );
  }
}
