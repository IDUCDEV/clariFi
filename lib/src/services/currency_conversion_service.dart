import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clarifi_app/src/config/api_config.dart';

/// Servicio para conversión de monedas
/// Proporciona funcionalidad de conversión automática a moneda principal para consolidación
/// 
/// Características:
/// - Conversión entre múltiples monedas
/// - Cache de tasas de cambio
/// - Actualización automática de tasas
/// - Soporte para monedas offline con tasas aproximadas
class CurrencyConversionService {
  // Moneda base para consolidación (por defecto USD)
  static const String baseCurrency = 'USD';
  
  // Cache de tasas de cambio
  final Map<String, double> _exchangeRates = {};
  
  // Última actualización de tasas
  DateTime? _lastUpdate;
  
  // Singleton
  static final CurrencyConversionService _instance = CurrencyConversionService._internal();
  factory CurrencyConversionService() => _instance;
  CurrencyConversionService._internal() {
    _initializeDefaultRates();
  }
  
  /// Inicializa tasas de cambio por defecto (offline)
  /// Estas tasas son aproximadas y se usan cuando no hay conexión
  void _initializeDefaultRates() {
    _exchangeRates.addAll({
      'USD': 1.0,        // Dólar estadounidense (base)
      'EUR': 0.92,       // Euro
      'GBP': 0.79,       // Libra esterlina
      'JPY': 149.50,     // Yen japonés
      'CAD': 1.36,       // Dólar canadiense
      'AUD': 1.53,       // Dólar australiano
      'CHF': 0.88,       // Franco suizo
      'CNY': 7.24,       // Yuan chino
      'MXN': 17.08,      // Peso mexicano
      'BRL': 4.97,       // Real brasileño
      'ARS': 350.00,     // Peso argentino
      'CLP': 898.00,     // Peso chileno
      'COP': 3950.00,    // Peso colombiano
      'PEN': 3.73,       // Sol peruano
      'UYU': 39.50,      // Peso uruguayo
      'INR': 83.12,      // Rupia india
      'KRW': 1320.00,    // Won surcoreano
      'RUB': 92.00,      // Rublo ruso
      'ZAR': 18.50,      // Rand sudafricano
      'NZD': 1.64,       // Dólar neozelandés
    });
  }
  
