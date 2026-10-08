import 'package:care_circle/admin/admin_login.dart';
import 'package:care_circle/auth/login_page.dart';
import 'package:care_circle/auth/splash.dart';
import 'package:care_circle/database/hivedb.dart';
import 'package:care_circle/orphanage_screens/manage_require.dart';
import 'package:care_circle/orphanage_screens/orp_navigation.dart';
import 'package:care_circle/orphanage_screens/orphanage_home.dart';
import 'package:care_circle/providers/auth_provider.dart';
import 'package:care_circle/providers/donation_provider.dart';
import 'package:care_circle/providers/orphanage_provider.dart';
import 'package:care_circle/user_screens/orp_details.dart';
import 'package:care_circle/user_screens/uhomepage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive - keep this for now
  await HiveDB.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrphanageProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => DonationProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Care_Circle',
      debugShowCheckedModeBanner: false,
      home: onboardingscrn(),
    );
  }
}