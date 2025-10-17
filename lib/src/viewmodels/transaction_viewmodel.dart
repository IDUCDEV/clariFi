import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/transaction/transaction_repository.dart';
import '../models/category.dart';
import '../repositories/category/category_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final CategoryRepository categoryRepository;
  final TransactionRepository _repository;

  List<CategoryModel> categories = [];
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;

  int _page = 0;
  final int _limit = 20;

  // 🔹 Filtros actuales
  String? _selectedCategoryId;
  String? _selectedAccountId;
  String? _selectedType; // "income" o "expense"
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';

  TransactionViewModel(this._repository, this.categoryRepository);

  // ============================================================
  // Getters
  // ============================================================
  List<TransactionModel> get transactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  // ============================================================
  // Cargar transacciones (inicio)
  // ============================================================
  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    _page = 0;
    _hasMore = true;
    notifyListeners();

    try {
      final data = await _repository.getTransactions(offset: 0, limit: _limit);
      _allTransactions = data;
      _filteredTransactions = List.from(_allTransactions);
      _page = 1;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // Cargar más transacciones (scroll infinito)
  // ============================================================
  Future<void> loadMoreTransactions() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final offset = _page * _limit;
      final data = await _repository.getTransactions(offset: offset, limit: _limit);

      if (data.isEmpty) {
        _hasMore = false;
      } else {
        _allTransactions.addAll(data);
        _filteredTransactions = List.from(_allTransactions);
        _page++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingMore = false;
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

      // 🔸 Filtro por categoría
      if (_selectedCategoryId != null && t.categoryId != _selectedCategoryId) {
        matches = false;
      }

      // 🔸 Filtro por cuenta
      if (_selectedAccountId != null && t.accountId != _selectedAccountId) {
        matches = false;
      }

      // 🔸 Filtro por tipo
      if (_selectedType != null && t.type != _selectedType) {
        matches = false;
      }

      // 🔸 Filtro por rango de fechas
      if (_selectedDateRange != null) {
        matches = matches &&
            t.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }

      // 🔸 Filtro por texto
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
  
Future<void> refreshTransactions() async {
  _allTransactions.clear();
  _filteredTransactions.clear();
  notifyListeners();
  await loadTransactions();
}
  // ============================================================
  // CRUD
  // ============================================================
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.createTransaction(transaction);
      await loadTransactions();
    } catch (e, stack) {
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
  // Cargar categorías por tipo
  // ============================================================
  Future<void> loadCategories(String type) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      categories = await categoryRepository.fetchAllCategories(type: type);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  TransactionModel? getTransactionById(String id) {
  try {
    return _allTransactions.firstWhere((t) => t.id == id);
  } catch (e) {
    return null;
  }
}
}
