import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/constants/routes.dart';
import 'package:tour_management_app/screens/dashboard/user_home.dart';
import '../../../constants/colors.dart'; // Ensure AppColors is defined here
import '../../../constants/strings.dart'; // Ensure Strings.signup is defined here
import '../../../models/signup_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/user_provider.dart';
import '../../dashboard/home_page.dart';
import '../../global_components/custom_text_field.dart'; // Ensure CustomTextFormField is implemented correctly

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String selectedType = 'selectType';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  String? _validateField(String? value, String errorKey) {
    if (value == null || value.isEmpty) {
      return errorKey; // Replace this with actual error messages
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final error = _validateField(value, 'Email is required.');
    if (error != null) return error;

    if (!RegExp(r'^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+$').hasMatch(value!)) {
      return 'Invalid email format.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final error = _validateField(value, 'Password is required.');
    if (error != null) return error;

    if (value!.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required.';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }
  String? _validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    final RegExp regex = RegExp(r'^\+?[0-9]{7,15}$'); // Allows international and local formats
    if (!regex.hasMatch(value)) {
      return 'Enter a valid mobile number';
    }
    return null;
  }


  // Firebase sign up function using SignupModel
  Future<void> _signUp(SignupModel signupModel, BuildContext context) async {
    if (isLoading) return; // Prevent multiple signups

    setState(() {
      isLoading = true;
    });

    try {
      // Sign up user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: signupModel.email, password: signupModel.password);

      // Create a UserModel with Firebase Auth user and additional details
      UserModel userModel = UserModel(
        uid: userCredential.user!.uid,
        email: signupModel.email,
        displayName: signupModel.name,
        userType: signupModel.userType,
        phoneNumber: signupModel.phoneNumber
      );
    // Set the user in the provider
    Provider.of<UserProvider>(context, listen: false).setUser(userModel);

      // Store additional data in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': signupModel.name,
        'email': signupModel.email,
        'userType': signupModel.userType,
        'createdAt': Timestamp.now(),
        'phoneNumber': signupModel.phoneNumber,
      });


      // Optionally, fetch user data from Firestore and update UserProvider
      await Provider.of<UserProvider>(context, listen: false).fetchUserData();

      if(signupModel.userType == 'user'){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserHome(),));
      }else{
        Navigator.of(context).pushNamed(AppRoutes.home);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signup successful!')),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = 'An error occurred. Please try again.';
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
              Strings.signup,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildForm(context),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle('Name'),
          const SizedBox(height: 5),
          CustomTextFormField(
            hintKey: 'Enter your name',
            validation: _validateName,
            controller: nameController,
          ),
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
          _buildTitle('Confirm Password'),
          const SizedBox(height: 5),
          CustomTextFormField(
            hintKey: 'Confirm your password',
            validation: _validateConfirmPassword,
            controller: confirmPasswordController,
            isPassword: true,
          ),
          _buildTitle('Contact Number'),
          const SizedBox(height: 5),
          CustomTextFormField(
            hintKey: 'Enter your contact number',
            validation: _validateMobileNumber,
            controller: phoneController,
          ),
          _buildTitle('User Type'),
          const SizedBox(height: 5),
          CustomTextFormField(
            hintKey: 'Select user type',
            isDropdown: true,
            dropdownItems: [
              'selectType',
              'user',
              'manager',
            ],
            validation: (value) {
              if (value == null || value == 'selectType') {
                return 'Please select a user type.';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {
                selectedType = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() == true) {
                        // Create SignupModel and call _signUp
                        SignupModel signupModel = SignupModel(
                          name: nameController.text,
                          email: emailController.text,
                          password: passwordController.text,
                          confirmPassword: confirmPasswordController.text,
                          userType: selectedType,
                          phoneNumber: phoneController.text
                        );
                        _signUp(signupModel, context);
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Signup'),
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
