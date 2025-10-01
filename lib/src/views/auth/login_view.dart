
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Example of how to access the ViewModel
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your TextFormFields and Button here
            const Text('Login View'),
            ElevatedButton(
              onPressed: () {
                // Example login call
                // authViewModel.login('test@example.com', 'password');
              },
              child: const Text('Login'),
            ),
            TextButton(
              onPressed: () => context.go('/signup'),
              child: const Text('Don\'t have an account? Sign up'),
            )
          ],
        ),
      ),
    );
  }
}
