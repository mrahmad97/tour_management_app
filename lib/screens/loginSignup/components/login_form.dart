import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/routes.dart';
import 'package:tour_management_app/models/login_model.dart';
import 'package:tour_management_app/screens/dashboard/user_home.dart';
import 'package:tour_management_app/screens/global_components/responsive_widget.dart';
import 'package:tour_management_app/screens/loginSignup/components/forget_password_screen.dart';

import '../../../constants/colors.dart'; // Ensure AppColors is defined
import '../../../constants/strings.dart'; // Ensure Strings.login is defined
import '../../../main.dart';
import '../../../models/user_model.dart';
import '../../../providers/user_provider.dart';
import '../../global_components/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  final void Function(int) switchPage;

  const LoginForm({super.key, required this.switchPage});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true; // For password visibility toggle

  Future<void> _login(LoginModel loginModel) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      isLoading = true;
    });

    try {
      // Sign in user with Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginModel.email,
        password: loginModel.password,
      );

      // Fetch user data from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      saveFcmTokenForUser(userCredential.user!.uid);

      // Create a UserModel from Firestore data
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        displayName: userDoc['name'],
        // Assuming 'name' field in Firestore
        email: userDoc['email'],
        userType: userDoc['userType'],
        // Assuming 'userType' field in Firestore
        phoneNumber: userDoc['phoneNumber'],
      );

      // Update UserProvider with the logged-in user's information
      userProvider.setUser(userModel);

      // Fetch the groupId where the user is a member
      // Fetch the groupId where the user is a member
      String? groupId;
      if (userDoc['userType'] == 'user') {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('groups')
            .where('members',
                arrayContains: userCredential.user!.uid) // Ensure correct field
            .get();

        // Check if the query returned any documents
        if (querySnapshot.docs.isNotEmpty) {
          groupId = querySnapshot.docs.first.id; // Get the groupId
          print('gorup id ${groupId}');
        } else {
          groupId = null; // No group found
        }
      }

      // Navigate based on user type and pass the groupId if user
      if (userDoc['userType'].toLowerCase() == 'user') {
        NavigationService.navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => UserHome(
            groupId: groupId,
          ),
        ));
      } else {
        Navigator.of(context).pushNamed(AppRoutes.home);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'This operation is not allowed.';
          break;
        default:
          errorMessage = 'Error: ${e.code}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }
    if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+$').hasMatch(value)) {
      return 'Please enter a valid email.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Strings.welcomeBack, // Replace with your localized string
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            Text(
              Strings.enterCredentials, // Replace with your localized string
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            _buildForm(context),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t Have an account?  '),
                GestureDetector(
                    onTap: () => widget.switchPage(1),
                    child: Text(
                      "Signup",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  void saveFcmTokenForUser(String userId) async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      // Store the FCM token in Firestore under the 'users' collection
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true)); // Merge to avoid overwriting existing data
    }
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle('Email'),
          const SizedBox(height: 5),
          CustomTextFormField(
            hintKey: 'Enter your email',
            validation: _validateEmail,
            controller: emailController,
          ),
          _buildTitle('Password'),
          const SizedBox(height: 5),
          CustomTextFormField(
            hintKey: 'Enter your password',
            validation: _validatePassword,
            controller: passwordController,
            isPassword: true,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPasswordScreen(),));
                },
                child: Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                      ResponsiveWidget.isLargeScreen(context)
                          ? MediaQuery.of(context).size.width * 1 / 2
                          : MediaQuery.of(context).size.width * 2 / 3,
                      ResponsiveWidget.isLargeScreen(context) ? 50 : 40),
                  foregroundColor: AppColors.surfaceColor,
                  backgroundColor: AppColors.primaryColor),
              onPressed: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() == true) {
                        _login(LoginModel(
                          email: emailController.text,
                          password: passwordController.text,
                        ));
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: AppColors.surfaceColor,
                    )
                  : const Text('Login'),
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
