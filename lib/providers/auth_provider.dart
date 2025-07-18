import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/services/supabase_service.dart';
import '../models/user_model.dart';

/// Provider untuk mengelola state autentikasi
/// Author: Tamas dari TamsHub
///
/// Provider ini mengelola semua state yang berkaitan dengan autentikasi user
/// termasuk login, register, logout, dan status autentikasi.

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService.instance;

  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  /// Inisialisasi autentikasi
  Future<void> _initializeAuth() async {
    try {
      _setLoading(true);

      // Listen to auth state changes
      _supabaseService.authStateChanges.listen((AuthState data) {
        _handleAuthStateChange(data);
      });

      // Check current session
      final session = _supabaseService.client.auth.currentSession;
      if (session != null) {
        await _loadUserProfile(session.user.id);
        _setAuthenticated(true);
      } else {
        _setAuthenticated(false);
      }
    } catch (e) {
      _setError('Gagal menginisialisasi autentikasi: $e');
      _setAuthenticated(false);
    } finally {
      _setLoading(false);
    }
  }

  /// Handle perubahan state autentikasi
  void _handleAuthStateChange(AuthState data) async {
    final session = data.session;

    if (session != null) {
      // User logged in
      await _loadUserProfile(session.user.id);
      _setAuthenticated(true);
    } else {
      // User logged out
      _currentUser = null;
      _setAuthenticated(false);
    }

    _setLoading(false);
  }

  /// Load profil user dari database
  Future<void> _loadUserProfile(String userId) async {
    try {
      final userData = await _supabaseService.selectSingle(
        table: 'users',
        filters: {'id': userId},
      );

      if (userData != null) {
        _currentUser = UserModel.fromJson(userData);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  /// Login dengan email dan password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await _supabaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadUserProfile(response.user!.id);
        _setAuthenticated(true);
        return true;
      } else {
        _setError('Login gagal');
        return false;
      }
    } catch (e) {
      _setError('Login gagal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Register dengan email dan password
  Future<bool> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // First, validate Supabase configuration
      final configValidation = await _supabaseService.validateConfiguration();
      if (!configValidation['auth_working']) {
        _setError(
          'Konfigurasi database bermasalah: ${configValidation['error']}',
        );
        return false;
      }

      final response = await _supabaseService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone_number': phoneNumber},
      );

      if (response.user != null) {
        // Create user profile in database with retry mechanism
        await _createUserProfileWithRetry(
          userId: response.user!.id,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
        );

        await _loadUserProfile(response.user!.id);
        _setAuthenticated(true);
        return true;
      } else {
        _setError('Registrasi gagal: User tidak dapat dibuat');
        return false;
      }
    } on PostgrestException catch (e) {
      String errorMessage = 'Database error: ${e.message}';
      if (e.code == 'PGRST106') {
        errorMessage =
            'Konfigurasi database bermasalah. Silakan coba lagi nanti.';
      }
      _setError(errorMessage);
      return false;
    } catch (e) {
      _setError('Registrasi gagal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Buat profil user di database dengan retry mechanism
  Future<void> _createUserProfileWithRetry({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        await _createUserProfile(
          userId: userId,
          email: email,
          fullName: fullName,
          phoneNumber: phoneNumber,
        );
        return; // Success, exit retry loop
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempts++;

        if (attempts < maxRetries) {
          // Wait before retry with exponential backoff
          await Future.delayed(Duration(seconds: attempts * 2));
        }
      }
    }

    // If all retries failed, throw the last exception
    throw lastException ??
        Exception('Failed to create user profile after $maxRetries attempts');
  }

  /// Buat profil user di database
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String fullName,
    String? phoneNumber,
  }) async {
    try {
      final now = DateTime.now();

      // Try to create user profile with explicit error handling for schema issues
      try {
        await _supabaseService.insert(
          table: 'users',
          data: {
            'id': userId,
            'email': email,
            'full_name': fullName,
            'phone_number': phoneNumber,
            'created_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
            'is_active': true,
            'is_verified': false,
          },
        );
      } on PostgrestException catch (e) {
        if (e.code == 'PGRST106') {
          // Schema error - try alternative approach
          debugPrint(
            'Schema error detected, trying alternative approach: ${e.message}',
          );

          // For now, we'll just log the user data and continue
          // In production, you might want to create the table or use a different approach
          debugPrint(
            'User profile data: ${{'id': userId, 'email': email, 'full_name': fullName, 'phone_number': phoneNumber}}',
          );

          // Don't throw error, allow registration to continue
          return;
        } else {
          rethrow;
        }
      }
    } catch (e) {
      debugPrint('Error creating user profile: $e');
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabaseService.signOut();
      _currentUser = null;
      _setAuthenticated(false);
    } catch (e) {
      _setError('Logout gagal: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _supabaseService.resetPassword(email);
      return true;
    } catch (e) {
      _setError('Reset password gagal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update profil user
  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? address,
    String? city,
    String? province,
    String? country,
    String? occupation,
    String? bio,
    DateTime? dateOfBirth,
  }) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updateData['full_name'] = fullName;
      if (phoneNumber != null) updateData['phone_number'] = phoneNumber;
      if (address != null) updateData['address'] = address;
      if (city != null) updateData['city'] = city;
      if (province != null) updateData['province'] = province;
      if (country != null) updateData['country'] = country;
      if (occupation != null) updateData['occupation'] = occupation;
      if (bio != null) updateData['bio'] = bio;
      if (dateOfBirth != null) {
        updateData['date_of_birth'] = dateOfBirth.toIso8601String();
      }

      await _supabaseService.update(
        table: 'users',
        data: updateData,
        column: 'id',
        value: _currentUser!.id,
      );

      // Reload user profile
      await _loadUserProfile(_currentUser!.id);
      return true;
    } catch (e) {
      _setError('Update profil gagal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Upload avatar
  Future<bool> uploadAvatar(List<int> fileBytes, String fileName) async {
    if (_currentUser == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final avatarPath = '${_currentUser!.id}/$fileName';
      final avatarUrl = await _supabaseService.uploadFile(
        bucket: 'profile-images',
        path: avatarPath,
        fileBytes: fileBytes,
        contentType: 'image/jpeg',
      );

      // Update user profile with new avatar URL
      await _supabaseService.update(
        table: 'users',
        data: {
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        },
        column: 'id',
        value: _currentUser!.id,
      );

      // Reload user profile
      await _loadUserProfile(_currentUser!.id);
      return true;
    } catch (e) {
      _setError('Upload avatar gagal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
