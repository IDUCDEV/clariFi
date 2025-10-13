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
    String categoryId,
    DateTime startDate,
    DateTime endDate,
    double? alertThreshold,
  ) async {
    final userId = _currentUserId;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabaseClient.from('budgets').insert({
        'user_id': userId,
        'name': name,
        'amount': amount,
        'period': period,
        'category_id': null, // Por ahora null hasta que se implemente selección de categoría real
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'alert_threshold': alertThreshold,
      });
    } on PostgrestException catch (e) {
      throw Exception('Error creando presupuesto: ${e.message}');
    } catch (e) {
      throw Exception('Error creando presupuesto: $e');
    }
  }
}
