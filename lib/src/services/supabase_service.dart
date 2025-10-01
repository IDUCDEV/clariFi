
import 'package:clarifi_app/src/models/account.dart';
import 'package:clarifi_app/src/models/category.dart';
import 'package:clarifi_app/src/models/transaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

  // --- Transactions ---

  Future<List<TransactionModel>> fetchTransactions({DateTime? from, DateTime? to}) async {
    try {
      // Use PostgREST syntax for filtering. The response is cast to a List.
      final response = await client
          .from('transactions')
          .select()
          .eq('user_id', client.auth.currentUser!.id)
          .order('date', ascending: false);
      
      // Map the JSON list to a list of TransactionModel objects
      return response.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      // Simple error handling
      print('Error fetching transactions: $e');
      return [];
    }
  }

  Future<void> insertTransaction(TransactionModel transaction) async {
    try {
      await client.from('transactions').insert(transaction.toJson());
      // As the design doc suggests, you might want to call an edge function 
      // from here to update account balances or check budgets.
    } catch (e) {
      print('Error inserting transaction: $e');
      // Re-throwing the error allows the ViewModel to catch it and show a message to the user.
      rethrow;
    }
  }

  // --- Accounts ---

  Future<List<AccountModel>> fetchAccounts() async {
    try {
      final response = await client
          .from('accounts')
          .select()
          .eq('user_id', client.auth.currentUser!.id);

      return response.map((json) => AccountModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching accounts: $e');
      return [];
    }
  }

  // --- Categories ---

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final response = await client
          .from('categories')
          .select()
          .eq('user_id', client.auth.currentUser!.id);

      return response.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
  
  // You can add other methods for budgets, user profiles, etc. following the same pattern.
}
