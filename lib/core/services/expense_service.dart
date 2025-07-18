import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../constants/app_constants.dart';
import '../../models/expense_model.dart';
import '../../models/todo_model.dart'; // For LocationData
import 'supabase_service.dart';

/// Service untuk mengelola Expense (FinTech)
/// Author: Tamas dari TamsHub
///
/// Service ini menyediakan fungsi-fungsi untuk mengelola pengeluaran
/// dengan integrasi lokasi dan Google Maps.

class ExpenseService {
  static ExpenseService? _instance;
  static ExpenseService get instance => _instance ??= ExpenseService._();

  ExpenseService._();

  final SupabaseService _supabaseService = SupabaseService.instance;

  /// Membuat expense baru
  Future<ExpenseModel> createExpense({
    required String userId,
    required String title,
    String? description,
    required double amount,
    String currency = 'IDR',
    required String category,
    String? subcategory,
    DateTime? transactionDate,
    String paymentMethod = 'cash',
    bool includeCurrentLocation = false,
    List<String>? tags,
    bool isRecurring = false,
    String? recurringType,
  }) async {
    try {
      final now = DateTime.now();
      LocationData? location;

      // Get current location if requested
      if (includeCurrentLocation) {
        location = await getCurrentLocation();
      }

      final expenseData = {
        'user_id': userId,
        'title': title,
        'description': description,
        'amount': amount,
        'currency': currency,
        'category': category,
        'subcategory': subcategory,
        'transaction_date': (transactionDate ?? now).toIso8601String(),
        'payment_method': paymentMethod,
        'location': location?.toJson(),
        'tags': tags,
        'is_recurring': isRecurring,
        'recurring_type': recurringType,
        'next_recurring_date': isRecurring && recurringType != null
            ? _calculateNextRecurringDate(
                transactionDate ?? now,
                recurringType,
              ).toIso8601String()
            : null,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final result = await _supabaseService.insert(
        table: AppConstants.expensesTable,
        data: expenseData,
      );

      return ExpenseModel.fromJson(result.first);
    } catch (e) {
      debugPrint('Error creating expense: $e');
      rethrow;
    }
  }

  /// Mendapatkan semua expenses user
  Future<List<ExpenseModel>> getUserExpenses(String userId) async {
    try {
      final result = await _supabaseService.select(
        table: AppConstants.expensesTable,
        filters: {'user_id': userId},
        orderBy: 'transaction_date',
        ascending: false,
      );

      return result.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting user expenses: $e');
      rethrow;
    }
  }

  /// Mendapatkan expenses berdasarkan kategori
  Future<List<ExpenseModel>> getExpensesByCategory({
    required String userId,
    required String category,
  }) async {
    try {
      final result = await _supabaseService.select(
        table: AppConstants.expensesTable,
        filters: {'user_id': userId, 'category': category},
        orderBy: 'transaction_date',
        ascending: false,
      );

      return result.map((json) => ExpenseModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting expenses by category: $e');
      rethrow;
    }
  }

  /// Mendapatkan expenses berdasarkan rentang tanggal
  Future<List<ExpenseModel>> getExpensesByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final expenses = await getUserExpenses(userId);

      return expenses.where((expense) {
        return expense.transactionDate.isAfter(
              startDate.subtract(const Duration(days: 1)),
            ) &&
            expense.transactionDate.isBefore(
              endDate.add(const Duration(days: 1)),
            );
      }).toList();
    } catch (e) {
      debugPrint('Error getting expenses by date range: $e');
      rethrow;
    }
  }

