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
        categoryId: null, // Siempre null por ahora hasta implementar selección de categoría
        startDate: startDate,
        endDate: endDate,
        alertThreshold: alertThreshold,
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
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);

        return response.map((json) => BudgetModel.fromJson(json)).toList();
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
              .select()
              .eq('id', budgetId)
              .eq('user_id', userId)
              .single();

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
}
