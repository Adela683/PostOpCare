import 'package:flutter/material.dart';
import 'package:postopcare/screens/login_screen.dart';
import 'package:postopcare/screens/signin_screen.dart';
import '../widgets/custom_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 94, 219, 236), // Verde pal deschis
              Color.fromARGB(255, 248, 248, 252), // Alb
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Message
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 45, 65, 120),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 0),

                // Logo Image
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Image.asset(
                    'assets/images/PostOpCare.png',
                    height: 300,
                  ),
                ),
                const SizedBox(height: 50),

                // Sign In Button
                CustomButton(
                  text: 'Create an Account',
                  onPressed: () {
                    // Handle sign in
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(
                      child: Divider(
                        color: Color.fromARGB(255, 45, 65, 120),
                        thickness: 2,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Color.fromARGB(255, 45, 65, 120),
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(
                        color: Color.fromARGB(255, 45, 65, 120),
                        thickness: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Login Button
                CustomButton(
                  text: 'Log In',
                  onPressed: () {
                    // Handle login
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
