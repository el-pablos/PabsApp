import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../constants/app_constants.dart';
import '../../models/todo_model.dart';
import 'supabase_service.dart';

/// Service untuk mengelola TodoList
/// Author: Tamas dari TamsHub
///
/// Service ini menyediakan fungsi-fungsi untuk mengelola todo items
/// dengan integrasi lokasi dan Google Maps.

class TodoService {
  static TodoService? _instance;
  static TodoService get instance => _instance ??= TodoService._();

  TodoService._();

  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Membuat todo baru
  Future<TodoModel> createTodo({
    required String userId,
    required String title,
    String? description,
    DateTime? dueDate,
    String priority = 'medium',
    String? category,
    List<String>? tags,
    bool includeCurrentLocation = false,
  }) async {
    try {
      final now = DateTime.now();
      LocationData? location;

      // Get current location if requested
      if (includeCurrentLocation) {
        location = await getCurrentLocation();
      }

      final todoData = {
        'user_id': userId,
        'title': title,
        'description': description,
        'is_completed': false,
        'due_date': dueDate?.toIso8601String(),
        'priority': priority,
        'category': category,
        'tags': tags,
        'location': location?.toJson(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final result = await _supabaseService.insert(
        table: AppConstants.todosTable,
        data: todoData,
      );

      return TodoModel.fromJson(result.first);
    } catch (e) {
      debugPrint('Error creating todo: $e');
      rethrow;
    }
  }

  /// Mendapatkan semua todos user
  Future<List<TodoModel>> getUserTodos(String userId) async {
    try {
      final result = await _supabaseService.select(
        table: AppConstants.todosTable,
        filters: {'user_id': userId},
        orderBy: 'created_at',
        ascending: false,
      );

      return result.map((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting user todos: $e');
      rethrow;
    }
  }

  /// Mendapatkan todos berdasarkan status
  Future<List<TodoModel>> getTodosByStatus({
    required String userId,
    required bool isCompleted,
  }) async {
    try {
      final result = await _supabaseService.select(
        table: AppConstants.todosTable,
        filters: {'user_id': userId, 'is_completed': isCompleted},
        orderBy: 'created_at',
        ascending: false,
      );

      return result.map((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting todos by status: $e');
      rethrow;
    }
  }

  /// Mendapatkan todos berdasarkan kategori
  Future<List<TodoModel>> getTodosByCategory({
    required String userId,
    required String category,
  }) async {
    try {
      final result = await _supabaseService.select(
        table: AppConstants.todosTable,
        filters: {'user_id': userId, 'category': category},
        orderBy: 'created_at',
        ascending: false,
      );

      return result.map((json) => TodoModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting todos by category: $e');
      rethrow;
    }
  }

  /// Mendapatkan todos yang akan jatuh tempo hari ini
  Future<List<TodoModel>> getTodayTodos(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final result = await _supabaseService.select(
        table: AppConstants.todosTable,
        filters: {'user_id': userId},
        orderBy: 'due_date',
        ascending: true,
      );

      final todos = result.map((json) => TodoModel.fromJson(json)).toList();

      return todos.where((todo) {
        if (todo.dueDate == null) return false;
        return todo.dueDate!.isAfter(startOfDay) &&
            todo.dueDate!.isBefore(endOfDay);
      }).toList();
    } catch (e) {
      debugPrint('Error getting today todos: $e');
      rethrow;
    }
  }

  /// Update todo
  Future<TodoModel> updateTodo({
    required String todoId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    String? priority,
    String? category,
    List<String>? tags,
    LocationData? location,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (isCompleted != null) {
        updateData['is_completed'] = isCompleted;
        if (isCompleted) {
          updateData['completed_at'] = DateTime.now().toIso8601String();
        } else {
          updateData['completed_at'] = null;
        }
      }
      if (dueDate != null) updateData['due_date'] = dueDate.toIso8601String();
      if (priority != null) updateData['priority'] = priority;
      if (category != null) updateData['category'] = category;
      if (tags != null) updateData['tags'] = tags;
      if (location != null) updateData['location'] = location.toJson();

      final result = await _supabaseService.update(
        table: AppConstants.todosTable,
        data: updateData,
        column: 'id',
        value: todoId,
      );

      return TodoModel.fromJson(result.first);
    } catch (e) {
      debugPrint('Error updating todo: $e');
      rethrow;
    }
  }

  /// Toggle status completed todo
  Future<TodoModel> toggleTodoStatus(String todoId, bool isCompleted) async {
    try {
      final updateData = {
        'is_completed': isCompleted,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (isCompleted) {
        updateData['completed_at'] = DateTime.now().toIso8601String();
      } else {
        updateData.remove('completed_at');
      }

      final result = await _supabaseService.update(
        table: AppConstants.todosTable,
        data: updateData,
        column: 'id',
        value: todoId,
      );

      return TodoModel.fromJson(result.first);
    } catch (e) {
      debugPrint('Error toggling todo status: $e');
      rethrow;
    }
  }

  /// Hapus todo
  Future<void> deleteTodo(String todoId) async {
    try {
      await _supabaseService.delete(
        table: AppConstants.todosTable,
        column: 'id',
        value: todoId,
      );
    } catch (e) {
      debugPrint('Error deleting todo: $e');
      rethrow;
    }
  }

  /// Mendapatkan lokasi saat ini
  Future<LocationData?> getCurrentLocation() async {
    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen');
      }

      // Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? address;
      String? placeName;
      String? city;
      String? country;

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        address =
            '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}';
        placeName = placemark.name;
        city = placemark.locality;
        country = placemark.country;
      }

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        placeName: placeName,
        city: city,
        country: country,
      );
    } catch (e) {
      debugPrint('Error getting current location: $e');
      return null;
    }
  }

  /// Mendapatkan alamat dari koordinat
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        return '${placemark.street}, ${placemark.subLocality}, ${placemark.locality}';
      }

      return null;
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Mendapatkan koordinat dari alamat
  Future<LocationData?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final location = locations.first;
        return LocationData(
          latitude: location.latitude,
          longitude: location.longitude,
          address: address,
        );
      }

      return null;
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Mendapatkan statistik todos
  Future<Map<String, dynamic>> getTodoStatistics(String userId) async {
    try {
      final todos = await getUserTodos(userId);

      final totalTodos = todos.length;
      final completedTodos = todos.where((todo) => todo.isCompleted).length;
      final pendingTodos = totalTodos - completedTodos;
      final overdueTodos = todos.where((todo) => todo.isOverdue).length;
      final todayTodos = todos.where((todo) => todo.isDueToday).length;

      // Category breakdown
      final categoryBreakdown = <String, int>{};
      for (final todo in todos) {
        if (todo.category != null) {
          categoryBreakdown[todo.category!] =
              (categoryBreakdown[todo.category!] ?? 0) + 1;
        }
      }

      // Priority breakdown
      final priorityBreakdown = <String, int>{};
      for (final todo in todos) {
        priorityBreakdown[todo.priority] =
            (priorityBreakdown[todo.priority] ?? 0) + 1;
      }

      return {
        'total_todos': totalTodos,
        'completed_todos': completedTodos,
        'pending_todos': pendingTodos,
        'overdue_todos': overdueTodos,
        'today_todos': todayTodos,
        'completion_rate': totalTodos > 0
            ? (completedTodos / totalTodos * 100).round()
            : 0,
        'category_breakdown': categoryBreakdown,
        'priority_breakdown': priorityBreakdown,
      };
    } catch (e) {
      debugPrint('Error getting todo statistics: $e');
      rethrow;
    }
  }

  /// Mendapatkan todos dengan lokasi
  Future<List<TodoModel>> getTodosWithLocation(String userId) async {
    try {
      final todos = await getUserTodos(userId);
      return todos.where((todo) => todo.location != null).toList();
    } catch (e) {
      debugPrint('Error getting todos with location: $e');
      rethrow;
    }
  }

  /// Mencari todos
  Future<List<TodoModel>> searchTodos({
    required String userId,
    required String query,
  }) async {
    try {
      final todos = await getUserTodos(userId);

      return todos.where((todo) {
        final titleMatch = todo.title.toLowerCase().contains(
          query.toLowerCase(),
        );
        final descriptionMatch =
            todo.description?.toLowerCase().contains(query.toLowerCase()) ??
            false;
        final categoryMatch =
            todo.category?.toLowerCase().contains(query.toLowerCase()) ?? false;

        return titleMatch || descriptionMatch || categoryMatch;
      }).toList();
    } catch (e) {
      debugPrint('Error searching todos: $e');
      rethrow;
    }
  }
}
