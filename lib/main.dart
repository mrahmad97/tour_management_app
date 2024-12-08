import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tour_management_app/providers/user_provider.dart';
import 'package:tour_management_app/screens/create_group_screen/create_group_screen.dart';
import 'package:tour_management_app/screens/get_started/get_started_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
      ChangeNotifierProvider(
      create: (_) => UserProvider(),)
  ],
  child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tour Management App',
      initialRoute: AppRoutes.getStarted,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
