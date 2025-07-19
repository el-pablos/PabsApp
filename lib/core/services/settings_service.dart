import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/settings_model.dart';

/// Service untuk mengelola pengaturan aplikasi
/// Author: Tamas dari TamsHub
///
/// Service ini mengelola operasi CRUD untuk pengaturan aplikasi
/// menggunakan SharedPreferences untuk penyimpanan lokal

class SettingsService {
  static const String _settingsKey = 'app_settings';

  /// Mendapatkan pengaturan user
  Future<SettingsModel> getSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('${_settingsKey}_$userId');
      
      if (settingsJson != null) {
        final settingsData = jsonDecode(settingsJson) as Map<String, dynamic>;
        return SettingsModel.fromJson(settingsData);
      }
      
      // Return default settings if not found
      final defaultSettings = SettingsModel.defaultSettings(userId);
      await saveSettings(defaultSettings);
      return defaultSettings;
    } catch (e) {
      debugPrint('Error getting settings: $e');
      return SettingsModel.defaultSettings(userId);
    }
  }

  /// Menyimpan pengaturan user
  Future<void> saveSettings(SettingsModel settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(settings.toJson());
      await prefs.setString('${_settingsKey}_${settings.userId}', settingsJson);
      
      debugPrint('Settings saved successfully');
    } catch (e) {
      debugPrint('Error saving settings: $e');
      throw Exception('Failed to save settings: $e');
    }
  }

  /// Update pengaturan tertentu
  Future<void> updateSetting(String userId, String key, dynamic value) async {
    try {
      final settings = await getSettings(userId);
      
      SettingsModel updatedSettings;
      switch (key) {
        case 'notifications':
          updatedSettings = settings.copyWith(
            notificationsEnabled: value as bool,
            updatedAt: DateTime.now(),
          );
          break;
        case 'sound':
          updatedSettings = settings.copyWith(
            soundEnabled: value as bool,
            updatedAt: DateTime.now(),
          );
          break;
        case 'vibration':
          updatedSettings = settings.copyWith(
            vibrationEnabled: value as bool,
            updatedAt: DateTime.now(),
          );
          break;
        case 'autoBackup':
          updatedSettings = settings.copyWith(
            autoBackup: value as bool,
            updatedAt: DateTime.now(),
          );
          break;
        case 'biometric':
          updatedSettings = settings.copyWith(
            biometricEnabled: value as bool,
            updatedAt: DateTime.now(),
          );
          break;
        case 'language':
          updatedSettings = settings.copyWith(
            language: value as String,
            updatedAt: DateTime.now(),
          );
          break;
        case 'theme':
          updatedSettings = settings.copyWith(
            theme: value as String,
            updatedAt: DateTime.now(),
          );
          break;
        default:
          throw Exception('Unknown setting key: $key');
      }

      await saveSettings(updatedSettings);
    } catch (e) {
      debugPrint('Error updating setting: $e');
      throw Exception('Failed to update setting: $e');
    }
  }

  /// Menghapus pengaturan user
  Future<void> deleteSettings(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_settingsKey}_$userId');
      
      debugPrint('Settings deleted successfully');
    } catch (e) {
      debugPrint('Error deleting settings: $e');
      throw Exception('Failed to delete settings: $e');
    }
  }

  /// Reset pengaturan ke default
  Future<void> resetSettings(String userId) async {
    try {
      final defaultSettings = SettingsModel.defaultSettings(userId);
      await saveSettings(defaultSettings);
      
      debugPrint('Settings reset to default');
    } catch (e) {
      debugPrint('Error resetting settings: $e');
      throw Exception('Failed to reset settings: $e');
    }
  }

  /// Export pengaturan ke JSON string
  Future<String> exportSettings(String userId) async {
    try {
      final settings = await getSettings(userId);
      return jsonEncode(settings.toJson());
    } catch (e) {
      debugPrint('Error exporting settings: $e');
      throw Exception('Failed to export settings: $e');
    }
  }

  /// Import pengaturan dari JSON string
  Future<void> importSettings(String userId, String settingsJson) async {
    try {
      final settingsData = jsonDecode(settingsJson) as Map<String, dynamic>;
      final settings = SettingsModel.fromJson(settingsData);
      
      // Update user ID to current user
      final updatedSettings = settings.copyWith(
        userId: userId,
        updatedAt: DateTime.now(),
      );
      
      await saveSettings(updatedSettings);
      
      debugPrint('Settings imported successfully');
    } catch (e) {
      debugPrint('Error importing settings: $e');
      throw Exception('Failed to import settings: $e');
    }
  }

  /// Mendapatkan semua pengaturan (untuk debug/admin)
  Future<List<SettingsModel>> getAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_settingsKey));
      
      final settingsList = <SettingsModel>[];
      for (final key in keys) {
        final settingsJson = prefs.getString(key);
        if (settingsJson != null) {
          final settingsData = jsonDecode(settingsJson) as Map<String, dynamic>;
          settingsList.add(SettingsModel.fromJson(settingsData));
        }
      }
      
      return settingsList;
    } catch (e) {
      debugPrint('Error getting all settings: $e');
      return [];
    }
  }

  /// Validasi pengaturan
  bool validateSettings(SettingsModel settings) {
    try {
      // Check if user ID is not empty
      if (settings.userId.isEmpty) return false;
      
      // Check if language is supported
      const supportedLanguages = ['Indonesia', 'English'];
      if (!supportedLanguages.contains(settings.language)) return false;
      
      // Check if theme is supported
      const supportedThemes = ['system', 'light', 'dark'];
      if (!supportedThemes.contains(settings.theme)) return false;
      
      return true;
    } catch (e) {
      debugPrint('Error validating settings: $e');
      return false;
    }
  }

  /// Backup pengaturan
  Future<Map<String, dynamic>> backupSettings(String userId) async {
    try {
      final settings = await getSettings(userId);
      return {
        'settings': settings.toJson(),
        'backup_date': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
    } catch (e) {
      debugPrint('Error backing up settings: $e');
      throw Exception('Failed to backup settings: $e');
    }
  }

  /// Restore pengaturan dari backup
  Future<void> restoreSettings(String userId, Map<String, dynamic> backup) async {
    try {
      if (backup['version'] != '1.0') {
        throw Exception('Unsupported backup version');
      }
      
      final settingsData = backup['settings'] as Map<String, dynamic>;
      final settings = SettingsModel.fromJson(settingsData);
      
      // Update user ID and timestamp
      final restoredSettings = settings.copyWith(
        userId: userId,
        updatedAt: DateTime.now(),
      );
      
      if (!validateSettings(restoredSettings)) {
        throw Exception('Invalid settings data');
      }
      
      await saveSettings(restoredSettings);
      
      debugPrint('Settings restored successfully');
    } catch (e) {
      debugPrint('Error restoring settings: $e');
      throw Exception('Failed to restore settings: $e');
    }
  }

  /// Clear all app data (untuk logout/reset)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_settingsKey));
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      debugPrint('All settings data cleared');
    } catch (e) {
      debugPrint('Error clearing all data: $e');
      throw Exception('Failed to clear all data: $e');
    }
  }
}
