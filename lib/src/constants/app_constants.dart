import 'package:flutter/material.dart';

/// Constantes globales de la aplicación
/// Centraliza valores que se usan en múltiples partes del sistema

class AppConstants {
  // Tipos de cuenta disponibles en toda la aplicación
  static const List<AccountTypeOption> accountTypes = [
    AccountTypeOption(
      value: 'cash',
      label: 'Efectivo',
      icon: Icons.payments_outlined,
      color: Color(0xFF10B981), // Verde
    ),
    AccountTypeOption(
      value: 'current',
      label: 'Corriente',
      icon: Icons.account_balance_outlined,
      color: Color(0xFF7C3AED), // Morado
    ),
    AccountTypeOption(
      value: 'to_save',
      label: 'Ahorro',
      icon: Icons.savings_outlined,
      color: Color(0xFF06B6D4), // Cyan
    ),
    AccountTypeOption(
      value: 'credit',
      label: 'Crédito',
      icon: Icons.credit_card,
      color: Color(0xFFF59E0B), // Naranja
    ),
    AccountTypeOption(
      value: 'bank',
      label: 'Banco',
      icon: Icons.account_balance,
      color: Color(0xFF3B82F6), // Azul
    ),
    AccountTypeOption(
      value: 'card',
      label: 'Tarjeta',
      icon: Icons.credit_card_outlined,
      color: Color(0xFFEC4899), // Rosa
    ),
    AccountTypeOption(
      value: 'digital_wallet',
      label: 'Billetera Digital',
      icon: Icons.account_balance_wallet_outlined,
      color: Color(0xFF8B5CF6), // Morado claro
    ),
    AccountTypeOption(
      value: 'other',
      label: 'Otro',
      icon: Icons.more_horiz,
      color: Color(0xFF6B7280), // Gris
    ),
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
  final IconData icon;
  final Color color;

  const AccountTypeOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
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
