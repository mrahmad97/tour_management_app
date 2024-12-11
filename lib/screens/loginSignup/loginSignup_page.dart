import 'package:flutter/material.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/screens/global_components/responsive_widget.dart';

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
        child: ResponsiveWidget(largeScreen: _buildLargeScreen(context),
          mediumScreen: _buildMediumScreen(context),
          smallScreen: _buildSmallScreen(context),
        ),
      ),
    );
  }
  Widget _buildSmallScreen(BuildContext context){
    return _buildColumn(context);
  }
  Widget _buildMediumScreen(BuildContext context){
    return Center(
      child: SizedBox(
          width: MediaQuery.of(context).size.width * 2/3,
          child: _buildColumn(context),),
    );

  }
  
  Widget _buildLargeScreen(BuildContext context){
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1/3,
        child: _buildColumn(context),),
    );
  }

  Widget _buildColumn(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20,),
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
    );
  }
}
