import '../../models/account.dart';

/// Repository para operaciones de cuentas
/// Define el contrato que debe cumplir cualquier implementación
/// Sigue el principio de Inversión de Dependencias (SOLID)
abstract class AccountRepository {
  /// Obtiene todas las cuentas del usuario actual
  Future<List<AccountModel>> getAccounts();
  
  /// Crea una nueva cuenta
  /// Lanza excepción si el nombre ya existe o hay error
  Future<void> createAccount({
    required String name,
    required String type,
    required String currency,
    double balance = 0.0,
    bool isDefault = false,
  });
  
  /// Verifica si ya existe una cuenta con el mismo nombre para el usuario
  /// Retorna true si existe, false si no existe
  Future<bool> accountNameExists(String name);
  
  /// Actualiza una cuenta existente
  Future<void> updateAccount(AccountModel account);
  
  /// Elimina una cuenta por su ID
  Future<void> deleteAccount(String accountId);
  
  /// Obtiene una cuenta específica por su ID
  Future<AccountModel?> getAccountById(String accountId);
  
  /// Transfiere el saldo de una cuenta a otra
  /// Suma el balance de fromAccountId al balance de toAccountId
  /// Esta operación debe ser atómica para evitar inconsistencias
  Future<void> transferBalance({
    required String fromAccountId,
    required String toAccountId,
  });

  Future<void> transferAmount({
  required String fromAccountId,
  required String toAccountId,
  required double amount,
  });
}
