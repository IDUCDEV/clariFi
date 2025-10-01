
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:clarifi_app/src/views/auth/login_view.dart';
import 'package:clarifi_app/src/views/auth/signup_view.dart';
import 'package:clarifi_app/src/views/home/home_view.dart';
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
          name: 'home',
          path: '/',
          builder: (context, state) => const HomeView(),
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
      redirect: (BuildContext context, GoRouterState state) {
        final isAuthenticated = authViewModel.isAuthenticated;
        
        final isLoggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/signup';

        // If user is not authenticated and not trying to log in, redirect to login
        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        // If user is authenticated and tries to go to login/signup, redirect to home
        if (isAuthenticated && isLoggingIn) {
          return '/';
        }

        return null; // No redirect needed
      },
    );
  }
}
