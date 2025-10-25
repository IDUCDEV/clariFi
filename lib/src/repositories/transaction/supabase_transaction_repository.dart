import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/transaction.dart';
import 'transaction_repository.dart';

class SupabaseTransactionRepository implements TransactionRepository {
  final SupabaseClient _supabase;

  SupabaseTransactionRepository(this._supabase);

  String? get _currentUserId => _supabase.auth.currentUser?.id;

@override
Future<List<TransactionModel>> getTransactions({int offset = 0, int limit = 20}) async {
  try {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    final response = await _supabase
        .from('transactions')
        .select('*, accounts(name), categories(name)')
        .eq('user_id', userId)
        .order('date', ascending: false)
        .range(offset, offset + limit - 1);
    return (response as List)
        .map((json) => TransactionModel.fromJson(json))
        .toList();
  } catch (e) {
    throw Exception('Error al obtener transacciones: $e');
  }
}

//   @override
// Future<void> createTransaction(TransactionModel transaction) async {
//   try {
//     final userId = _currentUserId;
//     if (userId == null) throw Exception('Usuario no autenticado');

//     final data = transaction.toJson()..remove('id');
//     data['user_id'] = userId;

//     // 1️⃣ Insertar la transacción
//     final response = await _supabase
//         .from('transactions')
//         .insert(data)
//         .select()
//         .single();

//     // 2️⃣ Si está asociado a presupuesto, resta del presupuesto disponible
//     if (transaction.budgetId != null) {
//       await _supabase.rpc(
//         'subtract_from_budget',
//         params: {
//           'p_budget_id': transaction.budgetId,
//           'p_amount': transaction.amount
//         },
//       );
//     }

//     // 3️⃣ Si NO tiene presupuesto, actualizar la cuenta
//     if (transaction.budgetId == null && transaction.accountId != null) {
//       if (transaction.type == 'expense') {
//         await _supabase.rpc(
//           'decrease_account_amount',
//           params: {
//             'p_account_id': transaction.accountId,
//             'p_amount': transaction.amount
//           },
//         );
//       } else {
//         await _supabase.rpc(
//           'increase_account_amount',
//           params: {
//             'p_account_id': transaction.accountId,
//             'p_amount': transaction.amount
//           },
//         );
//       }
//     }

//   } catch (e) {
//     throw Exception('Error al crear transacción: $e');
//   }
// }

@override
Future<void> createTransaction(TransactionModel transaction) async {
  try {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    final data = transaction.toJson()..remove('id');
    data['user_id'] = userId;

    // 1️⃣ Insertar la transacción
    final response = await _supabase
        .from('transactions')
        .insert(data)
        .select()
        .single();

    // 2️⃣ Si está asociado a presupuesto, actualiza según tipo
    if (transaction.budgetId != null) {
      if (transaction.type == 'expense') {
        await _supabase.rpc(
          'subtract_from_budget',
          params: {
            'p_budget_id': transaction.budgetId,
            'p_amount': transaction.amount,
          },
        );
      } else if (transaction.type == 'income') {
        await _supabase.rpc(
          'add_to_budget',
          params: {
            'p_budget_id': transaction.budgetId,
            'p_amount': transaction.amount,
          },
        );
      }
    }

    // 3️⃣ Si NO tiene presupuesto, actualizar la cuenta
    if (transaction.budgetId == null && transaction.accountId != null) {
      if (transaction.type == 'expense') {
        await _supabase.rpc(
          'decrease_account_amount',
          params: {
            'p_account_id': transaction.accountId,
            'p_amount': transaction.amount,
          },
        );
      } else {
        await _supabase.rpc(
          'increase_account_amount',
          params: {
            'p_account_id': transaction.accountId,
            'p_amount': transaction.amount,
          },
        );
      }
    }

  } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
      throw Exception('Error al obtener transacción: $e');
    }
  }
}
