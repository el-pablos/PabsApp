# 🗄️ PabsApp Supabase Database Integration Guide

## 📋 Table of Contents

1. [Database Setup](#database-setup)
2. [Environment Configuration](#environment-configuration)
3. [Flutter Integration](#flutter-integration)
4. [Service Layer Updates](#service-layer-updates)
5. [Authentication Integration](#authentication-integration)
6. [Testing & Verification](#testing--verification)

---

## 🚀 Database Setup

### 1. Create Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Create new project
3. Note down your project URL and anon key

### 2. Execute Database Scripts

Execute the SQL scripts in this order:

```sql
-- 1. Create tables and schema
\i database/supabase_schema.sql

-- 2. Create indexes and constraints
\i database/indexes_and_constraints.sql

-- 3. Setup RLS policies
\i database/rls_policies.sql

-- 4. Insert sample data (optional)
\i database/sample_data.sql
```

### 3. Verify Database Setup

```sql
-- Check if all tables are created
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
ORDER BY table_name;

-- Check RLS is enabled
SELECT schemaname, tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND rowsecurity = true;
```

---

## ⚙️ Environment Configuration

### 1. Update .env File

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# Database Configuration
DATABASE_URL=postgresql://postgres:your_password@db.your-project.supabase.co:5432/postgres
```

### 2. Add Supabase Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.3.4
  postgrest: ^2.1.1
  realtime_client: ^2.0.2
```

### 3. Initialize Supabase in Flutter

Update `lib/main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    debug: kDebugMode,
  );
  
  runApp(const PabsApp());
}

// Global Supabase client
final supabase = Supabase.instance.client;
```

---

## 🔧 Flutter Integration

### 1. Create Database Service

Create `lib/core/services/database_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  static final _client = Supabase.instance.client;
  
  // Generic CRUD operations
  static Future<List<Map<String, dynamic>>> select(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
  }) async {
    var query = _client.from(table);
    
    if (select != null) query = query.select(select);
    if (filters != null) {
      filters.forEach((key, value) {
        query = query.eq(key, value);
      });
    }
    if (orderBy != null) query = query.order(orderBy);
    if (limit != null) query = query.limit(limit);
    
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }
  
  static Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(table)
        .insert(data)
        .select()
        .single();
    return response;
  }
  
  static Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await _client
        .from(table)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return response;
  }
  
  static Future<void> delete(String table, String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
```

### 2. Update Authentication Service

Update `lib/core/services/auth_service.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _client = Supabase.instance.client;
  
  // Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'username': username,
        'full_name': fullName,
      },
    );
    
    // Create user profile
    if (response.user != null) {
      await DatabaseService.insert('users', {
        'auth_user_id': response.user!.id,
        'username': username,
        'email': email,
        'full_name': fullName,
      });
    }
    
    return response;
  }
  
  // Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // Get current user
  static User? get currentUser => _client.auth.currentUser;
  
  // Get current user profile
  static Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    
    final profiles = await DatabaseService.select(
      'users',
      filters: {'auth_user_id': user.id},
    );
    
    return profiles.isNotEmpty ? profiles.first : null;
  }
}
```

---

## 🔄 Service Layer Updates

### 1. Update Todo Service

Update `lib/core/services/todo_service.dart`:

```dart
class TodoService {
  // Get user todos
  static Future<List<TodoModel>> getUserTodos(String userId) async {
    final data = await DatabaseService.select(
      'todos',
      select: '''
        *,
        todo_categories(name, color, icon)
      ''',
      filters: {'user_id': userId},
      orderBy: 'created_at',
    );
    
    return data.map((json) => TodoModel.fromJson(json)).toList();
  }
  
  // Create todo
  static Future<TodoModel> createTodo(TodoModel todo) async {
    final data = await DatabaseService.insert('todos', todo.toJson());
    return TodoModel.fromJson(data);
  }
  
  // Update todo
  static Future<TodoModel> updateTodo(TodoModel todo) async {
    final data = await DatabaseService.update(
      'todos',
      todo.id,
      todo.toJson(),
    );
    return TodoModel.fromJson(data);
  }
  
  // Delete todo
  static Future<void> deleteTodo(String todoId) async {
    await DatabaseService.delete('todos', todoId);
  }
}
```

### 2. Update Transaction Service

Update `lib/core/services/transaction_service.dart`:

```dart
class TransactionService {
  // Get user transactions
  static Future<List<TransactionModel>> getUserTransactions(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var filters = {'user_id': userId};
    
    final data = await DatabaseService.select(
      'transactions',
      select: '''
        *,
        transaction_categories(name, color, icon),
        payment_methods(name, method_type)
      ''',
      filters: filters,
      orderBy: 'transaction_date',
    );
    
    return data.map((json) => TransactionModel.fromJson(json)).toList();
  }
  
  // Create transaction
  static Future<TransactionModel> createTransaction(
    TransactionModel transaction,
  ) async {
    final data = await DatabaseService.insert(
      'transactions',
      transaction.toJson(),
    );
    return TransactionModel.fromJson(data);
  }
}
```

### 3. Update Location Service

Update `lib/core/services/location_service.dart`:

```dart
class LocationService {
  // Save location
  static Future<SavedLocationModel> saveLocation(
    SavedLocationModel location,
  ) async {
    final data = await DatabaseService.insert(
      'saved_locations',
      location.toJson(),
    );
    return SavedLocationModel.fromJson(data);
  }
  
  // Get saved locations
  static Future<List<SavedLocationModel>> getSavedLocations(
    String userId,
  ) async {
    final data = await DatabaseService.select(
      'saved_locations',
      filters: {'user_id': userId},
      orderBy: 'created_at',
    );
    
    return data.map((json) => SavedLocationModel.fromJson(json)).toList();
  }
  
  // Record location history
  static Future<void> recordLocationHistory({
    required String userId,
    required double latitude,
    required double longitude,
    required double accuracy,
    String? activityType,
  }) async {
    await DatabaseService.insert('location_history', {
      'user_id': userId,
      'coordinates': 'POINT($longitude $latitude)',
      'accuracy': accuracy,
      'activity_type': activityType,
    });
  }
}
```

---

## 🔐 Authentication Integration

### 1. Update Auth Provider

Update `lib/providers/auth_provider.dart`:

```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  AuthProvider() {
    _initializeAuth();
  }
  
  Future<void> _initializeAuth() async {
    _setLoading(true);
    
    try {
      // Check if user is already signed in
      _user = AuthService.currentUser;
      
      if (_user != null) {
        _userProfile = await AuthService.getCurrentUserProfile();
      }
      
      // Listen to auth state changes
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        _user = data.session?.user;
        if (_user != null) {
          _loadUserProfile();
        } else {
          _userProfile = null;
        }
        notifyListeners();
      });
    } catch (e) {
      _setError('Error initializing auth: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final response = await AuthService.signIn(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _user = response.user;
        await _loadUserProfile();
        return true;
      }
      
      return false;
    } catch (e) {
      _setError('Login failed: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadUserProfile() async {
    try {
      _userProfile = await AuthService.getCurrentUserProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }
  
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await AuthService.signOut();
      _user = null;
      _userProfile = null;
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
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
```

---

## 🧪 Testing & Verification

### 1. Test Database Connection

Create `test/database_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Database Tests', () {
    setUpAll(() async {
      await Supabase.initialize(
        url: 'your-supabase-url',
        anonKey: 'your-anon-key',
      );
    });
    
    test('should connect to database', () async {
      final response = await Supabase.instance.client
          .from('users')
          .select('count')
          .count(CountOption.exact);
      
      expect(response.count, isA<int>());
    });
    
    test('should create and retrieve todo', () async {
      // Test todo CRUD operations
      final todo = {
        'title': 'Test Todo',
        'description': 'Test Description',
        'user_id': 'test-user-id',
      };
      
      final created = await Supabase.instance.client
          .from('todos')
          .insert(todo)
          .select()
          .single();
      
      expect(created['title'], equals('Test Todo'));
      
      // Clean up
      await Supabase.instance.client
          .from('todos')
          .delete()
          .eq('id', created['id']);
    });
  });
}
```

### 2. Test Authentication Flow

```dart
test('should authenticate user', () async {
  final response = await AuthService.signIn(
    email: 'test@example.com',
    password: 'testpassword',
  );
  
  expect(response.user, isNotNull);
  expect(response.session, isNotNull);
});
```

### 3. Verify RLS Policies

```sql
-- Test RLS policies
SET ROLE authenticated;
SET request.jwt.claims TO '{"sub": "550e8400-e29b-41d4-a716-446655440000"}';

-- Should return only user's data
SELECT * FROM todos;
SELECT * FROM transactions;
SELECT * FROM saved_locations;
```

---

## 🚀 Deployment Checklist

- [ ] Database schema created successfully
- [ ] RLS policies applied and tested
- [ ] Indexes created for performance
- [ ] Sample data inserted (optional)
- [ ] Flutter app connected to Supabase
- [ ] Authentication flow working
- [ ] CRUD operations tested
- [ ] Error handling implemented
- [ ] Environment variables configured
- [ ] Production database secured

---

## 📞 Support

If you encounter any issues during integration:

1. Check Supabase logs in dashboard
2. Verify environment variables
3. Test database connection
4. Review RLS policies
5. Check Flutter console for errors

For additional help, contact: yeteprem.end23juni@gmail.com
