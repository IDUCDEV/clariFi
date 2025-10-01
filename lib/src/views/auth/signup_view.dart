
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Signup View'),
            ElevatedButton(
              onPressed: () {
                // Example signup call
                // authViewModel.signUp('test@example.com', 'password');
              },
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Login'),
            )
          ],
        ),
      ),
    );
  }
}
