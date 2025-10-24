/// Configuración centralizada de APIs y endpoints
/// 
/// Este archivo contiene todas las URLs base y endpoints de APIs externas
/// utilizadas en la aplicación. Facilita el mantenimiento y permite
/// cambiar entre ambientes (dev, staging, production).
class ApiConfig {
  // Private constructor para prevenir instanciación
  ApiConfig._();
  
  /// Base URL para la API de conversión de monedas
  /// 
  /// **Opción 1 (Actual):** Hardcoded para API pública sin autenticación
  /// - Ventaja: Simple, no requiere configuración adicional
  /// - Desventaja: Menos flexible para cambiar de proveedor
  /// 
  /// **Opción 2 (Alternativa):** Leer desde .env para mayor flexibilidad
  /// Descomenta las siguientes líneas si prefieres usar .env:
  /// 
  /// ```dart
  /// import 'package:flutter_dotenv/flutter_dotenv.dart';
  /// 
  /// static String get exchangeRateApiBaseUrl => 
  ///     dotenv.env['EXCHANGE_RATE_API_BASE_URL'] ?? 
  ///     'https://api.exchangerate-api.com/v4'; // fallback
  /// 
  /// static String get exchangeRateApiKey => 
  ///     dotenv.env['EXCHANGE_RATE_API_KEY'] ?? '';
  /// ```
  /// 
  /// Alternativas gratuitas:
  /// - ExchangeRate-API: https://api.exchangerate-api.com (sin key)
  /// - Open Exchange Rates: https://openexchangerates.org (requiere key)
  /// - Fixer.io: https://fixer.io (requiere key)
  /// - Currency API: https://currencyapi.com (requiere key)
  // Default external API base URL (you provided this endpoint). Keep disabled
  // by default via `useExternalExchangeApi` to avoid unsafe direct calls.
  static const String exchangeRateApiBaseUrl = 'http://exchangesrateapi.com/api';
  
  /// Endpoint para obtener tasas de cambio
  /// {currency} será reemplazado por el código de moneda (ej: USD, EUR)
  static String getExchangeRatesEndpoint(String baseCurrency) {
    return '$exchangeRateApiBaseUrl/latest/$baseCurrency';
  }
  
  // ==========================================
  // CONFIGURACIÓN PARA OTRAS APIS
  // ==========================================
  
  /// Si en el futuro necesitas autenticación, puedes agregar:
  /// static const String exchangeRateApiKey = String.fromEnvironment(
  ///   'EXCHANGE_RATE_API_KEY',
  ///   defaultValue: '',
  /// );
  
  /// Timeouts para peticiones HTTP
  static const Duration defaultTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(seconds: 30);
  
  /// Configuración de cache
  static const Duration exchangeRateCacheDuration = Duration(hours: 24);
  
  /// Límites de la API (para manejar rate limiting)
  static const int maxRequestsPerMonth = 1500; // ExchangeRate-API free tier
  
  /// Headers comunes para todas las peticiones
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
