import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Screenshot Service using Statically API
/// Provides website screenshot functionality
/// Author: Tamas dari TamsHub
class ScreenshotService {
  static const String _baseUrl = 'https://cdn.statically.io/screenshot';
  static const Duration _timeout = Duration(seconds: 60);

  /// Screenshot options
  static const Map<String, String> _deviceOptions = {
    'desktop': 'desktop',
    'mobile': 'mobile',
    'tablet': 'tablet',
  };

  static const Map<String, String> _formatOptions = {
    'png': 'png',
    'jpg': 'jpg',
    'webp': 'webp',
  };

  /// Take basic screenshot of a URL
  static Future<Map<String, dynamic>> takeScreenshot({
    required String url,
    String device = 'desktop',
    bool fullPage = false,
    String format = 'png',
    int? width,
    int? height,
    int? quality,
    bool darkMode = false,
  }) async {
    try {
      // Validate URL
      if (!_isValidUrl(url)) {
        return {
          'success': false,
          'error': 'Invalid URL format',
        };
      }

      // Build screenshot URL
      final screenshotUrl = _buildScreenshotUrl(
        url: url,
        device: device,
        fullPage: fullPage,
        format: format,
        width: width,
        height: height,
        quality: quality,
        darkMode: darkMode,
      );

      debugPrint('Screenshot Request: $screenshotUrl');

      // Make HTTP request
      final response = await http.get(
        Uri.parse(screenshotUrl),
        headers: {
          'User-Agent': 'PabsApp/1.0.0 (Screenshot Service)',
        },
      ).timeout(_timeout);

      debugPrint('Screenshot Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'imageBytes': response.bodyBytes,
          'contentType': response.headers['content-type'] ?? 'image/$format',
          'size': response.bodyBytes.length,
          'url': screenshotUrl,
          'originalUrl': url,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          'statusCode': response.statusCode,
        };
      }
    } on SocketException catch (e) {
      debugPrint('Screenshot Network Error: $e');
      return {
        'success': false,
        'error': 'Network error: ${e.message}',
        'type': 'network_error',
      };
    } catch (e) {
      debugPrint('Screenshot Error: $e');
      return {
        'success': false,
        'error': 'Screenshot failed: $e',
        'type': 'unknown_error',
      };
    }
  }

  /// Take mobile screenshot
  static Future<Map<String, dynamic>> takeMobileScreenshot({
    required String url,
    bool fullPage = false,
    String format = 'png',
  }) async {
    return await takeScreenshot(
      url: url,
      device: 'mobile',
      fullPage: fullPage,
      format: format,
    );
  }

  /// Take desktop screenshot
  static Future<Map<String, dynamic>> takeDesktopScreenshot({
    required String url,
    bool fullPage = false,
    String format = 'png',
    int? width,
    int? height,
  }) async {
    return await takeScreenshot(
      url: url,
      device: 'desktop',
      fullPage: fullPage,
      format: format,
      width: width,
      height: height,
    );
  }

  /// Take full page screenshot
  static Future<Map<String, dynamic>> takeFullPageScreenshot({
    required String url,
    String device = 'desktop',
    String format = 'png',
  }) async {
    return await takeScreenshot(
      url: url,
      device: device,
      fullPage: true,
      format: format,
    );
  }

  /// Save screenshot to device
  static Future<Map<String, dynamic>> saveScreenshot({
    required Uint8List imageBytes,
    required String originalUrl,
    String? filename,
    String format = 'png',
  }) async {
    try {
      // Get documents directory
      final directory = await getApplicationDocumentsDirectory();
      final screenshotsDir = Directory('${directory.path}/screenshots');
      
      // Create screenshots directory if it doesn't exist
      if (!await screenshotsDir.exists()) {
        await screenshotsDir.create(recursive: true);
      }

      // Generate filename if not provided
      final finalFilename = filename ?? 
          'screenshot_${DateTime.now().millisecondsSinceEpoch}.$format';
      
      final filePath = '${screenshotsDir.path}/$finalFilename';
      final file = File(filePath);

      // Write image bytes to file
      await file.writeAsBytes(imageBytes);

      debugPrint('Screenshot saved: $filePath');

      return {
        'success': true,
        'filePath': filePath,
        'filename': finalFilename,
        'size': imageBytes.length,
        'originalUrl': originalUrl,
      };
    } catch (e) {
      debugPrint('Save Screenshot Error: $e');
      return {
        'success': false,
        'error': 'Failed to save screenshot: $e',
      };
    }
  }

  /// Share screenshot
  static Future<Map<String, dynamic>> shareScreenshot({
    required Uint8List imageBytes,
    required String originalUrl,
    String? filename,
    String format = 'png',
    String? subject,
    String? text,
  }) async {
    try {
      // Save screenshot temporarily
      final saveResult = await saveScreenshot(
        imageBytes: imageBytes,
        originalUrl: originalUrl,
        filename: filename,
        format: format,
      );

      if (!saveResult['success']) {
        return saveResult;
      }

      final filePath = saveResult['filePath'] as String;
      
      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: subject ?? 'Screenshot from PabsApp',
        text: text ?? 'Screenshot of: $originalUrl',
      );

      return {
        'success': true,
        'message': 'Screenshot shared successfully',
        'filePath': filePath,
      };
    } catch (e) {
      debugPrint('Share Screenshot Error: $e');
      return {
        'success': false,
        'error': 'Failed to share screenshot: $e',
      };
    }
  }

  /// Get screenshot URL without downloading
  static String getScreenshotUrl({
    required String url,
    String device = 'desktop',
    bool fullPage = false,
    String format = 'png',
    int? width,
    int? height,
    int? quality,
    bool darkMode = false,
  }) {
    return _buildScreenshotUrl(
      url: url,
      device: device,
      fullPage: fullPage,
      format: format,
      width: width,
      height: height,
      quality: quality,
      darkMode: darkMode,
    );
  }

  /// Build screenshot URL with parameters
  static String _buildScreenshotUrl({
    required String url,
    String device = 'desktop',
    bool fullPage = false,
    String format = 'png',
    int? width,
    int? height,
    int? quality,
    bool darkMode = false,
  }) {
    final params = <String>[];
    
    // Add device parameter
    if (device != 'desktop') {
      params.add('device=$device');
    }
    
    // Add full page parameter
    if (fullPage) {
      params.add('full=true');
    }
    
    // Add format parameter
    if (format != 'png') {
      params.add('format=$format');
    }
    
    // Add width parameter
    if (width != null) {
      params.add('width=$width');
    }
    
    // Add height parameter
    if (height != null) {
      params.add('height=$height');
    }
    
    // Add quality parameter
    if (quality != null && quality >= 1 && quality <= 100) {
      params.add('quality=$quality');
    }
    
    // Add dark mode parameter
    if (darkMode) {
      params.add('dark=true');
    }

    // Build final URL
    final paramString = params.isNotEmpty ? '${params.join(',')}/' : '';
    return '$_baseUrl/$paramString$url';
  }

  /// Validate URL format
  static bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Get available device options
  static Map<String, String> getDeviceOptions() {
    return Map.from(_deviceOptions);
  }

  /// Get available format options
  static Map<String, String> getFormatOptions() {
    return Map.from(_formatOptions);
  }

  /// Validate screenshot parameters
  static Map<String, dynamic> validateParameters({
    required String url,
    String? device,
    String? format,
    int? width,
    int? height,
    int? quality,
  }) {
    final errors = <String>[];

    // Validate URL
    if (!_isValidUrl(url)) {
      errors.add('Invalid URL format');
    }

    // Validate device
    if (device != null && !_deviceOptions.containsKey(device)) {
      errors.add('Invalid device option');
    }

    // Validate format
    if (format != null && !_formatOptions.containsKey(format)) {
      errors.add('Invalid format option');
    }

    // Validate dimensions
    if (width != null && (width < 100 || width > 3840)) {
      errors.add('Width must be between 100 and 3840 pixels');
    }

    if (height != null && (height < 100 || height > 2160)) {
      errors.add('Height must be between 100 and 2160 pixels');
    }

    // Validate quality
    if (quality != null && (quality < 1 || quality > 100)) {
      errors.add('Quality must be between 1 and 100');
    }

    return {
      'isValid': errors.isEmpty,
      'errors': errors,
    };
  }
}
