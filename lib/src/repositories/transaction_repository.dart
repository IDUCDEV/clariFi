import '../models/transaction.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions();
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
  Future<TransactionModel?> getTransactionById(String id);
}
