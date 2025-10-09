import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../repositories/account_repository.dart';

/// ViewModel para gestionar el estado y lógica de negocio de cuentas
/// Implementa ChangeNotifier para notificar cambios a la UI
class AccountViewModel extends ChangeNotifier {
  final AccountRepository _repository;
  
  AccountViewModel(this._repository);
  
  // Estado
  List<AccountModel> _accounts = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<AccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasAccounts => _accounts.isNotEmpty;
  
  /// Obtiene la cuenta predeterminada del usuario
  AccountModel? get defaultAccount {
    try {
      return _accounts.firstWhere((account) => account.isDefault == true);
    } catch (e) {
      return null;
    }
  }
  
  /// Carga todas las cuentas del usuario desde la base de datos
  Future<void> loadAccounts() async {
    _setLoading(true);
    _clearError();
    
    try {
      _accounts = await _repository.getAccounts();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar cuentas: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// Crea una nueva cuenta
  /// Retorna true si se creó exitosamente, false en caso contrario
  Future<bool> createAccount({
    required String name,
    required String type,
    required String currency,
    double balance = 0.0,
    bool isDefault = false,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      // Validar nombre único antes de intentar crear
      final nameExists = await _repository.accountNameExists(name);
      if (nameExists) {
        _setError('Ya existe una cuenta con el nombre "$name"');
        _setLoading(false);
        return false;
      }
      
      // Crear la cuenta
      await _repository.createAccount(
        name: name,
        type: type,
        currency: currency,
        balance: balance,
        isDefault: isDefault,
      );
      
      // Recargar la lista de cuentas
      await loadAccounts();
      
      return true;
      
    } catch (e) {
      _setError('Error al crear cuenta: $e');
      _setLoading(false);
      return false;
    }
  }
  
  /// Actualiza una cuenta existente
  /// Retorna true si se actualizó exitosamente, false en caso contrario
  Future<bool> updateAccount(AccountModel account) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _repository.updateAccount(account);
      
      // Recargar la lista de cuentas
      await loadAccounts();
      
      return true;
      
    } catch (e) {
      _setError('Error al actualizar cuenta: $e');
      _setLoading(false);
      return false;
    }
  }
  
  /// Elimina una cuenta
  /// Retorna true si se eliminó exitosamente, false en caso contrario
  Future<bool> deleteAccount(String accountId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _repository.deleteAccount(accountId);
      
      // Recargar la lista de cuentas
      await loadAccounts();
      
      return true;
      
    } catch (e) {
      _setError('Error al eliminar cuenta: $e');
      _setLoading(false);
      return false;
    }
  }
  
  /// Obtiene una cuenta específica por ID
  Future<AccountModel?> getAccountById(String accountId) async {
    try {
      return await _repository.getAccountById(accountId);
    } catch (e) {
      _setError('Error al obtener cuenta: $e');
      return null;
    }
  }
  
  /// Verifica si existe una cuenta con el nombre dado
  Future<bool> accountNameExists(String name) async {
    try {
      return await _repository.accountNameExists(name);
    } catch (e) {
      return false;
    }
  }
  
  /// Busca cuentas por texto (nombre o tipo)
  List<AccountModel> searchAccounts(String query) {
    if (query.isEmpty) return _accounts;
    
    final lowerQuery = query.toLowerCase();
    return _accounts.where((account) {
      return account.name.toLowerCase().contains(lowerQuery) ||
             account.type.toLowerCase().contains(lowerQuery);
    }).toList();
  }
  
  /// Filtra cuentas por tipo
  List<AccountModel> filterByType(String type) {
    return _accounts.where((account) => account.type == type).toList();
  }
  
  /// Filtra cuentas por moneda
  List<AccountModel> filterByCurrency(String currency) {
    return _accounts.where((account) => account.currency == currency).toList();
  }
  
  /// Calcula el balance total de todas las cuentas
  /// Nota: Este cálculo es aproximado ya que puede haber diferentes monedas
  double get totalBalance {
    return _accounts.fold(0.0, (sum, account) => sum + account.balance);
  }
  
  /// Limpia el mensaje de error
  void clearError() {
    _clearError();
  }
  
  // Métodos privados para gestionar estado
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }
}
