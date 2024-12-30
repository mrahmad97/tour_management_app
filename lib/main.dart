import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tour_management_app/constants/colors.dart';
import 'package:tour_management_app/functions/get_token.dart';
import 'package:tour_management_app/providers/location_provider.dart';
import 'package:tour_management_app/providers/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:universal_platform/universal_platform.dart';
import 'constants/routes.dart';
import 'firebase_options.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotification();
  await Supabase.initialize(
    url: 'https://vuxaehlafmlukabuawdo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ1eGFlaGxhZm1sdWthYnVhd2RvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQwOTUwOTgsImV4cCI6MjA0OTY3MTA5OH0.sbqaMjQiPG975T5GmS2eDbI7Exo9BQ_Ey03RHdbxj_w',
  );

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
    ),
    ChangeNotifierProvider(create: (_) => LocationProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryColor,
              primary: AppColors.primaryColor,
              surface: AppColors.surfaceColor)),
      title: 'Tour Management App',
      initialRoute: UniversalPlatform.isWeb
          ? AppRoutes.loginSignup
          : AppRoutes.getStarted,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
