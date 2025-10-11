import 'app_constants.dart';

// Reexportación de clases para mantener compatibilidad
export 'app_constants.dart' show AccountTypeOption, CurrencyOption;

/// Constantes específicas del módulo de cuentas
/// Reexporta constantes globales para mantener compatibilidad
class AccountConstants {
  // Reexportación de constantes globales de tipos de cuenta
  static const List<AccountTypeOption> accountTypes = AppConstants.accountTypes;

  // Reexportación de constantes globales de monedas
  static const List<CurrencyOption> currencies = AppConstants.currencies;

  // Valores por defecto para cuentas
  static const String defaultCurrency = AppConstants.defaultCurrency;
  static const double defaultInitialBalance = AppConstants.defaultInitialBalance;
  
  // Constantes específicas de validación de cuentas
  static const int minNameLength = AppConstants.minAccountNameLength;
  static const int maxNameLength = AppConstants.maxAccountNameLength;
}


