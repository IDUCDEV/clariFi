
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    // ignore: unused_field
    super.initState();

    Timer(const Duration(seconds: 3), () async {
      // Navigate to the onboarding screen after 3 seconds
      GoRouter.of(context).go('/login');
    });
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 253, 252, 252),
      body: Center(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace with your app logo
              Image.asset(
                'lib/assets/logo.png',
                width: 230,
                height: 230,
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 16),
              const Text(
                '© 2025 Developed By No country simulations',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}