  /// Obtiene las tasas de cambio actualizadas desde una API
  /// Usa ExchangeRate-API (gratis) configurada en ApiConfig
  Future<bool> updateExchangeRates() async {
    try {
      // Verificar si necesita actualización
      if (_lastUpdate != null && 
          DateTime.now().difference(_lastUpdate!) < ApiConfig.exchangeRateCacheDuration) {
        return true; // Cache aún válido
      }
      
      // Obtener URL desde configuración centralizada
      final url = Uri.parse(ApiConfig.getExchangeRatesEndpoint(baseCurrency));
      
      final response = await http.get(
        url,
        headers: ApiConfig.defaultHeaders,
      ).timeout(
        ApiConfig.defaultTimeout,
        onTimeout: () {
          throw Exception('Timeout al obtener tasas de cambio');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;
        
        // Actualizar cache
        _exchangeRates.clear();
        rates.forEach((currency, rate) {
          _exchangeRates[currency] = (rate as num).toDouble();
        });
        
        _lastUpdate = DateTime.now();
        return true;
      } else {
        throw Exception('Error HTTP ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error al actualizar tasas de cambio: $e');
      print('📌 Usando tasas de cambio en cache/offline');
      return false; // Usa tasas por defecto
    }
  }
  
  /// Convierte un monto de una moneda a otra
  /// 
  /// [amount] - Monto a convertir
  /// [fromCurrency] - Moneda de origen (ej: 'MXN')
  /// [toCurrency] - Moneda de destino (ej: 'USD')
  /// 
  /// Retorna el monto convertido
  double convert({
    required double amount,
    required String fromCurrency,
    String? toCurrency,
  }) {
    final targetCurrency = toCurrency ?? baseCurrency;
    
    // Si es la misma moneda, retornar el mismo monto
    if (fromCurrency == targetCurrency) {
      return amount;
    }
    
    // Obtener tasas
    final fromRate = _exchangeRates[fromCurrency];
    final toRate = _exchangeRates[targetCurrency];
    
    // Verificar que ambas monedas existan
    if (fromRate == null || toRate == null) {
      print('⚠️ Moneda no soportada: $fromCurrency o $targetCurrency');
      return amount; // Retornar el monto original si no se puede convertir
    }
    
    // Convertir: primero a USD (base), luego a la moneda destino
    final amountInBase = amount / fromRate;
    final convertedAmount = amountInBase * toRate;
    
    return convertedAmount;
  }
  
  /// Convierte un monto a la moneda base (USD)
  double convertToBase({
    required double amount,
    required String fromCurrency,
  }) {
    return convert(
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: baseCurrency,
    );
  }
  
  /// Consolida múltiples montos en diferentes monedas a una sola moneda
  /// 
  /// [amounts] - Mapa de moneda -> monto (ej: {'USD': 100.0, 'EUR': 50.0})
  /// [targetCurrency] - Moneda de consolidación (por defecto USD)
  /// 
  /// Retorna el total consolidado en la moneda objetivo
  double consolidate({
    required Map<String, double> amounts,
    String? targetCurrency,
  }) {
    final target = targetCurrency ?? baseCurrency;
    double total = 0.0;
    
    amounts.forEach((currency, amount) {
      final converted = convert(
        amount: amount,
        fromCurrency: currency,
        toCurrency: target,
      );
      total += converted;
    });
    
    return total;
  }
  
  /// Obtiene la tasa de cambio entre dos monedas
  /// 
  /// [fromCurrency] - Moneda de origen
  /// [toCurrency] - Moneda de destino
  /// 
  /// Retorna la tasa de cambio (cuánto vale 1 unidad de fromCurrency en toCurrency)
  double getExchangeRate({
    required String fromCurrency,
    String? toCurrency,
  }) {
    final target = toCurrency ?? baseCurrency;
    
    if (fromCurrency == target) {
      return 1.0;
    }
    
    final fromRate = _exchangeRates[fromCurrency];
    final toRate = _exchangeRates[target];
    
    if (fromRate == null || toRate == null) {
      return 1.0; // Retornar 1:1 si no hay tasa disponible
    }
    
    return toRate / fromRate;
  }
  
  /// Verifica si una moneda está soportada
  bool isCurrencySupported(String currency) {
    return _exchangeRates.containsKey(currency);
  }
  
  /// Obtiene todas las monedas soportadas
  List<String> getSupportedCurrencies() {
    return _exchangeRates.keys.toList()..sort();
  }
  
  /// Obtiene el timestamp de la última actualización
  DateTime? get lastUpdate => _lastUpdate;
  
  /// Verifica si el cache es válido
  bool get isCacheValid {
    if (_lastUpdate == null) return false;
    return DateTime.now().difference(_lastUpdate!) < ApiConfig.exchangeRateCacheDuration;
  }
  
  /// Formatea un monto con símbolo de moneda
  /// 
  /// [amount] - Monto a formatear
  /// [currency] - Código de moneda
  /// 
  /// Retorna el monto formateado (ej: "$1,234.56")
  String formatAmount({
    required double amount,
    required String currency,
  }) {
    final symbol = _getCurrencySymbol(currency);
    final formatted = amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    
    return '$symbol$formatted';
  }
  
  /// Obtiene el símbolo de una moneda
  String _getCurrencySymbol(String currency) {
    const symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'MXN': '\$',
      'BRL': 'R\$',
      'ARS': '\$',
      'CLP': '\$',
      'COP': '\$',
      'PEN': 'S/',
      'UYU': '\$U',
      'INR': '₹',
      'CNY': '¥',
      'KRW': '₩',
      'RUB': '₽',
      'CHF': 'CHF',
      'CAD': 'C\$',
      'AUD': 'A\$',
      'NZD': 'NZ\$',
      'ZAR': 'R',
    };
    
    return symbols[currency] ?? currency;
  }
  
  /// Limpia el cache de tasas de cambio
  void clearCache() {
    _lastUpdate = null;
    _initializeDefaultRates(); // Restaurar tasas por defecto
  }
}
