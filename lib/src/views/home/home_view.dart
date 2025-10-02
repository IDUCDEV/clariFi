
import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authViewModel.logout();
            },
          )
        ],
      ),
      body: const Center(
        child: Text('Home View'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/transactions/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
