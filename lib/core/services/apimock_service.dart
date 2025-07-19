import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// APIMock Service for testing and development
/// Integrates with https://apimock.lazycatlabs.com/docs
/// Author: Tamas dari TamsHub
class APIMockService {
  static const String _baseUrl = 'https://apimock.lazycatlabs.com';
  static const Duration _timeout = Duration(seconds: 30);
  
  // Mock endpoints for different data types
  static const Map<String, String> _mockEndpoints = {
    'users': '/api/users',
    'posts': '/api/posts',
    'todos': '/api/todos',
    'albums': '/api/albums',
    'photos': '/api/photos',
    'comments': '/api/comments',
    'products': '/api/products',
    'categories': '/api/categories',
    'orders': '/api/orders',
    'customers': '/api/customers',
  };

  /// Get mock data from APIMock service
  static Future<Map<String, dynamic>> getMockData({
    required String endpoint,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      // Build URL with query parameters
      final uri = Uri.parse('$_baseUrl$endpoint');
      final finalUri = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;

      debugPrint('APIMock Request: GET $finalUri');

      // Make HTTP request
      final response = await http.get(
        finalUri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
      ).timeout(_timeout);

      debugPrint('APIMock Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
          'headers': response.headers,
          'responseTime': DateTime.now().millisecondsSinceEpoch,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } on SocketException catch (e) {
      debugPrint('APIMock Network Error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.message}',
        'type': 'network_error',
      };
    } on HttpException catch (e) {
      debugPrint('APIMock HTTP Error: $e');
      return {
        'success': false,
        'error': 'HTTP error: ${e.message}',
        'type': 'http_error',
      };
    } catch (e) {
      debugPrint('APIMock Unknown Error: $e');
      return {
        'success': false,
        'error': 'Unknown error: $e',
        'type': 'unknown_error',
      };
    }
  }

  /// Post data to APIMock service
  static Future<Map<String, dynamic>> postMockData({
    required String endpoint,
    required Map<String, dynamic> data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      debugPrint('APIMock Request: POST $uri');
      debugPrint('APIMock Data: ${json.encode(data)}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: json.encode(data),
      ).timeout(_timeout);

      debugPrint('APIMock Response: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
          'statusCode': response.statusCode,
          'headers': response.headers,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          'statusCode': response.statusCode,
          'body': response.body,
        };
      }
    } catch (e) {
      debugPrint('APIMock POST Error: $e');
      return {
        'success': false,
        'error': 'Error posting data: $e',
        'type': 'post_error',
      };
    }
  }

  /// Get available mock endpoints
  static Map<String, String> getAvailableEndpoints() {
    return Map.from(_mockEndpoints);
  }

  /// Get mock users data
  static Future<Map<String, dynamic>> getMockUsers({
    int? limit,
    int? page,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['_limit'] = limit.toString();
    if (page != null) queryParams['_page'] = page.toString();

    return await getMockData(
      endpoint: _mockEndpoints['users']!,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get mock posts data
  static Future<Map<String, dynamic>> getMockPosts({
    int? userId,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId.toString();
    if (limit != null) queryParams['_limit'] = limit.toString();

    return await getMockData(
      endpoint: _mockEndpoints['posts']!,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get mock todos data
  static Future<Map<String, dynamic>> getMockTodos({
    int? userId,
    bool? completed,
  }) async {
    final queryParams = <String, String>{};
    if (userId != null) queryParams['userId'] = userId.toString();
    if (completed != null) queryParams['completed'] = completed.toString();

    return await getMockData(
      endpoint: _mockEndpoints['todos']!,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Get mock products data
  static Future<Map<String, dynamic>> getMockProducts({
    String? category,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (limit != null) queryParams['_limit'] = limit.toString();

    return await getMockData(
      endpoint: _mockEndpoints['products']!,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
  }

  /// Create mock user
  static Future<Map<String, dynamic>> createMockUser({
    required String name,
    required String email,
    String? phone,
    String? website,
  }) async {
    final userData = {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      if (website != null) 'website': website,
      'createdAt': DateTime.now().toIso8601String(),
    };

    return await postMockData(
      endpoint: _mockEndpoints['users']!,
      data: userData,
    );
  }

  /// Create mock post
  static Future<Map<String, dynamic>> createMockPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    final postData = {
      'title': title,
      'body': body,
      'userId': userId,
      'createdAt': DateTime.now().toIso8601String(),
    };

    return await postMockData(
      endpoint: _mockEndpoints['posts']!,
      data: postData,
    );
  }

  /// Test API connectivity
  static Future<bool> testConnectivity() async {
    try {
      final result = await getMockData(endpoint: '/api/health');
      return result['success'] == true;
    } catch (e) {
      debugPrint('APIMock Connectivity Test Failed: $e');
      return false;
    }
  }

  /// Get API status and information
  static Future<Map<String, dynamic>> getAPIStatus() async {
    try {
      final result = await getMockData(endpoint: '/api/status');
      return result;
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to get API status: $e',
      };
    }
  }

  /// Generate sample data for testing
  static Map<String, dynamic> generateSampleData(String type) {
    final now = DateTime.now();
    
    switch (type.toLowerCase()) {
      case 'user':
        return {
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'phone': '+1234567890',
          'website': 'https://johndoe.com',
          'address': {
            'street': '123 Main St',
            'city': 'Anytown',
            'zipcode': '12345',
          },
          'company': {
            'name': 'Doe Industries',
            'catchPhrase': 'Innovation at its finest',
          },
        };
      
      case 'post':
        return {
          'title': 'Sample Post Title',
          'body': 'This is a sample post body with some content for testing purposes.',
          'userId': 1,
          'tags': ['sample', 'test', 'demo'],
        };
      
      case 'todo':
        return {
          'title': 'Sample Todo Item',
          'completed': false,
          'userId': 1,
          'priority': 'medium',
          'dueDate': now.add(const Duration(days: 7)).toIso8601String(),
        };
      
      case 'product':
        return {
          'name': 'Sample Product',
          'description': 'This is a sample product for testing purposes.',
          'price': 29.99,
          'category': 'electronics',
          'inStock': true,
          'rating': 4.5,
        };
      
      default:
        return {
          'type': type,
          'data': 'Sample data',
          'timestamp': now.toIso8601String(),
        };
    }
  }
}
