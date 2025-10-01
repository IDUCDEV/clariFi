
import 'package:flutter/material.dart';

class TransactionFormView extends StatelessWidget {
  const TransactionFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Transaction')),
      body: const Center(
        child: Text('Transaction Form View'),
      ),
    );
  }
}
