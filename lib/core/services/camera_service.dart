import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Service untuk mengelola kamera dan media (Local Storage)
/// Author: Tamas dari TamsHub
///
/// Service ini menyediakan fungsi-fungsi untuk mengambil foto, merekam video,
/// dan mengelola media files dengan penyimpanan lokal.

class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();

  CameraService._();

  final ImagePicker _picker = ImagePicker();

  // Local storage key for media metadata
  static const String _mediaStorageKey = 'local_media_storage';

  /// Mengambil foto dari kamera
  Future<File?> takePhoto() async {
    try {
      // Check camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw Exception('Camera permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      rethrow;
    }
  }

  /// Mengambil foto dari galeri
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      rethrow;
    }
  }

  /// Merekam video
  Future<File?> recordVideo() async {
    try {
      // Check camera permission
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        throw Exception('Camera permission denied');
      }

      // Check microphone permission for video recording
      final microphoneStatus = await Permission.microphone.request();
      if (!microphoneStatus.isGranted) {
        throw Exception('Microphone permission denied');
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: AppConstants.maxVideoDuration),
      );

      return video != null ? File(video.path) : null;
    } catch (e) {
      debugPrint('Error recording video: $e');
      rethrow;
    }
  }

  /// Mengambil video dari galeri
  Future<File?> pickVideoFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(seconds: AppConstants.maxVideoDuration),
      );

      return video != null ? File(video.path) : null;
    } catch (e) {
      debugPrint('Error picking video from gallery: $e');
      rethrow;
    }
  }

  /// Save file to local storage
  Future<String> saveToLocalStorage(
    File file,
    String fileName, {
    String? userId,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${directory.path}/media');

      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      final userDir = userId != null
          ? Directory('${mediaDir.path}/$userId')
          : mediaDir;

      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }

      final localFile = File('${userDir.path}/$fileName');
      await file.copy(localFile.path);

      return localFile.path;
    } catch (e) {
      debugPrint('Error saving to local storage: $e');
      rethrow;
    }
  }

  /// Menyimpan metadata media ke local storage
  Future<void> saveMediaMetadata({
    required String fileName,
    required String filePath,
    required String fileType,
    required int fileSize,
    required String userId,
    String? description,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_mediaStorageKey) ?? '[]';
      final List<dynamic> mediaList = json.decode(existingData);

      final now = DateTime.now();
      final mediaItem = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'user_id': userId,
        'file_name': fileName,
        'file_path': filePath,
        'file_type': fileType,
        'file_size': fileSize,
        'description': description,
        'metadata': metadata,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      mediaList.add(mediaItem);
      await prefs.setString(_mediaStorageKey, json.encode(mediaList));
    } catch (e) {
      debugPrint('Error saving media metadata: $e');
      rethrow;
    }
  }

  /// Mendapatkan daftar media user
  Future<List<Map<String, dynamic>>> getUserMedia(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_mediaStorageKey) ?? '[]';
      final List<dynamic> mediaList = json.decode(existingData);

      return mediaList
          .where((item) => item['user_id'] == userId)
          .map((item) => Map<String, dynamic>.from(item))
          .toList()
        ..sort((a, b) => b['created_at'].compareTo(a['created_at']));
    } catch (e) {
      debugPrint('Error getting user media: $e');
      return [];
    }
  }

  /// Menghapus media
  Future<void> deleteMedia(String mediaId, String filePath) async {
    try {
      // Delete physical file
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Delete from metadata storage
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_mediaStorageKey) ?? '[]';
      final List<dynamic> mediaList = json.decode(existingData);

      mediaList.removeWhere((item) => item['id'] == mediaId);
      await prefs.setString(_mediaStorageKey, json.encode(mediaList));
    } catch (e) {
      debugPrint('Error deleting media: $e');
      rethrow;
    }
  }

  /// Validasi file media
  bool isValidMediaFile(File file) {
    final fileExtension = path.extension(file.path).toLowerCase();
    final extensionWithoutDot = fileExtension.substring(1);

    return AppConstants.supportedImageFormats.contains(extensionWithoutDot) ||
        AppConstants.supportedVideoFormats.contains(extensionWithoutDot);
  }

  /// Mendapatkan ukuran file dalam format yang mudah dibaca
  String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Mendapatkan tipe file
  String getFileType(File file) {
    final fileExtension = path.extension(file.path).toLowerCase();
    final extensionWithoutDot = fileExtension.substring(1);

    if (AppConstants.supportedImageFormats.contains(extensionWithoutDot)) {
      return 'image';
    } else if (AppConstants.supportedVideoFormats.contains(
      extensionWithoutDot,
    )) {
      return 'video';
    }
    return 'unknown';
  }

  /// Generate unique filename
  String generateFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'media_${timestamp}.$extension';
  }

  /// Generate unique filename from path
  String generateUniqueFileName(String originalPath) {
    final extension = path.extension(originalPath);
    return generateFileName(extension.substring(1));
  }

  /// Check if file is image
  bool isImageFile(String filePath) {
    final fileExtension = path.extension(filePath).toLowerCase();
    final extensionWithoutDot = fileExtension.substring(1);
    return AppConstants.supportedImageFormats.contains(extensionWithoutDot);
  }

  /// Check if file is video
  bool isVideoFile(String filePath) {
    final fileExtension = path.extension(filePath).toLowerCase();
    final extensionWithoutDot = fileExtension.substring(1);
    return AppConstants.supportedVideoFormats.contains(extensionWithoutDot);
  }

  /// Validate file size
  bool validateFileSize(File file, {required bool isImage}) {
    final fileSize = file.lengthSync();
    if (isImage) {
      return fileSize <= AppConstants.maxImageSize;
    } else {
      return fileSize <= AppConstants.maxVideoSize;
    }
  }

  /// Validate file format
  bool validateFileFormat(String fileName, {required bool isImage}) {
    final fileExtension = path.extension(fileName).toLowerCase();
    final extensionWithoutDot = fileExtension.substring(1);

    if (isImage) {
      return AppConstants.supportedImageFormats.contains(extensionWithoutDot);
    } else {
      return AppConstants.supportedVideoFormats.contains(extensionWithoutDot);
    }
  }

  /// Upload to Supabase (compatibility method - now saves locally)
  Future<String> uploadToSupabase(
    File file,
    String fileName, {
    String? userId,
    String? contentType,
  }) async {
    // Redirect to local storage
    return await saveToLocalStorage(file, fileName, userId: userId);
  }
}
