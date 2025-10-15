import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import 'transaction_repository.dart';

class SupabaseTransactionRepository implements TransactionRepository {
  final SupabaseClient _supabase;

  SupabaseTransactionRepository(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('transactions')
          .select('*, accounts(name), categories(name)')
          .eq('user_id', userId)
          .order('date', ascending: false);

      print('✅ [Repo] Transacciones cargadas: ${response.length}');

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      print('🔴 [Repo] Error al obtener transacciones: $e');
      throw Exception('Error al obtener transacciones: $e');
    }
  }

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      final data = transaction.toJson()..remove('id');
      data['user_id'] = userId;

      print('🟣 [Repo] Creando transacción: $data');

      final response = await _supabase
          .from('transactions')
          .insert(data)
          .select()
          .single();

      print('✅ [Repo] Transacción creada: $response');
    } catch (e) {
      print('🔴 [Repo] Error al crear transacción: $e');
      throw Exception('Error al crear transacción: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase
          .from('transactions')
          .update(transaction.toJson())
          .eq('id', transaction.id)
          .eq('user_id', userId);

      print('✅ [Repo] Transacción actualizada: ${transaction.id}');
    } catch (e) {
      print('🔴 [Repo] Error al actualizar transacción: $e');
      throw Exception('Error al actualizar transacción: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _supabase
          .from('transactions')
          .delete()
          .eq('id', transactionId)
          .eq('user_id', userId);

      print('🗑️ [Repo] Transacción eliminada: $transactionId');
    } catch (e) {
      print('🔴 [Repo] Error al eliminar transacción: $e');
      throw Exception('Error al eliminar transacción: $e');
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    try {
      final userId = _currentUserId;
      if (userId == null) throw Exception('Usuario no autenticado');

      final response = await _supabase
          .from('transactions')
          .select('*, accounts(name), categories(name)')
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return TransactionModel.fromJson(response);
    } catch (e) {
      print('🔴 [Repo] Error al obtener transacción por ID: $e');
      throw Exception('Error al obtener transacción: $e');
    }
  }
}
