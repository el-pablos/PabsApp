import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/profile_model.dart';

/// Service untuk mengelola profil user
/// Author: Tamas dari TamsHub
///
/// Service ini mengelola operasi CRUD untuk profil user
/// menggunakan local storage (SharedPreferences dan file system)

class ProfileService {
  static const String _profileKey = 'user_profile';
  static const String _avatarDir = 'avatars';

  /// Mendapatkan profil user
  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('${_profileKey}_$userId');
      
      if (profileJson != null) {
        final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
        return ProfileModel.fromJson(profileData);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      return null;
    }
  }

  /// Menyimpan profil user
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      await prefs.setString('${_profileKey}_${profile.id}', profileJson);
      
      debugPrint('Profile saved successfully');
    } catch (e) {
      debugPrint('Error saving profile: $e');
      throw Exception('Failed to save profile: $e');
    }
  }

  /// Upload avatar dan return URL lokal
  Future<String> uploadAvatar(String userId, File imageFile) async {
    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory(path.join(appDir.path, _avatarDir));
      
      // Create directory if not exists
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }
      
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = 'avatar_${userId}_$timestamp$extension';
      final targetPath = path.join(avatarDir.path, fileName);
      
      // Copy file to app directory
      final savedFile = await imageFile.copy(targetPath);
      
      debugPrint('Avatar uploaded to: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      throw Exception('Failed to upload avatar: $e');
    }
  }

  /// Menghapus avatar
  Future<void> deleteAvatar(String avatarUrl) async {
    try {
      final file = File(avatarUrl);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Avatar deleted: $avatarUrl');
      }
    } catch (e) {
      debugPrint('Error deleting avatar: $e');
    }
  }

  /// Menghapus profil user
  Future<void> deleteProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get profile to delete avatar
      final profile = await getProfile(userId);
      if (profile?.avatarUrl != null) {
        await deleteAvatar(profile!.avatarUrl!);
      }
      
      // Remove profile from preferences
      await prefs.remove('${_profileKey}_$userId');
      
      debugPrint('Profile deleted successfully');
    } catch (e) {
      debugPrint('Error deleting profile: $e');
      throw Exception('Failed to delete profile: $e');
    }
  }

  /// Mendapatkan semua profil (untuk admin/debug)
  Future<List<ProfileModel>> getAllProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_profileKey));
      
      final profiles = <ProfileModel>[];
      for (final key in keys) {
        final profileJson = prefs.getString(key);
        if (profileJson != null) {
          final profileData = jsonDecode(profileJson) as Map<String, dynamic>;
          profiles.add(ProfileModel.fromJson(profileData));
        }
      }
      
      return profiles;
    } catch (e) {
      debugPrint('Error getting all profiles: $e');
      return [];
    }
  }

  /// Update profil tertentu
  Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      final profile = await getProfile(userId);
      if (profile == null) {
        throw Exception('Profile not found');
      }

      final updatedProfile = ProfileModel(
        id: profile.id,
        name: updates['name'] ?? profile.name,
        email: updates['email'] ?? profile.email,
        bio: updates['bio'] ?? profile.bio,
        phone: updates['phone'] ?? profile.phone,
        avatarUrl: updates['avatarUrl'] ?? profile.avatarUrl,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
      );

      await saveProfile(updatedProfile);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Validasi format email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validasi format phone
  bool isValidPhone(String phone) {
    return RegExp(r'^[\+]?[0-9]{10,15}$').hasMatch(phone.replaceAll(' ', ''));
  }

  /// Get avatar file size
  Future<int> getAvatarSize(String avatarUrl) async {
    try {
      final file = File(avatarUrl);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting avatar size: $e');
      return 0;
    }
  }

  /// Clean up old avatars (keep only latest 5 per user)
  Future<void> cleanupOldAvatars(String userId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory(path.join(appDir.path, _avatarDir));
      
      if (!await avatarDir.exists()) return;
      
      final files = await avatarDir.list().toList();
      final userAvatars = files
          .where((file) => file.path.contains('avatar_${userId}_'))
          .cast<File>()
          .toList();
      
      // Sort by modification time (newest first)
      userAvatars.sort((a, b) => 
          b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      // Keep only latest 5, delete the rest
      if (userAvatars.length > 5) {
        for (int i = 5; i < userAvatars.length; i++) {
          await userAvatars[i].delete();
          debugPrint('Deleted old avatar: ${userAvatars[i].path}');
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up old avatars: $e');
    }
  }
}
