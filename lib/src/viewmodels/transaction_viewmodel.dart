import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final CategoryRepository categoryRepository;
  final TransactionRepository _repository;

  List<CategoryModel> categories = [];

  TransactionViewModel(this._repository, this.categoryRepository);

  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTransactions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _repository.getTransactions();
     
      for (var t in _transactions) {
      print('💰 ${t.note ?? t.categoryName} | Cuenta: ${t.accountName}');
    }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      _transactions.removeWhere((t) => t.id == id);
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
