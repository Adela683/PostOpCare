import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'screens/signin_screen.dart';

void main() {
  runApp(const PostOpCareApp());
}

class PostOpCareApp extends StatelessWidget {
  const PostOpCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PostOpCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
