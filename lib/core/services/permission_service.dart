import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service untuk mengelola permission aplikasi
/// Author: Tamas dari TamsHub
///
/// Service ini mengelola request dan status permission
/// dengan dialog yang user-friendly dan handling yang proper

class PermissionService {
  /// Request camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    try {
      final status = await Permission.camera.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        // Show explanation dialog
        final shouldRequest = await _showPermissionDialog(
          context,
          'Izin Kamera',
          'Aplikasi memerlukan akses kamera untuk mengambil foto dan video. '
          'Izinkan akses kamera?',
          Icons.camera_alt,
        );
        
        if (shouldRequest == true) {
          final result = await Permission.camera.request();
          return result.isGranted;
        }
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        await _showSettingsDialog(
          context,
          'Izin Kamera Ditolak',
          'Akses kamera telah ditolak secara permanen. '
          'Silakan aktifkan di pengaturan aplikasi.',
        );
        return false;
      }
      
      // Request permission directly
      final result = await Permission.camera.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission(BuildContext context) async {
    try {
      final status = await Permission.location.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final shouldRequest = await _showPermissionDialog(
          context,
          'Izin Lokasi',
          'Aplikasi memerlukan akses lokasi untuk fitur berbasis lokasi. '
          'Izinkan akses lokasi?',
          Icons.location_on,
        );
        
        if (shouldRequest == true) {
          final result = await Permission.location.request();
          return result.isGranted;
        }
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        await _showSettingsDialog(
          context,
          'Izin Lokasi Ditolak',
          'Akses lokasi telah ditolak secara permanen. '
          'Silakan aktifkan di pengaturan aplikasi.',
        );
        return false;
      }
      
      final result = await Permission.location.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  /// Request storage permission
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      // For Android 13+ (API 33+), we need different permissions
      Permission permission;
      
      // Check Android version and use appropriate permission
      if (await _isAndroid13OrHigher()) {
        // For Android 13+, we need photos permission for media access
        permission = Permission.photos;
      } else {
        // For older Android versions
        permission = Permission.storage;
      }
      
      final status = await permission.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final shouldRequest = await _showPermissionDialog(
          context,
          'Izin Penyimpanan',
          'Aplikasi memerlukan akses penyimpanan untuk menyimpan dan membaca file. '
          'Izinkan akses penyimpanan?',
          Icons.storage,
        );
        
        if (shouldRequest == true) {
          final result = await permission.request();
          return result.isGranted;
        }
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        await _showSettingsDialog(
          context,
          'Izin Penyimpanan Ditolak',
          'Akses penyimpanan telah ditolak secara permanen. '
          'Silakan aktifkan di pengaturan aplikasi.',
        );
        return false;
      }
      
      final result = await permission.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Request microphone permission
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    try {
      final status = await Permission.microphone.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final shouldRequest = await _showPermissionDialog(
          context,
          'Izin Mikrofon',
          'Aplikasi memerlukan akses mikrofon untuk merekam audio. '
          'Izinkan akses mikrofon?',
          Icons.mic,
        );
        
        if (shouldRequest == true) {
          final result = await Permission.microphone.request();
          return result.isGranted;
        }
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        await _showSettingsDialog(
          context,
          'Izin Mikrofon Ditolak',
          'Akses mikrofon telah ditolak secara permanen. '
          'Silakan aktifkan di pengaturan aplikasi.',
        );
        return false;
      }
      
      final result = await Permission.microphone.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('Error requesting microphone permission: $e');
      return false;
    }
  }

  /// Request notification permission (Android 13+)
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    try {
      final status = await Permission.notification.status;
      
      if (status.isGranted) {
        return true;
      }
      
      if (status.isDenied) {
        final shouldRequest = await _showPermissionDialog(
          context,
          'Izin Notifikasi',
          'Aplikasi memerlukan izin untuk mengirim notifikasi. '
          'Izinkan notifikasi?',
          Icons.notifications,
        );
        
        if (shouldRequest == true) {
          final result = await Permission.notification.request();
          return result.isGranted;
        }
        return false;
      }
      
      if (status.isPermanentlyDenied) {
        await _showSettingsDialog(
          context,
          'Izin Notifikasi Ditolak',
          'Izin notifikasi telah ditolak secara permanen. '
          'Silakan aktifkan di pengaturan aplikasi.',
        );
        return false;
      }
      
      final result = await Permission.notification.request();
      return result.isGranted;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Request multiple permissions at once
  static Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
    BuildContext context,
    List<Permission> permissions,
  ) async {
    try {
      final results = await permissions.request();
      return results;
    } catch (e) {
      debugPrint('Error requesting multiple permissions: $e');
      return {};
    }
  }

  /// Check if all required permissions are granted
  static Future<bool> checkAllPermissions(List<Permission> permissions) async {
    try {
      for (final permission in permissions) {
        final status = await permission.status;
        if (!status.isGranted) {
          return false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error checking permissions: $e');
      return false;
    }
  }

  /// Show permission explanation dialog
  static Future<bool?> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(icon, size: 48, color: Theme.of(context).primaryColor),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Izinkan'),
          ),
        ],
      ),
    );
  }

  /// Show settings dialog for permanently denied permissions
  static Future<void> _showSettingsDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.settings, size: 48, color: Colors.orange),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  /// Check if Android version is 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    try {
      // This is a simplified check - in real app you might want to use
      // device_info_plus package for more accurate version detection
      return true; // Assume modern Android for now
    } catch (e) {
      debugPrint('Error checking Android version: $e');
      return false;
    }
  }

  /// Get permission status text for UI
  static String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Diizinkan';
      case PermissionStatus.denied:
        return 'Ditolak';
      case PermissionStatus.restricted:
        return 'Dibatasi';
      case PermissionStatus.limited:
        return 'Terbatas';
      case PermissionStatus.permanentlyDenied:
        return 'Ditolak Permanen';
      case PermissionStatus.provisional:
        return 'Sementara';
    }
  }

  /// Get permission icon
  static IconData getPermissionIcon(Permission permission) {
    if (permission == Permission.camera) return Icons.camera_alt;
    if (permission == Permission.location) return Icons.location_on;
    if (permission == Permission.storage) return Icons.storage;
    if (permission == Permission.microphone) return Icons.mic;
    if (permission == Permission.notification) return Icons.notifications;
    return Icons.security;
  }
}
