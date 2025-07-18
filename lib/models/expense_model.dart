import 'package:json_annotation/json_annotation.dart';
import 'todo_model.dart'; // Import untuk LocationData

part 'expense_model.g.dart';

/// Model untuk data Expense (FinTech)
/// Author: Tamas dari TamsHub
///
/// Model ini merepresentasikan data pengeluaran dalam aplikasi PabsApp
/// dengan integrasi lokasi dan kategori pengeluaran.

@JsonSerializable()
class ExpenseModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final double amount;
  final String currency;
  final String category;
  final String? subcategory;
  final DateTime transactionDate;
  final String paymentMethod; // 'cash', 'card', 'transfer', 'ewallet'
  final LocationData? location;
  final String? receiptUrl;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final bool isRecurring;
  final String? recurringType; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime? nextRecurringDate;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.amount,
    this.currency = 'IDR',
    required this.category,
    this.subcategory,
    required this.transactionDate,
    this.paymentMethod = 'cash',
    this.location,
    this.receiptUrl,
    this.attachments,
    this.metadata,
    this.isRecurring = false,
    this.recurringType,
    this.nextRecurringDate,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor untuk membuat ExpenseModel dari JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$ExpenseModelFromJson(json);

  /// Method untuk mengkonversi ExpenseModel ke JSON
  Map<String, dynamic> toJson() => _$ExpenseModelToJson(this);

  /// Method untuk membuat copy ExpenseModel dengan perubahan tertentu
  ExpenseModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? amount,
    String? currency,
    String? category,
    String? subcategory,
    DateTime? transactionDate,
    String? paymentMethod,
    LocationData? location,
    String? receiptUrl,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    bool? isRecurring,
    String? recurringType,
    DateTime? nextRecurringDate,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      transactionDate: transactionDate ?? this.transactionDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      location: location ?? this.location,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      nextRecurringDate: nextRecurringDate ?? this.nextRecurringDate,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Method untuk mendapatkan kategori enum
  ExpenseCategory get categoryEnum {
    switch (category.toLowerCase()) {
      case 'makanan':
        return ExpenseCategory.food;
      case 'transportasi':
        return ExpenseCategory.transportation;
      case 'belanja':
        return ExpenseCategory.shopping;
      case 'hiburan':
        return ExpenseCategory.entertainment;
      case 'kesehatan':
        return ExpenseCategory.health;
      case 'pendidikan':
        return ExpenseCategory.education;
      default:
        return ExpenseCategory.others;
    }
  }

  /// Method untuk mendapatkan payment method enum
  PaymentMethod get paymentMethodEnum {
    switch (paymentMethod.toLowerCase()) {
      case 'card':
        return PaymentMethod.card;
      case 'transfer':
        return PaymentMethod.transfer;
      case 'ewallet':
        return PaymentMethod.ewallet;
      default:
        return PaymentMethod.cash;
    }
  }

  /// Method untuk mendapatkan warna berdasarkan kategori
  String get categoryColor {
    switch (categoryEnum) {
      case ExpenseCategory.food:
        return '#FF9800';
      case ExpenseCategory.transportation:
        return '#2196F3';
      case ExpenseCategory.shopping:
        return '#E91E63';
      case ExpenseCategory.entertainment:
        return '#9C27B0';
      case ExpenseCategory.health:
        return '#4CAF50';
      case ExpenseCategory.education:
        return '#3F51B5';
      case ExpenseCategory.others:
        return '#607D8B';
    }
  }

  /// Method untuk mendapatkan icon berdasarkan kategori
  String get categoryIcon {
    switch (categoryEnum) {
      case ExpenseCategory.food:
        return '🍽️';
      case ExpenseCategory.transportation:
        return '🚗';
      case ExpenseCategory.shopping:
        return '🛍️';
      case ExpenseCategory.entertainment:
        return '🎬';
      case ExpenseCategory.health:
        return '🏥';
      case ExpenseCategory.education:
        return '📚';
      case ExpenseCategory.others:
        return '📦';
    }
  }

  /// Method untuk format amount dengan currency
  String get formattedAmount {
    switch (currency) {
      case 'IDR':
        return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      default:
        return '$currency ${amount.toStringAsFixed(2)}';
    }
  }

  /// Method untuk mengecek apakah transaksi hari ini
  bool get isToday {
    final now = DateTime.now();
    return transactionDate.year == now.year &&
        transactionDate.month == now.month &&
        transactionDate.day == now.day;
  }

  /// Method untuk mengecek apakah transaksi minggu ini
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return transactionDate.isAfter(
          startOfWeek.subtract(const Duration(days: 1)),
        ) &&
        transactionDate.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Method untuk mengecek apakah transaksi bulan ini
  bool get isThisMonth {
    final now = DateTime.now();
    return transactionDate.year == now.year &&
        transactionDate.month == now.month;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExpenseModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.amount == amount &&
        other.currency == currency &&
        other.category == category &&
        other.transactionDate == transactionDate &&
        other.paymentMethod == paymentMethod &&
        other.location == location &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      title,
      amount,
      currency,
      category,
      transactionDate,
      paymentMethod,
      location,
      createdAt,
      updatedAt,
    );
  }

  String get categoryDisplayName {
    switch (category.toLowerCase()) {
      case 'food':
        return 'Makanan & Minuman';
      case 'transportation':
        return 'Transportasi';
      case 'shopping':
        return 'Belanja';
      case 'entertainment':
        return 'Hiburan';
      case 'health':
        return 'Kesehatan';
      case 'education':
        return 'Pendidikan';
      default:
        return 'Lainnya';
    }
  }

  String get paymentMethodDisplayName {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Tunai';
      case 'card':
        return 'Kartu';
      case 'transfer':
        return 'Transfer';
      case 'ewallet':
        return 'E-Wallet';
      default:
        return paymentMethod;
    }
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, title: $title, amount: $formattedAmount, category: $category)';
  }
}

/// Enum untuk kategori pengeluaran
enum ExpenseCategory {
  food,
  transportation,
  shopping,
  entertainment,
  health,
  education,
  others,
}

/// Enum untuk metode pembayaran
enum PaymentMethod { cash, card, transfer, ewallet }

/// Model untuk statistik pengeluaran
@JsonSerializable()
class ExpenseStatistics {
  final double totalAmount;
  final double averageAmount;
  final int totalTransactions;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> monthlyBreakdown;
  final String topCategory;
  final String topPaymentMethod;
  final DateTime periodStart;
  final DateTime periodEnd;

  const ExpenseStatistics({
    required this.totalAmount,
    required this.averageAmount,
    required this.totalTransactions,
    required this.categoryBreakdown,
    required this.monthlyBreakdown,
    required this.topCategory,
    required this.topPaymentMethod,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Factory constructor untuk membuat ExpenseStatistics dari JSON
  factory ExpenseStatistics.fromJson(Map<String, dynamic> json) =>
      _$ExpenseStatisticsFromJson(json);

  /// Method untuk mengkonversi ExpenseStatistics ke JSON
  Map<String, dynamic> toJson() => _$ExpenseStatisticsToJson(this);

  String get formattedTotalAmount {
    return 'Rp ${totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  String get formattedAverageAmount {
    return 'Rp ${averageAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  double get dailyAverage {
    final days = periodEnd.difference(periodStart).inDays + 1;
    return days > 0 ? totalAmount / days : 0;
  }

  String get formattedDailyAverage {
    return 'Rp ${dailyAverage.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  @override
  String toString() {
    return 'ExpenseStatistics(total: $totalAmount, transactions: $totalTransactions, topCategory: $topCategory)';
  }
}
