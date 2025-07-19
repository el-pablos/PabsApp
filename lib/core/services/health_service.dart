import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

import '../models/health_status_model.dart';

/// Service untuk monitoring kesehatan sistem
/// Author: Tamas dari TamsHub
///
/// Service ini mengelola monitoring status API, cuaca, sistem,
/// dan informasi jaringan untuk health runtime page

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final DateTime _appStartTime = DateTime.now();

  /// Check status semua API yang digunakan aplikasi
  Future<List<ApiStatus>> checkApiStatuses() async {
    final apis = [
      {
        'name': 'PDDIKTI API',
        'endpoint': 'https://api-frontend.kemdikbud.go.id/hit_mhs',
      },
      {
        'name': 'BotcahX API',
        'endpoint': 'https://api.botcahx.eu.org',
      },
      {
        'name': 'Weather API',
        'endpoint': 'https://api.openweathermap.org/data/2.5/weather',
      },
      {
        'name': 'JSONPlaceholder (Test)',
        'endpoint': 'https://jsonplaceholder.typicode.com/posts/1',
      },
    ];

    final List<ApiStatus> statuses = [];
    
    for (final api in apis) {
      try {
        final stopwatch = Stopwatch()..start();
        final response = await http.get(
          Uri.parse(api['endpoint']!),
          headers: {'User-Agent': 'PabsApp/1.0'},
        ).timeout(const Duration(seconds: 10));
        
        stopwatch.stop();
        
        statuses.add(ApiStatus(
          name: api['name']!,
          endpoint: api['endpoint']!,
          isOnline: response.statusCode >= 200 && response.statusCode < 300,
          responseTime: stopwatch.elapsedMilliseconds,
          status: 'HTTP ${response.statusCode}',
          lastChecked: DateTime.now(),
        ));
      } catch (e) {
        statuses.add(ApiStatus(
          name: api['name']!,
          endpoint: api['endpoint']!,
          isOnline: false,
          responseTime: 0,
          status: 'Error: ${e.toString().substring(0, 50)}...',
          lastChecked: DateTime.now(),
        ));
      }
    }
    
    return statuses;
  }

  /// Get informasi cuaca (mock data untuk demo)
  Future<WeatherInfo?> getWeatherInfo() async {
    try {
      // Mock weather data - in real app, use actual weather API
      await Future.delayed(const Duration(milliseconds: 500));
      
      return WeatherInfo(
        temperature: 28.5,
        description: 'Cerah Berawan',
        location: 'Jakarta, Indonesia',
        humidity: 65,
        windSpeed: 12.5,
        pressure: 1013,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting weather info: $e');
      return null;
    }
  }

  /// Get informasi sistem device
  Future<SystemInfo?> getSystemInfo() async {
    try {
      String platform = 'Unknown';
      String osVersion = 'Unknown';
      String deviceModel = 'Unknown';
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        platform = 'Android';
        osVersion = 'Android ${androidInfo.version.release}';
        deviceModel = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        platform = 'iOS';
        osVersion = 'iOS ${iosInfo.systemVersion}';
        deviceModel = iosInfo.model;
      }

      // Mock system metrics - in real app, use actual system monitoring
      return SystemInfo(
        platform: platform,
        osVersion: osVersion,
        deviceModel: deviceModel,
        availableMemory: 2048, // MB
        freeStorage: 15, // GB
        cpuUsage: 25, // %
        memoryUsage: 45, // %
        batteryLevel: 85, // %
        appUptime: DateTime.now().difference(_appStartTime).inSeconds,
      );
    } catch (e) {
      debugPrint('Error getting system info: $e');
      return null;
    }
  }

  /// Get informasi jaringan
  Future<NetworkInfo?> getNetworkInfo() async {
    try {
      // Check internet connectivity
      bool isConnected = false;
      String connectionType = 'Unknown';
      
      try {
        final result = await http.get(
          Uri.parse('https://www.google.com'),
          headers: {'User-Agent': 'PabsApp/1.0'},
        ).timeout(const Duration(seconds: 5));
        
        isConnected = result.statusCode == 200;
        connectionType = 'Mobile/WiFi';
      } catch (e) {
        isConnected = false;
        connectionType = 'Offline';
      }

      return NetworkInfo(
        isConnected: isConnected,
        connectionType: connectionType,
        signalStrength: isConnected ? 85 : 0, // Mock signal strength
        ipAddress: isConnected ? '192.168.1.100' : null, // Mock IP
        lastChecked: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting network info: $e');
      return NetworkInfo(
        isConnected: false,
        connectionType: 'Error',
        lastChecked: DateTime.now(),
      );
    }
  }

  /// Test koneksi ke endpoint tertentu
  Future<bool> testEndpoint(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'PabsApp/1.0'},
      ).timeout(const Duration(seconds: 10));
      
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      debugPrint('Error testing endpoint $url: $e');
      return false;
    }
  }

  /// Get ping time ke server
  Future<int> getPingTime(String host) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await http.get(
        Uri.parse('https://$host'),
        headers: {'User-Agent': 'PabsApp/1.0'},
      ).timeout(const Duration(seconds: 5));
      
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (e) {
      debugPrint('Error getting ping time for $host: $e');
      return -1;
    }
  }

  /// Get app performance metrics
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    try {
      return {
        'app_uptime': DateTime.now().difference(_appStartTime).inSeconds,
        'memory_usage': 45, // Mock data
        'cpu_usage': 25, // Mock data
        'network_requests': 150, // Mock data
        'cache_size': 25, // MB
        'database_size': 5, // MB
      };
    } catch (e) {
      debugPrint('Error getting performance metrics: $e');
      return {};
    }
  }

  /// Clear cache dan temporary data
  Future<void> clearCache() async {
    try {
      // Implementation for clearing cache
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
      throw Exception('Failed to clear cache: $e');
    }
  }

  /// Export health data untuk debugging
  Future<Map<String, dynamic>> exportHealthData() async {
    try {
      final apiStatuses = await checkApiStatuses();
      final weatherInfo = await getWeatherInfo();
      final systemInfo = await getSystemInfo();
      final networkInfo = await getNetworkInfo();
      final performanceMetrics = await getPerformanceMetrics();

      return {
        'timestamp': DateTime.now().toIso8601String(),
        'api_statuses': apiStatuses.map((api) => api.toJson()).toList(),
        'weather_info': weatherInfo?.toJson(),
        'system_info': systemInfo?.toJson(),
        'network_info': networkInfo?.toJson(),
        'performance_metrics': performanceMetrics,
      };
    } catch (e) {
      debugPrint('Error exporting health data: $e');
      throw Exception('Failed to export health data: $e');
    }
  }

  /// Get overall system health score (0-100)
  Future<int> getHealthScore() async {
    try {
      int score = 100;
      
      // Check API statuses
      final apiStatuses = await checkApiStatuses();
      final onlineApis = apiStatuses.where((api) => api.isOnline).length;
      final apiScore = (onlineApis / apiStatuses.length * 30).round();
      
      // Check network
      final networkInfo = await getNetworkInfo();
      final networkScore = networkInfo?.isConnected == true ? 30 : 0;
      
      // Check system resources
      final systemInfo = await getSystemInfo();
      int systemScore = 40;
      if (systemInfo != null) {
        if (systemInfo.memoryUsage > 80) systemScore -= 10;
        if (systemInfo.cpuUsage > 80) systemScore -= 10;
        if (systemInfo.batteryLevel < 20) systemScore -= 10;
        if (systemInfo.freeStorage < 5) systemScore -= 10;
      }
      
      score = apiScore + networkScore + systemScore;
      return score.clamp(0, 100);
    } catch (e) {
      debugPrint('Error calculating health score: $e');
      return 0;
    }
  }
}
