import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'screens/auth/phone_input_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase report eke thiyena widiyata setup kirima
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
      home: const PhoneInputScreen(), // Mulinnma yana screen eka
    );
  }
}
