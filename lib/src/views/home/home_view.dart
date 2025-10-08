import 'package:clarifi_app/src/viewmodels/auth_viewmodel.dart';
import 'package:clarifi_app/src/views/accounts/create_account_view.dart';
import 'package:clarifi_app/src/colors/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  void _showCreateAccountModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => const CreateAccountView(),
    );
  }

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
        onPressed: () => _showCreateAccountModal(context),
        tooltip: 'Crear Nueva Cuenta',
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}