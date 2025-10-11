
import 'package:clarifi_app/src/repositories/budgets/supabase_budget_repository.dart';
import 'package:flutter/material.dart';


class BudgetViewModel extends ChangeNotifier {
  final SupabaseBudgetRepository _repository;

  BudgetViewModel(this._repository);

  // Estado de carga
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Estado de error
  String? _error;
  String? get error => _error;

  // Métodos para cargar datos
}