  /// Mendapatkan expenses hari ini
  Future<List<ExpenseModel>> getTodayExpenses(String userId) async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      return await getExpensesByDateRange(
        userId: userId,
        startDate: startOfDay,
        endDate: endOfDay,
      );
    } catch (e) {
      debugPrint('Error getting today expenses: $e');
      rethrow;
    }
  }

  /// Mendapatkan expenses bulan ini
  Future<List<ExpenseModel>> getThisMonthExpenses(String userId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      return await getExpensesByDateRange(
        userId: userId,
        startDate: startOfMonth,
        endDate: endOfMonth,
      );
    } catch (e) {
      debugPrint('Error getting this month expenses: $e');
      rethrow;
    }
  }

  /// Update expense
  Future<ExpenseModel> updateExpense({
    required String expenseId,
    String? title,
    String? description,
    double? amount,
    String? currency,
    String? category,
    String? subcategory,
    DateTime? transactionDate,
    String? paymentMethod,
    LocationData? location,
    List<String>? tags,
    bool? isRecurring,
    String? recurringType,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (amount != null) updateData['amount'] = amount;
      if (currency != null) updateData['currency'] = currency;
      if (category != null) updateData['category'] = category;
      if (subcategory != null) updateData['subcategory'] = subcategory;
      if (transactionDate != null) {
        updateData['transaction_date'] = transactionDate.toIso8601String();
      }
      if (paymentMethod != null) updateData['payment_method'] = paymentMethod;
      if (location != null) updateData['location'] = location.toJson();
      if (tags != null) updateData['tags'] = tags;
      if (isRecurring != null) {
        updateData['is_recurring'] = isRecurring;
        if (isRecurring && recurringType != null && transactionDate != null) {
          updateData['next_recurring_date'] = _calculateNextRecurringDate(
            transactionDate,
            recurringType,
          ).toIso8601String();
        }
      }
      if (recurringType != null) updateData['recurring_type'] = recurringType;

      final result = await _supabaseService.update(
        table: AppConstants.expensesTable,
        data: updateData,
        column: 'id',
        value: expenseId,
      );

      return ExpenseModel.fromJson(result.first);
    } catch (e) {
      debugPrint('Error updating expense: $e');
      rethrow;
    }
  }

  /// Hapus expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _supabaseService.delete(
        table: AppConstants.expensesTable,
        column: 'id',
        value: expenseId,
      );
    } catch (e) {
      debugPrint('Error deleting expense: $e');
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

  /// Mendapatkan statistik expenses
  Future<ExpenseStatistics> getExpenseStatistics({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<ExpenseModel> expenses;

      if (startDate != null && endDate != null) {
        expenses = await getExpensesByDateRange(
          userId: userId,
          startDate: startDate,
          endDate: endDate,
        );
      } else {
        expenses = await getUserExpenses(userId);
      }

      final totalAmount = expenses.fold<double>(
        0,
        (sum, expense) => sum + expense.amount,
      );
      final averageAmount = expenses.isNotEmpty
          ? totalAmount / expenses.length
          : 0.0;
      final totalTransactions = expenses.length;

      // Category breakdown
      final categoryBreakdown = <String, double>{};
      for (final expense in expenses) {
        categoryBreakdown[expense.category] =
            (categoryBreakdown[expense.category] ?? 0) + expense.amount;
      }

      // Monthly breakdown
      final monthlyBreakdown = <String, double>{};
      for (final expense in expenses) {
        final monthKey =
            '${expense.transactionDate.year}-${expense.transactionDate.month.toString().padLeft(2, '0')}';
        monthlyBreakdown[monthKey] =
            (monthlyBreakdown[monthKey] ?? 0) + expense.amount;
      }

      // Top category and payment method
      String topCategory = '';
      String topPaymentMethod = '';

      if (categoryBreakdown.isNotEmpty) {
        topCategory = categoryBreakdown.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      final paymentMethodCount = <String, int>{};
      for (final expense in expenses) {
        paymentMethodCount[expense.paymentMethod] =
            (paymentMethodCount[expense.paymentMethod] ?? 0) + 1;
      }

      if (paymentMethodCount.isNotEmpty) {
        topPaymentMethod = paymentMethodCount.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
      }

      return ExpenseStatistics(
        totalAmount: totalAmount,
        averageAmount: averageAmount,
        totalTransactions: totalTransactions,
        categoryBreakdown: categoryBreakdown,
        monthlyBreakdown: monthlyBreakdown,
        topCategory: topCategory,
        topPaymentMethod: topPaymentMethod,
        periodStart:
            startDate ??
            (expenses.isNotEmpty
                ? expenses.last.transactionDate
                : DateTime.now()),
        periodEnd:
            endDate ??
            (expenses.isNotEmpty
                ? expenses.first.transactionDate
                : DateTime.now()),
      );
    } catch (e) {
      debugPrint('Error getting expense statistics: $e');
      rethrow;
    }
  }

  /// Mendapatkan expenses dengan lokasi
  Future<List<ExpenseModel>> getExpensesWithLocation(String userId) async {
    try {
      final expenses = await getUserExpenses(userId);
      return expenses.where((expense) => expense.location != null).toList();
    } catch (e) {
      debugPrint('Error getting expenses with location: $e');
      rethrow;
    }
  }

  /// Mencari expenses
  Future<List<ExpenseModel>> searchExpenses({
    required String userId,
    required String query,
  }) async {
    try {
      final expenses = await getUserExpenses(userId);

      return expenses.where((expense) {
        final titleMatch = expense.title.toLowerCase().contains(
          query.toLowerCase(),
        );
        final descriptionMatch =
            expense.description?.toLowerCase().contains(query.toLowerCase()) ??
            false;
        final categoryMatch = expense.category.toLowerCase().contains(
          query.toLowerCase(),
        );

        return titleMatch || descriptionMatch || categoryMatch;
      }).toList();
    } catch (e) {
      debugPrint('Error searching expenses: $e');
      rethrow;
    }
  }

  /// Calculate next recurring date
  DateTime _calculateNextRecurringDate(
    DateTime currentDate,
    String recurringType,
  ) {
    switch (recurringType.toLowerCase()) {
      case 'daily':
        return currentDate.add(const Duration(days: 1));
      case 'weekly':
        return currentDate.add(const Duration(days: 7));
      case 'monthly':
        return DateTime(
          currentDate.year,
          currentDate.month + 1,
          currentDate.day,
        );
      case 'yearly':
        return DateTime(
          currentDate.year + 1,
          currentDate.month,
          currentDate.day,
        );
      default:
        return currentDate.add(const Duration(days: 30));
    }
  }

  /// Get expense categories
  List<String> getExpenseCategories() {
    return AppConstants.expenseCategories;
  }

  /// Get payment methods
  List<String> getPaymentMethods() {
    return ['cash', 'card', 'transfer', 'ewallet'];
  }

  /// Get payment method labels
  Map<String, String> getPaymentMethodLabels() {
    return {
      'cash': 'Tunai',
      'card': 'Kartu',
      'transfer': 'Transfer',
      'ewallet': 'E-Wallet',
    };
  }
}
