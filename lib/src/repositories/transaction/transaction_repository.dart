import '../../models/transaction.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions({int offset = 0, int limit = 20});
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
  Future<TransactionModel?> getTransactionById(String id);
}
