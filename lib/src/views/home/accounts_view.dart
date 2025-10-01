
import 'package:flutter/material.dart';

class AccountsView extends StatelessWidget {
  const AccountsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accounts')),
      body: const Center(
        child: Text('Accounts View'),
      ),
    );
  }
}
