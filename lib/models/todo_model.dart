import 'package:json_annotation/json_annotation.dart';

part 'todo_model.g.dart';

/// Model untuk data Todo
/// Author: Tamas dari TamsHub
/// 
/// Model ini merepresentasikan data todo dalam aplikasi PabsApp
/// dengan integrasi lokasi dan fitur-fitur lainnya.

@JsonSerializable()
class TodoModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime? dueDate;
  final String priority; // 'low', 'medium', 'high'
  final String? category;
  final List<String>? tags;
  final LocationData? location;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.priority = 'medium',
    this.category,
    this.tags,
    this.location,
    this.attachments,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  /// Factory constructor untuk membuat TodoModel dari JSON
  factory TodoModel.fromJson(Map<String, dynamic> json) => _$TodoModelFromJson(json);

  /// Method untuk mengkonversi TodoModel ke JSON
  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  /// Method untuk membuat copy TodoModel dengan perubahan tertentu
  TodoModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    String? priority,
    String? category,
    List<String>? tags,
    LocationData? location,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Method untuk mengecek apakah todo sudah terlambat
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  /// Method untuk mengecek apakah todo akan jatuh tempo hari ini
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Method untuk mendapatkan status prioritas
  TodoPriority get priorityEnum {
    switch (priority.toLowerCase()) {
      case 'high':
        return TodoPriority.high;
      case 'low':
        return TodoPriority.low;
      default:
        return TodoPriority.medium;
    }
  }

  /// Method untuk mendapatkan warna berdasarkan prioritas
  String get priorityColor {
    switch (priorityEnum) {
      case TodoPriority.high:
        return '#FF5252';
      case TodoPriority.medium:
        return '#FF9800';
      case TodoPriority.low:
        return '#4CAF50';
    }
  }

  /// Method untuk mendapatkan durasi sejak dibuat
  Duration get timeSinceCreated {
    return DateTime.now().difference(createdAt);
  }

  /// Method untuk mendapatkan durasi hingga due date
  Duration? get timeUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TodoModel &&
        other.id == id &&
        other.userId == userId &&
        other.title == title &&
        other.description == description &&
        other.isCompleted == isCompleted &&
        other.dueDate == dueDate &&
        other.priority == priority &&
        other.category == category &&
        other.location == location &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.completedAt == completedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      title,
      description,
      isCompleted,
      dueDate,
      priority,
      category,
      location,
      createdAt,
      updatedAt,
      completedAt,
    );
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }
}

/// Enum untuk prioritas todo
enum TodoPriority {
  low,
  medium,
  high,
}

/// Model untuk data lokasi
@JsonSerializable()
class LocationData {
  final double latitude;
  final double longitude;
  final String? address;
  final String? placeName;
  final String? city;
  final String? country;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
    this.placeName,
    this.city,
    this.country,
  });

  /// Factory constructor untuk membuat LocationData dari JSON
  factory LocationData.fromJson(Map<String, dynamic> json) => _$LocationDataFromJson(json);

  /// Method untuk mengkonversi LocationData ke JSON
  Map<String, dynamic> toJson() => _$LocationDataToJson(this);

  /// Method untuk membuat copy LocationData dengan perubahan tertentu
  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? placeName,
    String? city,
    String? country,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      placeName: placeName ?? this.placeName,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }

  /// Method untuk mendapatkan alamat lengkap
  String get fullAddress {
    final addressParts = <String>[];
    
    if (placeName != null && placeName!.isNotEmpty) {
      addressParts.add(placeName!);
    }
    if (address != null && address!.isNotEmpty) {
      addressParts.add(address!);
    }
    if (city != null && city!.isNotEmpty) {
      addressParts.add(city!);
    }
    if (country != null && country!.isNotEmpty) {
      addressParts.add(country!);
    }
    
    return addressParts.join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address &&
        other.placeName == placeName &&
        other.city == city &&
        other.country == country;
  }

  @override
  int get hashCode {
    return Object.hash(
      latitude,
      longitude,
      address,
      placeName,
      city,
      country,
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, address: $address)';
  }
}
