import 'package:flutter/material.dart';

import '../widgets/login_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.13,
              ),
              Image.asset(
                'assets/images/logo.png',
                color: Colors.white,
                width: 200,
                height: 200,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Welcome to Neo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              LoginButton(
                  logo: 'assets/images/google.png',
                  text: 'Sign in with Google'),
              const SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
