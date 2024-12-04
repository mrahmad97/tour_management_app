import 'package:flutter/material.dart';
import 'package:tour_management_app/screens/home_page.dart';
import 'package:tour_management_app/screens/loginSignup/loginSignup_page.dart';
import '../../../constants/colors.dart';
import '../../../constants/strings.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> imagePaths = [
    'assets/get_started/mountains.png',
    'assets/get_started/hiking.png',
    'assets/get_started/camping.png',
  ];

  final List<String> titles = [
    Strings.firstTitle,
    Strings.secondTitle,
    Strings.thirdTitle,
  ];

  void _onNextPressed() {
    if (_currentIndex < imagePaths.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => LoginSignupPage(),
      ));
    }
  }

  void _onSkipPressed() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => LoginSignupPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // PageView with images
            SizedBox(
              height: 0.6 * screenHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: imagePaths.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: screenWidth,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(imagePaths[index]),
                    ),
                  );
                },
              ),
            ),

            // Spacing
            SizedBox(height: 20),

            // Text based on the current index
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                titles[_currentIndex],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ),

            // Spacing
            SizedBox(height: 20),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imagePaths.asMap().entries.map((entry) {
                return Container(
                  width: 10,
                  height: 10,
                  margin:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == entry.key
                        ? AppColors.primaryColor
                        : AppColors.iconColor,
                  ),
                );
              }).toList(),
            ),

            // Spacing
            Spacer(),

            // Skip and Next Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip Button
                  TextButton(
                    onPressed: _onSkipPressed,
                    child: Text(
                      'Skip',
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                  ),

                  // Next Button
                  ElevatedButton(
                    onPressed: _onNextPressed,
                    child: Text(
                      _currentIndex == imagePaths.length - 1
                          ? 'Finish'
                          : 'Next',
                    ),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.surfaceColor,
                        backgroundColor: AppColors.primaryColor),
                  ),
                ],
              ),
            ),

            // Spacing
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
