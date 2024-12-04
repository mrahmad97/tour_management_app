import 'package:flutter/material.dart';
import 'package:tour_management_app/constants/colors.dart';

import '../../constants/strings.dart';
import 'components/login_form.dart';
import 'components/signup_form.dart';

class LoginSignupPage extends StatefulWidget {
  @override
  _LoginSignupPageState createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  int _currentPage = 0;

  final PageController _pageController = PageController();

  void _switchPage(int index) {
    setState(() {
      _currentPage = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _switchPage(0),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage == 0
                        ? AppColors.primaryColor
                        : AppColors.iconColor,
                      foregroundColor: AppColors.surfaceColor
                  ),
                  child: Text(Strings.login),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _switchPage(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentPage == 1
                        ? AppColors.primaryColor
                        : AppColors.iconColor,
                    foregroundColor: AppColors.surfaceColor
                  ),
                  child: Text(Strings.signup),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  LoginForm(),
                  SignupForm(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
