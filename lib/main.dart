import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'authentication/get_started_screen.dart'; // Import the new starting screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MinggleApp());
}

class MinggleApp extends StatelessWidget {
  const MinggleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minggle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      // Change this from PhoneInputScreen to GetStartedScreen
      home: const GetStartedScreen(),
    );
  }
}
