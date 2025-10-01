
import 'package:clarifi_app/src/services/supabase_service.dart';
import 'package:flutter/material.dart';

class TransactionViewModel extends ChangeNotifier {
  final SupabaseService _supabaseService;
  List<dynamic> _transactions = [];
  bool _isLoading = false;

  TransactionViewModel(this._supabaseService);

  List<dynamic> get transactions => _transactions;
  bool get isLoading => _isLoading;

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _supabaseService.fetchTransactions();
    _isLoading = false;
    notifyListeners();
  }
}
