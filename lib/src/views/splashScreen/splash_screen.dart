
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progressValue = 0.0;

  @override
  void initState() {
    // ignore: unused_field
    super.initState();
    
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        progressValue += 0.3333; // Increment progress by 33.33% every second
        if (progressValue >= 1.0) {
          timer.cancel();
          //print('SplashScreen: navigating to /onboarding');
          GoRouter.of(context).go('/onboarding');
        }
      });  
    });

    
  }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2EFE7),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replace with your app logo
              Image.asset(
                'lib/assets/logo.png',
                width: 230,
                height: 230,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tu claridad financiera comienza aqui',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Simplifica la gestion de tus gastos, ahorros e inversiones. Toma el control de tu dinero con una interfaz intuitiva',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progressValue,
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
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