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

  } on PostgrestException catch (e) {
  // Capturamos el mensaje que viene desde la función SQL
  if (e.message.contains('Saldo insuficiente')) {
    throw Exception('Saldo insuficiente: no puedes gastar más de lo que tienes en la cuenta.');
  } else {
    throw Exception('Error del servidor: ${e.message}');
  }
} catch (e) {
  throw Exception('Error al crear transacción: $e');
}
}

@override
Future<void> updateTransaction(TransactionModel newTransaction) async {
  try {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    // 1️⃣ Obtener la transacción anterior
    final oldTx = await _supabase
        .from('transactions')
        .select('account_id, budget_id, type, amount')
        .eq('id', newTransaction.id)
        .single();

    if (oldTx == null) throw Exception('Transacción anterior no encontrada');

    final oldAccountId = oldTx['account_id'];
    final oldBudgetId = oldTx['budget_id'];
    final oldType = oldTx['type'];
    final oldAmount = (oldTx['amount'] as num).toDouble();

    // 2️⃣ Revertir el efecto anterior
    if (oldAccountId != null) {
      if (oldType == 'expense') {
        await _supabase.rpc('increase_account_amount', params: {
          'p_account_id': oldAccountId,
          'p_amount': oldAmount,
        });
      } else if (oldType == 'income') {
        await _supabase.rpc('decrease_account_amount', params: {
          'p_account_id': oldAccountId,
          'p_amount': oldAmount,
        });
      }
    }

    if (oldBudgetId != null) {
      if (oldType == 'expense') {
        await _supabase.rpc('increase_budget_amount', params: {
          'p_budget_id': oldBudgetId,
          'p_amount': oldAmount,
        });
      } else if (oldType == 'income') {
        await _supabase.rpc('decrease_budget_amount', params: {
          'p_budget_id': oldBudgetId,
          'p_amount': oldAmount,
        });
      }
    }

    // 3️⃣ Actualizar los datos de la transacción
    await _supabase
        .from('transactions')
        .update(newTransaction.toJson())
        .eq('id', newTransaction.id);

    // 4️⃣ Aplicar el nuevo efecto
    if (newTransaction.accountId != null) {
      if (newTransaction.type == 'expense') {
        await _supabase.rpc('decrease_account_amount', params: {
          'p_account_id': newTransaction.accountId,
          'p_amount': newTransaction.amount,
        });
      } else if (newTransaction.type == 'income') {
        await _supabase.rpc('increase_account_amount', params: {
          'p_account_id': newTransaction.accountId,
          'p_amount': newTransaction.amount,
        });
      }
    }

    if (newTransaction.budgetId != null) {
      if (newTransaction.type == 'expense') {
        await _supabase.rpc('decrease_budget_amount', params: {
          'p_budget_id': newTransaction.budgetId,
          'p_amount': newTransaction.amount,
        });
      } else if (newTransaction.type == 'income') {
        await _supabase.rpc('increase_budget_amount', params: {
          'p_budget_id': newTransaction.budgetId,
          'p_amount': newTransaction.amount,
        });
      }
    }

    print('🟢 Transacción actualizada correctamente');
  } catch (e) {
    print('🔴 Error al actualizar transacción: $e');
    throw Exception('Error al actualizar transacción: $e');
  }
}


@override
Future<void> deleteTransaction(String transactionId) async {
  try {
    final userId = _currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    // 1️⃣ Obtener la transacción antes de eliminarla
    final transaction = await _supabase
        .from('transactions')
        .select('account_id, budget_id, type, amount')
        .eq('id', transactionId)
        .single();

    final accountId = transaction['account_id'];
    final budgetId = transaction['budget_id'];
    final type = transaction['type'];
    final amount = (transaction['amount'] as num).toDouble();

    // 2️⃣ Revertir el efecto según el origen (cuenta o presupuesto)
    if (accountId != null) {
      if (type == 'expense') {
        // Se elimina un gasto → devolver saldo a la cuenta
        await _supabase.rpc('increase_account_amount', params: {
          'p_account_id': accountId,
          'p_amount': amount,
        });
      } else if (type == 'income') {
        // Se elimina un ingreso → reducir saldo de la cuenta
        await _supabase.rpc('decrease_account_amount', params: {
          'p_account_id': accountId,
          'p_amount': amount,
        });
      }
    } else if (budgetId != null) {
      if (type == 'expense') {
        // Se elimina un gasto → devolver monto al presupuesto
        await _supabase.rpc('increase_budget_amount', params: {
          'p_budget_id': budgetId,
          'p_amount': amount,
        });
      } else if (type == 'income') {
        // Se elimina un ingreso → restar monto del presupuesto
        await _supabase.rpc('decrease_budget_amount', params: {
          'p_budget_id': budgetId,
          'p_amount': amount,
        });
      }
    }

    // 3️⃣ Eliminar la transacción
    await _supabase.from('transactions').delete().eq('id', transactionId);

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
  // Dentro de SupabaseTransactionRepository
@override
Future<void> transferBetweenAccounts( String fromAccountId, String toAccountId, double amount,
  String? note) async {
  try {
    // 1️⃣ Validar que no sea la misma cuenta
    if (fromAccountId == toAccountId) {
      throw Exception('No puedes transferir entre la misma cuenta.');
    }

    // 2️⃣ Validar que la cuenta origen tenga saldo suficiente
    final fromAccount = await _supabase
        .from('accounts')
        .select('balance')
        .eq('id', fromAccountId)
        .maybeSingle();

    if (fromAccount == null) {
      throw Exception('Cuenta origen no encontrada.');
    }

    final currentBalance = (fromAccount['balance'] as num).toDouble();
    if (currentBalance < amount) {
      throw Exception('Saldo insuficiente en la cuenta origen.');
    }

    // 3️⃣ Ejecutar transferencia en Supabase (función RPC que tú defines)
   await _supabase.rpc('transfer_between_accounts', params: {
  'p_from_account_id': fromAccountId,
  'p_to_account_id': toAccountId,
  'p_amount': amount,
  'p_note': note ?? '',
});
  } on PostgrestException catch (e) {
    throw Exception('Error de base de datos: ${e.message}');
  } catch (e) {
    throw Exception('Error al transferir: $e');
  }
}

}
