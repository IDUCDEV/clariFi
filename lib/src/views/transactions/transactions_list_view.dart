
import 'package:clarifi_app/src/viewmodels/transaction_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransactionsListView extends StatelessWidget {
  const TransactionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Consumer<TransactionViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: viewModel.transactions.length,
            itemBuilder: (context, index) {
              final transaction = viewModel.transactions[index];
              return ListTile(
                title: Text(transaction.note ?? 'No note'),
                subtitle: Text(transaction.amount.toString()),
              );
            },
          );
        },
      ),
    );
  }
}
