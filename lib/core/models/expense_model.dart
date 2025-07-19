/// Model untuk Expense
/// Author: Tamas dari TamsHub
/// 
/// Model ini merepresentasikan data expense dalam aplikasi FinTech

class ExpenseModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? receiptUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.latitude,
    this.longitude,
    this.locationName,
    this.receiptUrl,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'payment_method': paymentMethod,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'receipt_url': receiptUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['payment_method'] as String,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['location_name'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Copy with new values
  ExpenseModel copyWith({
    String? id,
    String? userId,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, title: $title, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
