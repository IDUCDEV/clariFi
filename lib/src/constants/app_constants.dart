/// Constantes globales de la aplicación
/// Centraliza valores que se usan en múltiples partes del sistema

class AppConstants {
  // Tipos de cuenta disponibles en toda la aplicación
  static const List<AccountTypeOption> accountTypes = [
    AccountTypeOption(value: 'cash', label: 'Efectivo'),
    AccountTypeOption(value: 'bank', label: 'Banco'),
    AccountTypeOption(value: 'card', label: 'Tarjeta'),
    AccountTypeOption(value: 'digital_wallet', label: 'Billetera Digital'),
    AccountTypeOption(value: 'other', label: 'Otro'),
  ];

  // Monedas soportadas en toda la aplicación
  static const List<CurrencyOption> currencies = [
    CurrencyOption(code: 'USD', label: 'USD - Dólar', symbol: '\$'),
    CurrencyOption(code: 'EUR', label: 'EUR - Euro', symbol: '€'),
    CurrencyOption(code: 'ARS', label: 'ARS - Peso Argentino', symbol: '\$'),
    CurrencyOption(code: 'COP', label: 'COP - Peso Colombiano', symbol: '\$'),
  ];

  // Valores por defecto
  static const String defaultCurrency = 'USD';
  static const double defaultInitialBalance = 0.0;
  
  // Límites de validación
  static const int minAccountNameLength = 3;
  static const int maxAccountNameLength = 50;
  static const int minTransactionAmountDecimals = 2;
}

/// Opción de tipo de cuenta
class AccountTypeOption {
  final String value;
  final String label;

  const AccountTypeOption({
    required this.value,
    required this.label,
  });
}

/// Opción de moneda
class CurrencyOption {
  final String code;
  final String label;
  final String symbol;

  const CurrencyOption({
    required this.code,
    required this.label,
    required this.symbol,
  });
}
