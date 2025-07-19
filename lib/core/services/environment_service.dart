import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service untuk mengelola environment variables dan konfigurasi
/// Author: Tamas dari TamsHub
///
/// Service ini menyediakan akses aman ke environment variables
/// dan memastikan tidak ada credentials yang hardcoded

class EnvironmentService {
  static final EnvironmentService _instance = EnvironmentService._internal();
  factory EnvironmentService() => _instance;
  EnvironmentService._internal();

  /// Initialize environment service
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      debugPrint('Environment variables loaded successfully');
    } catch (e) {
      debugPrint('Warning: Could not load .env file: $e');
      debugPrint('Using default/fallback values');
    }
  }

  /// Get environment variable with fallback
  static String get(String key, {String defaultValue = ''}) {
    try {
      // First try from environment variables (for production)
      String? value = const String.fromEnvironment(key);
      if (value.isNotEmpty) return value;
      
      // Then try from .env file (for development)
      value = dotenv.env[key];
      if (value != null && value.isNotEmpty) return value;
      
      // Return default value
      return defaultValue;
    } catch (e) {
      debugPrint('Error getting environment variable $key: $e');
      return defaultValue;
    }
  }

  /// Get boolean environment variable
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = get(key).toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Get integer environment variable
  static int getInt(String key, {int defaultValue = 0}) {
    try {
      return int.parse(get(key));
    } catch (e) {
      return defaultValue;
    }
  }

  /// Get double environment variable
  static double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return double.parse(get(key));
    } catch (e) {
      return defaultValue;
    }
  }

  // =============================================================================
  // SECURE API CONFIGURATION
  // =============================================================================

  /// BotcahX API Configuration
  static String get botcahxApiUrl => get('BOTCAHX_API_URL', 
      defaultValue: 'https://api.botcahx.eu.org');
  
  static String get botcahxApiKey => get('BOTCAHX_API_KEY', 
      defaultValue: 'demo_key');

  /// PDDIKTI API Configuration
  static String get pddiktiApiUrl => get('PDDIKTI_API_URL', 
      defaultValue: 'https://api-frontend.kemdikbud.go.id');

  /// Weather API Configuration
  static String get weatherApiKey => get('WEATHER_API_KEY', 
      defaultValue: '');
  
  static String get weatherApiUrl => get('WEATHER_API_URL', 
      defaultValue: 'https://api.openweathermap.org/data/2.5');

  /// Google Maps API Configuration
  static String get googleMapsApiKey => get('GOOGLE_MAPS_API_KEY', 
      defaultValue: '');

  /// Firebase Configuration
  static String get firebaseProjectId => get('FIREBASE_PROJECT_ID', 
      defaultValue: '');
  
  static String get firebaseApiKey => get('FIREBASE_API_KEY', 
      defaultValue: '');

  /// OpenAI Configuration
  static String get openaiApiKey => get('OPENAI_API_KEY', 
      defaultValue: '');

  /// Gemini AI Configuration
  static String get geminiApiKey => get('GEMINI_API_KEY', 
      defaultValue: '');

  // =============================================================================
  // APPLICATION CONFIGURATION
  // =============================================================================

  /// App Configuration
  static String get appName => get('APP_NAME', 
      defaultValue: 'PabsApp');
  
  static String get appVersion => get('APP_VERSION', 
      defaultValue: '1.0.0');
  
  static String get appAuthor => get('APP_AUTHOR', 
      defaultValue: 'Tamas dari TamsHub');

  /// Debug Configuration
  static bool get debugMode => getBool('DEBUG_MODE', 
      defaultValue: kDebugMode);
  
  static String get logLevel => get('LOG_LEVEL', 
      defaultValue: 'info');

  /// Database Configuration
  static String get databaseSchema => get('DATABASE_SCHEMA', 
      defaultValue: 'public');

  // =============================================================================
  // VALIDATION METHODS
  // =============================================================================

  /// Validate that all required environment variables are set
  static bool validateConfiguration() {
    final requiredKeys = [
      'APP_NAME',
      'APP_VERSION',
      'APP_AUTHOR',
    ];

    final missingKeys = <String>[];
    
    for (final key in requiredKeys) {
      if (get(key).isEmpty) {
        missingKeys.add(key);
      }
    }

    if (missingKeys.isNotEmpty) {
      debugPrint('Missing required environment variables: ${missingKeys.join(', ')}');
      return false;
    }

    return true;
  }

  /// Check if API keys are configured
  static Map<String, bool> checkApiKeys() {
    return {
      'BotcahX': botcahxApiKey != 'demo_key' && botcahxApiKey.isNotEmpty,
      'Weather': weatherApiKey.isNotEmpty,
      'Google Maps': googleMapsApiKey.isNotEmpty,
      'OpenAI': openaiApiKey.isNotEmpty,
      'Gemini': geminiApiKey.isNotEmpty,
    };
  }

  /// Get configuration summary for debugging (without sensitive data)
  static Map<String, dynamic> getConfigurationSummary() {
    final apiKeys = checkApiKeys();
    
    return {
      'app_name': appName,
      'app_version': appVersion,
      'app_author': appAuthor,
      'debug_mode': debugMode,
      'log_level': logLevel,
      'api_keys_configured': apiKeys,
      'total_configured_apis': apiKeys.values.where((v) => v).length,
    };
  }

  /// Sanitize sensitive data for logging
  static String sanitizeForLogging(String value) {
    if (value.isEmpty) return '[EMPTY]';
    if (value.length <= 8) return '[HIDDEN]';
    
    // Show first 4 and last 4 characters, hide the middle
    return '${value.substring(0, 4)}...${value.substring(value.length - 4)}';
  }

  /// Log configuration status (safely)
  static void logConfigurationStatus() {
    final summary = getConfigurationSummary();
    debugPrint('=== PabsApp Configuration Status ===');
    debugPrint('App: ${summary['app_name']} v${summary['app_version']}');
    debugPrint('Author: ${summary['app_author']}');
    debugPrint('Debug Mode: ${summary['debug_mode']}');
    debugPrint('Log Level: ${summary['log_level']}');
    debugPrint('Configured APIs: ${summary['total_configured_apis']}/5');
    
    final apiKeys = summary['api_keys_configured'] as Map<String, bool>;
    apiKeys.forEach((api, configured) {
      debugPrint('  $api: ${configured ? '✓ Configured' : '✗ Not configured'}');
    });
    debugPrint('=====================================');
  }
}
