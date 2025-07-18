import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/botcahx_model.dart';

/// Service untuk integrasi API BotcahX
/// Author: Tamas dari TamsHub
/// 
/// Service ini menyediakan fungsi-fungsi untuk mengakses berbagai
/// API dari BotcahX seperti AI, tools, dan utilities.

class BotcahXService {
  static BotcahXService? _instance;
  static BotcahXService get instance => _instance ??= BotcahXService._();
  
  BotcahXService._();

  static const String _baseUrl = 'https://api.botcahx.eu.org';
  static const String _apiKey = 'YOUR_API_KEY'; // Replace with actual API key

  final http.Client _client = http.Client();

  /// Mendapatkan informasi API
  Future<BotcahXApiInfo> getApiInfo() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXApiInfo.fromJson(data);
      } else {
        throw Exception('Failed to get API info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting API info: $e');
      rethrow;
    }
  }

  /// AI Chat dengan GPT
  Future<BotcahXChatResponse> chatWithGPT({
    required String message,
    String model = 'gpt-3.5-turbo',
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/ai/gpt'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
        body: json.encode({
          'message': message,
          'model': model,
          'apikey': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXChatResponse.fromJson(data);
      } else {
        throw Exception('Failed to chat with GPT: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error chatting with GPT: $e');
      rethrow;
    }
  }

  /// Generate gambar dengan AI
  Future<BotcahXImageResponse> generateImage({
    required String prompt,
    String model = 'dall-e-3',
    String size = '1024x1024',
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/ai/text2img'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
        body: json.encode({
          'prompt': prompt,
          'model': model,
          'size': size,
          'apikey': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXImageResponse.fromJson(data);
      } else {
        throw Exception('Failed to generate image: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating image: $e');
      rethrow;
    }
  }

  /// Download video dari YouTube
  Future<BotcahXDownloadResponse> downloadYouTube({
    required String url,
    String quality = '720p',
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/download/youtube'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
        body: json.encode({
          'url': url,
          'quality': quality,
          'apikey': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXDownloadResponse.fromJson(data);
      } else {
        throw Exception('Failed to download YouTube video: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading YouTube video: $e');
      rethrow;
    }
  }

  /// Download video dari TikTok
  Future<BotcahXDownloadResponse> downloadTikTok({
    required String url,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/download/tiktok'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
        body: json.encode({
          'url': url,
          'apikey': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXDownloadResponse.fromJson(data);
      } else {
        throw Exception('Failed to download TikTok video: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error downloading TikTok video: $e');
      rethrow;
    }
  }

  /// Stalk Instagram profile
  Future<BotcahXInstagramResponse> stalkInstagram({
    required String username,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/stalk/instagram/$username?apikey=$_apiKey'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXInstagramResponse.fromJson(data);
      } else {
        throw Exception('Failed to stalk Instagram: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error stalking Instagram: $e');
      rethrow;
    }
  }

  /// Cek info gempa terbaru
  Future<BotcahXGempaResponse> getGempaInfo() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/info/gempa?apikey=$_apiKey'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXGempaResponse.fromJson(data);
      } else {
        throw Exception('Failed to get gempa info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting gempa info: $e');
      rethrow;
    }
  }

  /// Cek cuaca berdasarkan kota
  Future<BotcahXCuacaResponse> getCuaca({
    required String kota,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/info/cuaca/$kota?apikey=$_apiKey'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXCuacaResponse.fromJson(data);
      } else {
        throw Exception('Failed to get cuaca info: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting cuaca info: $e');
      rethrow;
    }
  }

  /// Generate QR Code
  Future<BotcahXQRResponse> generateQR({
    required String text,
    int size = 200,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/tools/qr'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
        body: json.encode({
          'text': text,
          'size': size,
          'apikey': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXQRResponse.fromJson(data);
      } else {
        throw Exception('Failed to generate QR code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating QR code: $e');
      rethrow;
    }
  }

  /// Shortlink URL
  Future<BotcahXShortlinkResponse> createShortlink({
    required String url,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/api/tools/shortlink'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
        body: json.encode({
          'url': url,
          'apikey': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BotcahXShortlinkResponse.fromJson(data);
      } else {
        throw Exception('Failed to create shortlink: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error creating shortlink: $e');
      rethrow;
    }
  }

  /// Validasi koneksi ke API BotcahX
  Future<bool> validateConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api'),
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'PabsApp/1.0',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error validating connection: $e');
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
