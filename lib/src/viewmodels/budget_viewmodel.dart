import 'package:clarifi_app/src/models/budget.dart';
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

  //lista de presupuestos
  List<BudgetModel> _budgets = [];
  List<BudgetModel> get budgets => _budgets;

  // presupestos filtrados por id
  BudgetModel? _budget;
  BudgetModel? get budget => _budget;

  // Métodos para cargar datos

  Future<void> loadBudgets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _budgets = await _repository.getBudgets();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // registrar presupuesto
  Future<void> createBudget({
    required String name,
    required double amount,
    required String period,
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
    required double? alertThreshold,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Aquí iría la llamada al repositorio para registrar el presupuesto
      // Ejemplo:
      await _repository.createBudget(
        name,
        amount,
        period,
        categoryId,
        startDate,
        endDate,
        alertThreshold,
      );
      // Actualizar la lista de presupuestos después de registrar
      await loadBudgets();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //delete budget
  Future<void> deleteBudget(String budgetId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Aquí iría la llamada al repositorio para eliminar el presupuesto
      // Ejemplo:
      await _repository.deleteBudget(budgetId);
      // Actualizar la lista de presupuestos después de eliminar
      await loadBudgets();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getBudgetById(String budgetId) async {
    try {
      _budget = await _repository.getBudgetById(budgetId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
