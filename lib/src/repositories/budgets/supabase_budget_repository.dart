import 'package:clarifi_app/src/models/budget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseBudgetRepository {
  final SupabaseClient _supabaseClient;

  SupabaseBudgetRepository(this._supabaseClient);

  // Métodos para interactuar con la base de datos de Supabase
  String? get _currentUserId => _supabaseClient.auth.currentUser?.id;

  //registrar presupuesto
  Future<void> createBudget(
    String name,
    double amount,
    String period,
    String? categoryId,
    DateTime startDate,
    DateTime endDate,
    double? alertThreshold,
    String accountId,
  ) async {
    final userId = _currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final budget = BudgetModel(
        name: name,
        amount: amount,
        period: period,
        userId: userId,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
        alertThreshold: alertThreshold,
        accountId: accountId,
      );

      

      final data = budget.toJson();
      // Excluir campos generados por la DB
      data.remove('id');
      data.remove('created_at');

      await _supabaseClient.from('budgets').insert(data);
      
    } on PostgrestException catch (e) {
      throw Exception('Error creando presupuesto: ${e.message}');
    } catch (e) {
      throw Exception('Error creando presupuesto: $e');
    }
  }

  Future<List<BudgetModel>> getBudgets() async {
    final userId = _currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabaseClient
          .from('budgets')
          .select('*, accounts(name), categories(name)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map((json) {
        // Extraer el nombre de la cuenta del join
        final accountData = json['accounts'] as Map<String, dynamic>?;
        if (accountData != null) {
          json['account_name'] = accountData['name'];
        }
        // Extraer el nombre de la categoría del join
        final categoryData = json['categories'] as Map<String, dynamic>?;
        if (categoryData != null) {
          json['category_name'] = categoryData['name'];
        }
        return BudgetModel.fromJson(json);
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener presupuestos: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener presupuestos: $e');
    }
  }

  Future<BudgetModel?> getBudgetById(String budgetId) async {
    final userId = _currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabaseClient
          .from('budgets')
          .select('*, accounts(name), categories(name)')
          .eq('id', budgetId)
          .eq('user_id', userId)
          .single();

      // Extraer el nombre de la cuenta del join
      final accountData = response['accounts'] as Map<String, dynamic>?;
      if (accountData != null) {
        response['account_name'] = accountData['name'];
      }
      // Extraer el nombre de la categoría del join
      final categoryData = response['categories'] as Map<String, dynamic>?;
      if (categoryData != null) {
        response['category_name'] = categoryData['name'];
      }

      return BudgetModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw Exception('Error al obtener presupuesto: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener presupuesto: $e');
    }
  }

  Future<void> deleteBudget(String budgetId) async {
    final userId = _currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }
    try {
      await _supabaseClient.from('budgets').delete().eq('id', budgetId);
    } on PostgrestException catch (e) {
      throw Exception('Error al eliminar presupuesto: ${e.message}');
    } catch (e) {
      throw Exception('Error al eliminar presupuesto: $e');
    }
  }

  //retornar dinero a la cuenta al eliminar presupuesto
  Future<void> returnBudgetToAccount(String accountId, double amount) async {
    try {
      // Obtener el saldo actual de la cuenta
      final response = await _supabaseClient
          .from('accounts')
          .select('balance')
          .eq('id', accountId)
          .single();  

      final currentBalance = response['balance'] as num? ?? 0;
      final newBalance = currentBalance.toDouble() + amount;

      // Actualizar el saldo con el nuevo valor calculado
      await _supabaseClient 
          .from('accounts')
          .update({'balance': newBalance})
          .eq('id', accountId);
    } catch (e) {
      throw Exception('Error al actualizar el saldo de la cuenta: $e');
    }
  }

  Future<void> updateBudget({
    required String id,
    required String name,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
    required double? alertThreshold,
  }) async {
    final userId = _currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final budget = BudgetModel(
      id: id,
      name: name,
      period: period,
      startDate: startDate,
      endDate: endDate,
      alertThreshold: alertThreshold,
    );

    final data = budget.toJson();
      // Excluir campos generados por la DB
    data.remove('amount');
    data.remove('user_id');
    data.remove('category_id');
    data.remove('account_id');
    data.remove('created_at');
    
    try {
      await _supabaseClient
          .from('budgets')
          .update(data)
          .eq('id', budget.id!);
    } on PostgrestException catch (e) {
      throw Exception('Error al actualizar presupuesto: ${e.message}');
    } catch (e) {
      throw Exception('Error al actualizar presupuesto: $e');
    }
  }

  Future<num> getTotalBudgetAmount() async {
    final userId = _currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabaseClient
          .from('budgets')
          .select('amount')
          .eq('user_id', userId);

      final amounts = (response as List)
          .map((item) => item['amount'] as num? ?? 0)
          .toList();

      final total = amounts.fold<num>(0, (prev, element) => prev + element);

      return total;
    } on PostgrestException catch (e) {
      throw Exception(
        'Error al obtener el total del presupuesto: ${e.message}',
      );
    } catch (e) {
      throw Exception('Error al obtener el total del presupuesto: $e');
    }
  }

  // have i accounts?  @override
  Future<bool> hasAccounts() async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return false;
      }

      final response = await _supabaseClient
          .from('accounts')
          .select('id')
          .eq('user_id', userId);

      return (response as List).isNotEmpty;
    } catch (e) {
      // Si hay error, asumimos que no tiene cuentas
      return false;
    }
  }

  // funcion que resta dinero de la cuenta para el presupuesto
  Future<void> updateAccountBalance(String accountId, double amount) async {
    try {
      // Obtener el saldo actual de la cuenta
      final response = await _supabaseClient
          .from('accounts')
          .select('balance')
          .eq('id', accountId)
          .single();

      final currentBalance = response['balance'] as num? ?? 0;
      final newBalance = currentBalance.toDouble() - amount;

      // Actualizar el saldo con el nuevo valor calculado
      await _supabaseClient
          .from('accounts')
          .update({'balance': newBalance})
          .eq('id', accountId);
    } catch (e) {
      throw Exception('Error al actualizar el saldo de la cuenta: $e');
    }
  }

  //funcion que permite validar que el presupuesto no exceda el saldo de la cuenta
  Future<bool> canAllocateBudget(String accountId, double amount) async {
    try {
      // Obtener el saldo actual de la cuenta
      final response = await _supabaseClient
          .from('accounts')
          .select('balance')
          .eq('id', accountId)
          .single();

      final currentBalance = response['balance'] as num? ?? 0;
      final canAllocate = currentBalance >= amount;
      return canAllocate;
    } catch (e) {
      throw Exception('Error al validar el saldo de la cuenta: $e');
    }
  }

  // Método unificado para verificar y actualizar el balance de la cuenta para un presupuesto
  Future<void> allocateBudgetToAccount(String accountId, double amount) async {
    try {
      // Verificar si el saldo es suficiente
      final canAllocate = await canAllocateBudget(accountId, amount);
      if (!canAllocate) {
        throw Exception('Saldo insuficiente en la cuenta para asignar el presupuesto');
      }

      // Si es suficiente, actualizar el balance
      await updateAccountBalance(accountId, amount);
    } catch (e) {
      throw Exception('Error al asignar presupuesto a la cuenta: $e');
    }
  }
}
