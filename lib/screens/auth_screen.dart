import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  // create and return a state object
  // that will hold the state of the widget
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:const EdgeInsets.all(30),
                child:Image.asset(
                  'assets/images/PostOpCare.png',
                  height: 300,
                )
              ),
              const SizedBox(height: 50),
              CustomButton(
                  text: 'Sign In',
                  onPressed: () {
                    // Handle sign in
                  },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child:Divider(color: const Color.fromARGB(255, 48, 42, 42), thickness: 1.5)),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: const Text('or', style: TextStyle(color: Color.fromARGB(255, 48, 42, 42), fontSize: 16))
                  ),
                  Expanded(child:Divider(color: const Color.fromARGB(255, 48, 42, 42), thickness: 1.5)),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(
                  text: 'Log in',
                  onPressed: () {
                    // Handle sign up
                  },
              ),
            ]
          )
         )
      )
    );
  }
}