import '../../models/transaction.dart';

abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions({
    int offset = 0,
    int limit = 20,
  });
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String transactionId);
  Future<TransactionModel?> getTransactionById(String id);
  Future<void> transferBetweenAccounts(
    String fromAccountId,
    String toAccountId,
    double amount,
    String? note,
  );
  Future<TransactionModel?> getPartnerTransfer(String id, String transferId);
  Future<void> deleteTransferPair(String transferId);
  Future<void> updateTransferPair(TransactionModel tx);
  Future<Map<String, dynamic>> getAccountsBalances(String accountId);
  Future<Map<String, double>> getAccountsBalances2(String fromId, String toId);
  Future<Map<String, dynamic>> getTransferPair(String transferId);
}
