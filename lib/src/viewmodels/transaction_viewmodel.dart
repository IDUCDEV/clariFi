import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final CategoryRepository categoryRepository;
  final TransactionRepository _repository;

  List<CategoryModel> categories = [];
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  //List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

   // 🔹 Filtros actuales
  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _selectedType; // "income" o "expense"
  DateTimeRange? _selectedDateRange;

  TransactionViewModel(this._repository, this.categoryRepository);

  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
       _allTransactions = await _repository.getTransactions();
      _filteredTransactions = List.from(_allTransactions);
     
      for (var t in _allTransactions) {
      print('💰 ${t.note ?? t.categoryName} | Cuenta: ${t.accountName}');
    }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
 // 🔹 Aplicar filtros
  void applyFilters({
    String? categoryId,
    String? accountId,
    String? type,
    DateTimeRange? dateRange,
  }) {
    _selectedCategoryId = categoryId;
    _selectedAccountId = accountId;
    _selectedType = type;
    _selectedDateRange = dateRange;

    _filteredTransactions = _allTransactions.where((t) {
      bool matches = true;

      if (categoryId != null && t.categoryId != categoryId) matches = false;
      if (accountId != null && t.accountId != accountId) matches = false;
      if (type != null && t.type != type) matches = false;

      if (dateRange != null) {
        matches = matches &&
            t.date.isAfter(dateRange.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(dateRange.end.add(const Duration(days: 1)));
      }

      return matches;
    }).toList();

    notifyListeners();
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _selectedAccountId = null;
    _selectedType = null;
    _selectedDateRange = null;
    _filteredTransactions = List.from(_allTransactions);
    notifyListeners();
  }

 Future<void> addTransaction(TransactionModel transaction) async {
  try {
    _isLoading = true;
    notifyListeners();

    print('🟣 [VM] Intentando guardar transacción...');
    print('🟢 [VM] Datos enviados: ${transaction.toJson()}');

    await _repository.createTransaction(transaction);
    await loadTransactions(); 
    
    print('✅ [VM] Transacción creada correctamente');

    _isLoading = false;
    notifyListeners();
  } catch (e, stack) {
    print('🔴 [VM] Error al crear transacción: $e');
    print('📜 Stacktrace: $stack');
    _isLoading = false;
    _errorMessage = e.toString();
    notifyListeners();
  }
}

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _repository.updateTransaction(transaction);
      await loadTransactions();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await _repository.deleteTransaction(id);
      _allTransactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCategories(String type) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      categories = await categoryRepository.fetchAllCategories(type: type);

      print('📝 Response categories: $categories'); // Para debug
    } catch (e) {
      _errorMessage = e.toString();
      print('⚠️ Error cargando categorías: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
