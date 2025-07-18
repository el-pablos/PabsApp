import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

/// Service untuk mengelola koneksi dan operasi Supabase
/// Author: Tamas dari TamsHub
///
/// Service ini menyediakan fungsi-fungsi untuk berinteraksi dengan database Supabase
/// termasuk autentikasi, CRUD operations, dan real-time subscriptions.

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  /// Client Supabase
  SupabaseClient get client => Supabase.instance.client;

  /// Inisialisasi Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
        debug: true,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        postgrestOptions: const PostgrestClientOptions(
          schema: 'public', // Explicitly set schema to public
        ),
      );
    } catch (e) {
      throw Exception('Failed to initialize Supabase: $e');
    }
  }

  /// Mendapatkan user yang sedang login
  User? get currentUser => client.auth.currentUser;

  /// Stream untuk mendengarkan perubahan status autentikasi
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Login dengan email dan password
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Register dengan email dan password
  Future<AuthResponse> signUpWithEmailAndPassword({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  /// Insert data ke tabel
  Future<List<Map<String, dynamic>>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await client.from(table).insert(data).select();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      if (e is PostgrestException) {
        throw Exception('Database error: ${e.message} (Code: ${e.code})');
      }
      throw Exception('Failed to insert data: $e');
    }
  }

  /// Update data di tabel
  Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required String column,
    required dynamic value,
  }) async {
    try {
      final response = await client
          .from(table)
          .update(data)
          .eq(column, value)
          .select();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete data dari tabel
  Future<List<Map<String, dynamic>>> delete({
    required String table,
    required String column,
    required dynamic value,
  }) async {
    try {
      final response = await client
          .from(table)
          .delete()
          .eq(column, value)
          .select();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Select data dari tabel
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    String? orderBy,
    bool ascending = true,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      var query = client.from(table).select(columns);

      // Apply filters
      if (filters != null) {
        filters.forEach((key, value) {
          query = query.eq(key, value);
        });
      }

      // Build final query with ordering and limit
      if (orderBy != null && limit != null) {
        final response = await query
            .order(orderBy, ascending: ascending)
            .limit(limit);
        return List<Map<String, dynamic>>.from(response);
      } else if (orderBy != null) {
        final response = await query.order(orderBy, ascending: ascending);
        return List<Map<String, dynamic>>.from(response);
      } else if (limit != null) {
        final response = await query.limit(limit);
        return List<Map<String, dynamic>>.from(response);
      } else {
        final response = await query;
        return List<Map<String, dynamic>>.from(response);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Select single data dari tabel
  Future<Map<String, dynamic>?> selectSingle({
    required String table,
    String columns = '*',
    required Map<String, dynamic> filters,
  }) async {
    try {
      var query = client.from(table).select(columns);

      // Apply filters
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });

      final response = await query.maybeSingle();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Upload file ke storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> fileBytes,
    String? contentType,
  }) async {
    try {
      await client.storage
          .from(bucket)
          .uploadBinary(
            path,
            Uint8List.fromList(fileBytes),
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );

      final publicUrl = client.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Download file dari storage
  Future<List<int>> downloadFile({
    required String bucket,
    required String path,
  }) async {
    try {
      final response = await client.storage.from(bucket).download(path);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete file dari storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await client.storage.from(bucket).remove([path]);
    } catch (e) {
      rethrow;
    }
  }

  /// Subscribe ke perubahan data real-time
  RealtimeChannel subscribeToTable({
    required String table,
    required void Function(PostgresChangePayload) onInsert,
    required void Function(PostgresChangePayload) onUpdate,
    required void Function(PostgresChangePayload) onDelete,
  }) {
    final channel = client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: table,
          callback: onInsert,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: table,
          callback: onUpdate,
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: table,
          callback: onDelete,
        )
        .subscribe();

    return channel;
  }

  /// Unsubscribe dari channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }

  /// Execute RPC (Remote Procedure Call)
  Future<dynamic> rpc({
    required String functionName,
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await client.rpc(functionName, params: params);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Check koneksi ke Supabase
  Future<bool> checkConnection() async {
    try {
      // Try to get current session first
      final session = client.auth.currentSession;
      if (session != null) {
        return true;
      }

      // If no session, try a simple query to test connection
      await client.rpc('ping').timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      // If ping fails, try alternative method
      try {
        await client
            .from('users')
            .select('count')
            .limit(1)
            .timeout(const Duration(seconds: 5));
        return true;
      } catch (e2) {
        return false;
      }
    }
  }

  /// Validate Supabase configuration
  Future<Map<String, dynamic>> validateConfiguration() async {
    try {
      final result = <String, dynamic>{
        'url_valid': false,
        'auth_working': false,
        'database_accessible': false,
        'error': null,
      };

      // Check URL format
      final uri = Uri.tryParse(AppConstants.supabaseUrl);
      if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
        result['error'] = 'Invalid Supabase URL format';
        return result;
      }
      result['url_valid'] = true;

      // Check auth service
      try {
        client.auth.currentSession; // Test auth service access
        result['auth_working'] = true;
      } catch (e) {
        result['error'] = 'Auth service error: $e';
      }

      // Check database access with a simple query instead of RPC
      try {
        // Try a simple query that should work with any schema
        await client
            .from('auth.users')
            .select('count')
            .limit(1)
            .timeout(const Duration(seconds: 10));
        result['database_accessible'] = true;
      } catch (e) {
        // If auth.users fails, try with public schema
        try {
          await client
              .from('users')
              .select('count')
              .limit(1)
              .timeout(const Duration(seconds: 5));
          result['database_accessible'] = true;
        } catch (e2) {
          if (e is PostgrestException) {
            result['error'] =
                'Database schema error: ${e.message} (Code: ${e.code})';
          } else {
            result['error'] = 'Database connection error: $e';
          }
        }
      }

      return result;
    } catch (e) {
      return {
        'url_valid': false,
        'auth_working': false,
        'database_accessible': false,
        'error': 'Configuration validation failed: $e',
      };
    }
  }
}
