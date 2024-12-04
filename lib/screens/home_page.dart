import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/screens/loginSignup/loginSignup_page.dart';

import '../providers/user_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use listen: true to rebuild when the user changes
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: userProvider.user != null
                ? Text('Welcome, ${userProvider.user!.displayName}')
                : Text('No user signed in'),
          ),
          ElevatedButton(
            onPressed: () async {
              await userProvider
                  .signOut(); // This will trigger the sign out method
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginSignupPage(),
              ));
            },
            child: Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
