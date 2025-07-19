import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo_model.dart';

/// Service untuk mengelola TodoList dengan local storage
/// Author: Tamas dari TamsHub
/// 
/// Service ini menyediakan fungsi CRUD untuk TodoList menggunakan SharedPreferences

class TodoService {
  static TodoService? _instance;
  static TodoService get instance => _instance ??= TodoService._();

  TodoService._();

  static const String _todoStorageKey = 'local_todo_storage';

  /// Membuat todo baru
  Future<TodoModel> createTodo({
    required String title,
    required String description,
    required String userId,
    String? category,
    DateTime? dueDate,
    String? priority,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_todoStorageKey) ?? '[]';
      final List<dynamic> todoList = json.decode(existingData);
      
      final now = DateTime.now();
      final todo = TodoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        description: description,
        category: category ?? 'general',
        isCompleted: false,
        priority: priority ?? 'medium',
        dueDate: dueDate,
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        createdAt: now,
        updatedAt: now,
      );
      
      todoList.add(todo.toJson());
      await prefs.setString(_todoStorageKey, json.encode(todoList));
      
      return todo;
    } catch (e) {
      debugPrint('Error creating todo: $e');
      rethrow;
    }
  }

  /// Mendapatkan semua todos user
  Future<List<TodoModel>> getUserTodos(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_todoStorageKey) ?? '[]';
      final List<dynamic> todoList = json.decode(existingData);
      
      return todoList
          .where((item) => item['user_id'] == userId)
          .map((item) => TodoModel.fromJson(Map<String, dynamic>.from(item)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error getting user todos: $e');
      return [];
    }
  }

  /// Update todo
  Future<TodoModel> updateTodo({
    required String todoId,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
    String? priority,
    DateTime? dueDate,
    double? latitude,
    double? longitude,
    String? locationName,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_todoStorageKey) ?? '[]';
      final List<dynamic> todoList = json.decode(existingData);
      
      final todoIndex = todoList.indexWhere((item) => item['id'] == todoId);
      if (todoIndex == -1) {
        throw Exception('Todo not found');
      }
      
      final todoData = Map<String, dynamic>.from(todoList[todoIndex]);
      final todo = TodoModel.fromJson(todoData);
      
      final updatedTodo = TodoModel(
        id: todo.id,
        userId: todo.userId,
        title: title ?? todo.title,
        description: description ?? todo.description,
        category: category ?? todo.category,
        isCompleted: isCompleted ?? todo.isCompleted,
        priority: priority ?? todo.priority,
        dueDate: dueDate ?? todo.dueDate,
        latitude: latitude ?? todo.latitude,
        longitude: longitude ?? todo.longitude,
        locationName: locationName ?? todo.locationName,
        createdAt: todo.createdAt,
        updatedAt: DateTime.now(),
      );
      
      todoList[todoIndex] = updatedTodo.toJson();
      await prefs.setString(_todoStorageKey, json.encode(todoList));
      
      return updatedTodo;
    } catch (e) {
      debugPrint('Error updating todo: $e');
      rethrow;
    }
  }

  /// Menghapus todo
  Future<void> deleteTodo(String todoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_todoStorageKey) ?? '[]';
      final List<dynamic> todoList = json.decode(existingData);
      
      todoList.removeWhere((item) => item['id'] == todoId);
      await prefs.setString(_todoStorageKey, json.encode(todoList));
    } catch (e) {
      debugPrint('Error deleting todo: $e');
      rethrow;
    }
  }

  /// Toggle status completed todo
  Future<TodoModel> toggleTodoStatus(String todoId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_todoStorageKey) ?? '[]';
      final List<dynamic> todoList = json.decode(existingData);
      
      final todoIndex = todoList.indexWhere((item) => item['id'] == todoId);
      if (todoIndex == -1) {
        throw Exception('Todo not found');
      }
      
      final todoData = Map<String, dynamic>.from(todoList[todoIndex]);
      final todo = TodoModel.fromJson(todoData);
      
      final updatedTodo = TodoModel(
        id: todo.id,
        userId: todo.userId,
        title: todo.title,
        description: todo.description,
        category: todo.category,
        isCompleted: !todo.isCompleted,
        priority: todo.priority,
        dueDate: todo.dueDate,
        latitude: todo.latitude,
        longitude: todo.longitude,
        locationName: todo.locationName,
        createdAt: todo.createdAt,
        updatedAt: DateTime.now(),
      );
      
      todoList[todoIndex] = updatedTodo.toJson();
      await prefs.setString(_todoStorageKey, json.encode(todoList));
      
      return updatedTodo;
    } catch (e) {
      debugPrint('Error toggling todo status: $e');
      rethrow;
    }
  }

  /// Mendapatkan todos berdasarkan kategori
  Future<List<TodoModel>> getTodosByCategory(String userId, String category) async {
    try {
      final todos = await getUserTodos(userId);
      return todos.where((todo) => todo.category == category).toList();
    } catch (e) {
      debugPrint('Error getting todos by category: $e');
      return [];
    }
  }

  /// Mendapatkan todos yang belum selesai
  Future<List<TodoModel>> getPendingTodos(String userId) async {
    try {
      final todos = await getUserTodos(userId);
      return todos.where((todo) => !todo.isCompleted).toList();
    } catch (e) {
      debugPrint('Error getting pending todos: $e');
      return [];
    }
  }

  /// Mendapatkan todos yang sudah selesai
  Future<List<TodoModel>> getCompletedTodos(String userId) async {
    try {
      final todos = await getUserTodos(userId);
      return todos.where((todo) => todo.isCompleted).toList();
    } catch (e) {
      debugPrint('Error getting completed todos: $e');
      return [];
    }
  }

  /// Mendapatkan todos berdasarkan prioritas
  Future<List<TodoModel>> getTodosByPriority(String userId, String priority) async {
    try {
      final todos = await getUserTodos(userId);
      return todos.where((todo) => todo.priority == priority).toList();
    } catch (e) {
      debugPrint('Error getting todos by priority: $e');
      return [];
    }
  }

  /// Mendapatkan todos yang memiliki due date hari ini
  Future<List<TodoModel>> getTodayTodos(String userId) async {
    try {
      final todos = await getUserTodos(userId);
      final today = DateTime.now();
      
      return todos.where((todo) {
        if (todo.dueDate == null) return false;
        return todo.dueDate!.year == today.year &&
               todo.dueDate!.month == today.month &&
               todo.dueDate!.day == today.day;
      }).toList();
    } catch (e) {
      debugPrint('Error getting today todos: $e');
      return [];
    }
  }

  /// Mendapatkan todos yang overdue
  Future<List<TodoModel>> getOverdueTodos(String userId) async {
    try {
      final todos = await getUserTodos(userId);
      final now = DateTime.now();
      
      return todos.where((todo) {
        if (todo.dueDate == null || todo.isCompleted) return false;
        return todo.dueDate!.isBefore(now);
      }).toList();
    } catch (e) {
      debugPrint('Error getting overdue todos: $e');
      return [];
    }
  }

  /// Mendapatkan statistik todos
  Future<Map<String, int>> getTodoStats(String userId) async {
    try {
      final todos = await getUserTodos(userId);
      
      return {
        'total': todos.length,
        'completed': todos.where((todo) => todo.isCompleted).length,
        'pending': todos.where((todo) => !todo.isCompleted).length,
        'overdue': (await getOverdueTodos(userId)).length,
        'today': (await getTodayTodos(userId)).length,
      };
    } catch (e) {
      debugPrint('Error getting todo stats: $e');
      return {
        'total': 0,
        'completed': 0,
        'pending': 0,
        'overdue': 0,
        'today': 0,
      };
    }
  }
}
