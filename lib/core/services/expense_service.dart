import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/expense_model.dart';

/// Service untuk mengelola Expense dengan local storage
/// Author: Tamas dari TamsHub
///
/// Service ini menyediakan fungsi CRUD untuk Expense menggunakan SharedPreferences

class ExpenseService {
  static ExpenseService? _instance;
  static ExpenseService get instance => _instance ??= ExpenseService._();

  ExpenseService._();

  static const String _expenseStorageKey = 'local_expense_storage';

  /// Membuat expense baru
  Future<ExpenseModel> createExpense({
    required String title,
    required String description,
    required double amount,
    required String category,
    required String userId,
    DateTime? date,
    String? paymentMethod,
    double? latitude,
    double? longitude,
    String? locationName,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_expenseStorageKey) ?? '[]';
      final List<dynamic> expenseList = json.decode(existingData);

      final now = DateTime.now();
      final expense = ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        title: title,
        description: description,
        amount: amount,
        category: category,
        date: date ?? now,
        paymentMethod: paymentMethod ?? 'cash',
        latitude: latitude,
        longitude: longitude,
        locationName: locationName,
        receiptUrl: receiptUrl,
        metadata: metadata,
        createdAt: now,
        updatedAt: now,
      );

      expenseList.add(expense.toJson());
      await prefs.setString(_expenseStorageKey, json.encode(expenseList));

      return expense;
    } catch (e) {
      debugPrint('Error creating expense: $e');
      rethrow;
    }
  }

  /// Mendapatkan semua expenses user
  Future<List<ExpenseModel>> getUserExpenses(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_expenseStorageKey) ?? '[]';
      final List<dynamic> expenseList = json.decode(existingData);

      return expenseList
          .where((item) => item['user_id'] == userId)
          .map((item) => ExpenseModel.fromJson(Map<String, dynamic>.from(item)))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      debugPrint('Error getting user expenses: $e');
      return [];
    }
  }

  /// Update expense
  Future<ExpenseModel> updateExpense({
    required String expenseId,
    String? title,
    String? description,
    double? amount,
    String? category,
    DateTime? date,
    String? paymentMethod,
    double? latitude,
    double? longitude,
    String? locationName,
    String? receiptUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_expenseStorageKey) ?? '[]';
      final List<dynamic> expenseList = json.decode(existingData);

      final expenseIndex = expenseList.indexWhere(
        (item) => item['id'] == expenseId,
      );
      if (expenseIndex == -1) {
        throw Exception('Expense not found');
      }

      final expenseData = Map<String, dynamic>.from(expenseList[expenseIndex]);
      final expense = ExpenseModel.fromJson(expenseData);

      final updatedExpense = ExpenseModel(
        id: expense.id,
        userId: expense.userId,
        title: title ?? expense.title,
        description: description ?? expense.description,
        amount: amount ?? expense.amount,
        category: category ?? expense.category,
        date: date ?? expense.date,
        paymentMethod: paymentMethod ?? expense.paymentMethod,
        latitude: latitude ?? expense.latitude,
        longitude: longitude ?? expense.longitude,
        locationName: locationName ?? expense.locationName,
        receiptUrl: receiptUrl ?? expense.receiptUrl,
        metadata: metadata ?? expense.metadata,
        createdAt: expense.createdAt,
        updatedAt: DateTime.now(),
      );

      expenseList[expenseIndex] = updatedExpense.toJson();
      await prefs.setString(_expenseStorageKey, json.encode(expenseList));

      return updatedExpense;
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  /// Menghapus expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingData = prefs.getString(_expenseStorageKey) ?? '[]';
      final List<dynamic> expenseList = json.decode(existingData);

      expenseList.removeWhere((item) => item['id'] == expenseId);
      await prefs.setString(_expenseStorageKey, json.encode(expenseList));
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  /// Mendapatkan expenses berdasarkan kategori
  Future<List<ExpenseModel>> getExpensesByCategory(
    String userId,
    String category,
  ) async {
    try {
      final expenses = await getUserExpenses(userId);
      return expenses.where((expense) => expense.category == category).toList();
    } catch (e) {
      debugPrint('Error getting expenses by category: $e');
      return [];
    }
  }

  /// Mendapatkan expenses berdasarkan rentang tanggal
  Future<List<ExpenseModel>> getExpensesByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses = await getUserExpenses(userId);
      return expenses.where((expense) {
        return expense.date.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            expense.date.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      debugPrint('Error getting expenses by date range: $e');
      return [];
    }
  }

  /// Mendapatkan total pengeluaran user
  Future<double> getTotalExpenses(String userId) async {
    try {
      final expenses = await getUserExpenses(userId);
      return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
    } catch (e) {
      debugPrint('Error getting total expenses: $e');
      return 0.0;
    }
  }

  /// Mendapatkan total pengeluaran berdasarkan kategori
  Future<Map<String, double>> getExpensesByCategories(String userId) async {
    try {
      final expenses = await getUserExpenses(userId);
      final Map<String, double> categoryTotals = {};

      for (final expense in expenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0.0) + expense.amount;
      }

      return categoryTotals;
    } catch (e) {
      debugPrint('Error getting expenses by categories: $e');
      return {};
    }
  }

  /// Mendapatkan expenses bulan ini
  Future<List<ExpenseModel>> getThisMonthExpenses(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      return await getExpensesByDateRange(userId, startOfMonth, endOfMonth);
    } catch (e) {
      debugPrint('Error getting this month expenses: $e');
      return [];
    }
  }

  /// Mendapatkan expenses hari ini
  Future<List<ExpenseModel>> getTodayExpenses(String userId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      return await getExpensesByDateRange(userId, startOfDay, endOfDay);
    } catch (e) {
      debugPrint('Error getting today expenses: $e');
      return [];
    }
  }

  /// Mendapatkan statistik expenses
  Future<Map<String, dynamic>> getExpenseStats(String userId) async {
    try {
      final expenses = await getUserExpenses(userId);
      final thisMonthExpenses = await getThisMonthExpenses(userId);
      final todayExpenses = await getTodayExpenses(userId);
      final categoryTotals = await getExpensesByCategories(userId);

      return {
        'total_expenses': expenses.fold<double>(
          0.0,
          (sum, expense) => sum + expense.amount,
        ),
        'total_count': expenses.length,
        'this_month_total': thisMonthExpenses.fold<double>(
          0.0,
          (sum, expense) => sum + expense.amount,
        ),
        'this_month_count': thisMonthExpenses.length,
        'today_total': todayExpenses.fold<double>(
          0.0,
          (sum, expense) => sum + expense.amount,
        ),
        'today_count': todayExpenses.length,
        'category_totals': categoryTotals,
        'average_expense': expenses.isNotEmpty
            ? expenses.fold<double>(
                    0.0,
                    (sum, expense) => sum + expense.amount,
                  ) /
                  expenses.length
            : 0.0,
      };
    } catch (e) {
      debugPrint('Error getting expense stats: $e');
      return {
        'total_expenses': 0.0,
        'total_count': 0,
        'this_month_total': 0.0,
        'this_month_count': 0,
        'today_total': 0.0,
        'today_count': 0,
        'category_totals': <String, double>{},
        'average_expense': 0.0,
      };
    }
  }
}
