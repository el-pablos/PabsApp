import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../constants/app_constants.dart';
import 'supabase_service.dart';

/// Service untuk mengelola kamera dan media
/// Author: Tamas dari TamsHub
/// 
/// Service ini menyediakan fungsi-fungsi untuk mengambil foto, merekam video,
/// dan mengelola media files dengan integrasi ke Supabase storage.

class CameraService {
  static CameraService? _instance;
  static CameraService get instance => _instance ??= CameraService._();
  
  CameraService._();

  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Mengambil foto dari kamera
  Future<File?> takePhoto() async {
    try {
      // Check camera permission
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        throw Exception('Izin kamera diperlukan untuk mengambil foto');
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      rethrow;
    }
  }

  /// Memilih foto dari galeri
  Future<File?> pickImageFromGallery() async {
    try {
      // Check storage permission
      final storagePermission = await Permission.storage.request();
      if (!storagePermission.isGranted) {
        throw Exception('Izin penyimpanan diperlukan untuk mengakses galeri');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      rethrow;
    }
  }

  /// Merekam video
  Future<File?> recordVideo() async {
    try {
      // Check camera permission
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        throw Exception('Izin kamera diperlukan untuk merekam video');
      }

      // Check microphone permission
      final microphonePermission = await Permission.microphone.request();
      if (!microphonePermission.isGranted) {
        throw Exception('Izin mikrofon diperlukan untuk merekam video');
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: AppConstants.maxVideoDuration),
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error recording video: $e');
      rethrow;
    }
  }

  /// Memilih video dari galeri
  Future<File?> pickVideoFromGallery() async {
    try {
      // Check storage permission
      final storagePermission = await Permission.storage.request();
      if (!storagePermission.isGranted) {
        throw Exception('Izin penyimpanan diperlukan untuk mengakses galeri');
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );

      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking video from gallery: $e');
      rethrow;
    }
  }

  /// Menyimpan file ke penyimpanan lokal
  Future<File> saveToLocalStorage(File file, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final mediaDir = Directory(path.join(directory.path, 'media'));
      
      if (!await mediaDir.exists()) {
        await mediaDir.create(recursive: true);
      }

      final savedFile = File(path.join(mediaDir.path, fileName));
      return await file.copy(savedFile.path);
    } catch (e) {
      debugPrint('Error saving file to local storage: $e');
      rethrow;
    }
  }

  /// Upload file ke Supabase storage
  Future<String> uploadToSupabase(File file, String fileName, {String? userId}) async {
    try {
      final fileBytes = await file.readAsBytes();
      final fileExtension = path.extension(fileName).toLowerCase();
      
      // Determine content type
      String contentType;
      if (AppConstants.supportedImageFormats.contains(fileExtension.substring(1))) {
        contentType = 'image/${fileExtension.substring(1)}';
      } else if (AppConstants.supportedVideoFormats.contains(fileExtension.substring(1))) {
        contentType = 'video/${fileExtension.substring(1)}';
      } else {
        contentType = 'application/octet-stream';
      }

      // Create file path with user ID if provided
      final filePath = userId != null 
          ? '$userId/$fileName'
          : fileName;

      final publicUrl = await _supabaseService.uploadFile(
        bucket: AppConstants.mediaBucket,
        path: filePath,
        fileBytes: fileBytes,
        contentType: contentType,
      );

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading file to Supabase: $e');
      rethrow;
    }
  }

  /// Menyimpan metadata media ke database
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
      final now = DateTime.now();
      
      await _supabaseService.insert(
        table: AppConstants.mediaTable,
        data: {
          'user_id': userId,
          'file_name': fileName,
          'file_path': filePath,
          'file_type': fileType,
          'file_size': fileSize,
          'description': description,
          'metadata': metadata,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Error saving media metadata: $e');
      rethrow;
    }
  }

  /// Mendapatkan daftar media user
  Future<List<Map<String, dynamic>>> getUserMedia(String userId) async {
    try {
      return await _supabaseService.select(
        table: AppConstants.mediaTable,
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );
    } catch (e) {
      debugPrint('Error getting user media: $e');
      rethrow;
    }
  }

  /// Menghapus media
  Future<void> deleteMedia(String mediaId, String filePath) async {
    try {
      // Delete from storage
      await _supabaseService.deleteFile(
        bucket: AppConstants.mediaBucket,
        path: filePath,
      );

      // Delete from database
      await _supabaseService.delete(
        table: AppConstants.mediaTable,
        column: 'id',
        value: mediaId,
      );
    } catch (e) {
      debugPrint('Error deleting media: $e');
      rethrow;
    }
  }

  /// Validasi ukuran file
  bool validateFileSize(File file, {bool isImage = true}) {
    final fileSize = file.lengthSync();
    final maxSize = isImage ? AppConstants.maxImageSize : AppConstants.maxImageSize * 10; // 50MB for video
    
    return fileSize <= maxSize;
  }

  /// Validasi format file
  bool validateFileFormat(String fileName, {bool isImage = true}) {
    final extension = path.extension(fileName).toLowerCase().substring(1);
    
    if (isImage) {
      return AppConstants.supportedImageFormats.contains(extension);
    } else {
      return AppConstants.supportedVideoFormats.contains(extension);
    }
  }

  /// Generate nama file unik
  String generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = path.extension(originalFileName);
    final baseName = path.basenameWithoutExtension(originalFileName);
    
    return '${baseName}_$timestamp$extension';
  }

  /// Mendapatkan ukuran file dalam format yang mudah dibaca
  String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Cek apakah file adalah gambar
  bool isImageFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase().substring(1);
    return AppConstants.supportedImageFormats.contains(extension);
  }

  /// Cek apakah file adalah video
  bool isVideoFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase().substring(1);
    return AppConstants.supportedVideoFormats.contains(extension);
  }
}
