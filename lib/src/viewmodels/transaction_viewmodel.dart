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

  bool _isLoading = false;
  String? _errorMessage;

  // 🔹 Filtros actuales
  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _selectedType; // "income" o "expense"
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';

  TransactionViewModel(this._repository, this.categoryRepository);

  // 🔹 Getters
  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // ============================================================
  // Cargar transacciones
  // ============================================================
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

  // ============================================================
  // Aplicar filtros + búsqueda
  // ============================================================
  void applyFilters({
    String? categoryId,
    String? accountId,
    String? type,
    DateTimeRange? dateRange,
    String? search,
  }) {
    _selectedCategoryId = categoryId ?? _selectedCategoryId;
    _selectedAccountId = accountId ?? _selectedAccountId;
    _selectedType = type ?? _selectedType;
    _selectedDateRange = dateRange ?? _selectedDateRange;
    _searchQuery = search ?? _searchQuery;

    _filteredTransactions = _allTransactions.where((t) {
      bool matches = true;

      // 🔸 Filtrar por categoría, cuenta, tipo y fecha
      if (_selectedCategoryId != null && t.categoryId != _selectedCategoryId) {
        matches = false;
      }
      if (_selectedAccountId != null && t.accountId != _selectedAccountId) {
        matches = false;
      }
      if (_selectedType != null && t.type != _selectedType) {
        matches = false;
      }
      if (_selectedDateRange != null) {
        matches = matches &&
            t.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }

      // 🔸 Filtro por texto (nota / descripción / categoría)
      if (_searchQuery.isNotEmpty) {
        final lowerQuery = _searchQuery.toLowerCase();
        final note = t.note?.toLowerCase() ?? '';
        final category = t.categoryName?.toLowerCase() ?? '';
        final account = t.accountName?.toLowerCase() ?? '';

        if (!note.contains(lowerQuery) &&
            !category.contains(lowerQuery) &&
            !account.contains(lowerQuery)) {
          matches = false;
        }
      }

      return matches;
    }).toList();

    notifyListeners();
  }

  // ============================================================
  // Buscar por texto
  // ============================================================
  void setSearchQuery(String query) {
    _searchQuery = query;
    applyFilters(search: query);
  }

  // ============================================================
  // Restablecer filtros
  // ============================================================
  void clearFilters() {
    _selectedCategoryId = null;
    _selectedAccountId = null;
    _selectedType = null;
    _selectedDateRange = null;
    _searchQuery = '';
    _filteredTransactions = List.from(_allTransactions);
    notifyListeners();
  }

  // ============================================================
  // CRUD
  // ============================================================
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🟣 [VM] Intentando guardar transacción...');
      print('🟢 [VM] Datos enviados: ${transaction.toJson()}');

      await _repository.createTransaction(transaction);
      await loadTransactions();

      print('✅ [VM] Transacción creada correctamente');
    } catch (e, stack) {
      print('🔴 [VM] Error al crear transacción: $e');
      print('📜 Stacktrace: $stack');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
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
      _filteredTransactions.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ============================================================
  // Cargar categorías
  // ============================================================
  Future<void> loadCategories(String type) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      categories = await categoryRepository.fetchAllCategories(type: type);
      print('📝 Response categories: $categories');
    } catch (e) {
      _errorMessage = e.toString();
      print('⚠️ Error cargando categorías: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
