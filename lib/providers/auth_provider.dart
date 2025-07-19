import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider untuk mengelola state autentikasi
/// Author: Tamas dari TamsHub
///
/// Provider ini mengelola autentikasi sederhana dengan hardcoded credentials.

class AuthProvider extends ChangeNotifier {
  // Hardcoded credentials
  static const String _validUsername = 'tamas';
  static const String _validPassword = 'tamasnich';
  static const String _prefsKey = 'is_logged_in';

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _currentUsername;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String? get currentUsername => _currentUsername;

  AuthProvider() {
    _initializeAuth();
  }

  /// Inisialisasi autentikasi
  Future<void> _initializeAuth() async {
    _setLoading(true);

    try {
      // Check if user was previously logged in
      final prefs = await SharedPreferences.getInstance();
      final wasLoggedIn = prefs.getBool(_prefsKey) ?? false;

      if (wasLoggedIn) {
        final username = prefs.getString('username');
        if (username != null) {
          _currentUsername = username;
          _setAuthenticated(true);
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Login dengan hardcoded credentials
  Future<bool> signInWithCredentials({
    required String username,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Clean input
      final cleanUsername = username.trim().toLowerCase();
      final cleanPassword = password.trim();

      // Debug logging
      debugPrint('Login attempt:');
      debugPrint('Input username: "$cleanUsername"');
      debugPrint('Expected username: "$_validUsername"');
      debugPrint('Input password length: ${cleanPassword.length}');
      debugPrint('Expected password length: ${_validPassword.length}');
      debugPrint('Username match: ${cleanUsername == _validUsername}');
      debugPrint('Password match: ${cleanPassword == _validPassword}');

      // Check credentials with exact match
      if (cleanUsername == _validUsername && cleanPassword == _validPassword) {
        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_prefsKey, true);
        await prefs.setString('username', cleanUsername);

        _currentUsername = cleanUsername;
        _setAuthenticated(true);

        debugPrint('Login successful for user: $cleanUsername');
        return true;
      } else {
        // Provide more specific error messages
        String errorMsg = 'Username atau password salah';
        if (cleanUsername != _validUsername) {
          errorMsg = 'Username salah. Gunakan: "$_validUsername"';
        } else if (cleanPassword != _validPassword) {
          errorMsg = 'Password salah. Periksa kembali password Anda';
        }

        debugPrint('Login failed: $errorMsg');
        _setError(errorMsg);
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _setError('Login gagal: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      _setLoading(true);

      // Clear saved login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
      await prefs.remove('username');

      _currentUsername = null;
      _setAuthenticated(false);
      _clearError();
    } catch (e) {
      debugPrint('Error signing out: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set authenticated state
  void _setAuthenticated(bool authenticated) {
    _isAuthenticated = authenticated;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if user is valid (for compatibility with existing code)
  bool get hasValidUser => _isAuthenticated && _currentUsername != null;

  /// Get user ID (for compatibility with existing code)
  String get userId => _currentUsername ?? 'tamas';

  /// Get display name (for compatibility with existing code)
  String get displayName => _currentUsername?.toUpperCase() ?? 'TAMAS';

  /// Get initials (for compatibility with existing code)
  String get initials => _currentUsername?.substring(0, 1).toUpperCase() ?? 'T';

  /// Get current user object (for compatibility with existing code)
  SimpleUser? get currentUser => _isAuthenticated && _currentUsername != null
      ? SimpleUser(id: userId, displayName: displayName, initials: initials)
      : null;
}

/// Simple user class for compatibility
class SimpleUser {
  final String id;
  final String displayName;
  final String initials;

  SimpleUser({
    required this.id,
    required this.displayName,
    required this.initials,
  });
}
