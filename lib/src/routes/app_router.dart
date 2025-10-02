
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:clarifi_app/src/views/auth/login_view.dart';
import 'package:clarifi_app/src/views/auth/signup_view.dart';
import 'package:clarifi_app/src/views/home/home_view.dart';
import 'package:clarifi_app/src/views/onboarding/onboarding.dart';
import 'package:clarifi_app/src/views/splashScreen/splash_screen.dart';
import 'package:clarifi_app/src/views/transactions/transaction_form_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final AuthViewModel authViewModel;
  late final GoRouter router;

  AppRouter(this.authViewModel) {
    router = GoRouter(
      refreshListenable: authViewModel,
      initialLocation: '/',
      routes: [
        GoRoute(
          name: 'splashScreen',
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          name: 'onboarding',
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          name: 'login',
          path: '/login',
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          name: 'signup',
          path: '/signup',
          builder: (context, state) => const SignupView(),
        ),
        GoRoute(
          name: 'new-transaction',
          path: '/transactions/new',
          builder: (context, state) => const TransactionFormView(),
        ),
      ],
      
    );
  }
}
