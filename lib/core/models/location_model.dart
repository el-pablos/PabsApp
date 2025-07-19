/// Model untuk Location data
/// Author: Tamas dari TamsHub
/// 
/// Model ini merepresentasikan data lokasi yang disimpan user

class LocationModel {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LocationModel({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Copy with new values
  LocationModel copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get distance to another location in meters
  double distanceTo(LocationModel other) {
    // Simple distance calculation (not accurate for long distances)
    const double earthRadius = 6371000; // meters
    
    final lat1Rad = latitude * (3.14159265359 / 180);
    final lat2Rad = other.latitude * (3.14159265359 / 180);
    final deltaLatRad = (other.latitude - latitude) * (3.14159265359 / 180);
    final deltaLngRad = (other.longitude - longitude) * (3.14159265359 / 180);
    
    final a = (deltaLatRad / 2).sin() * (deltaLatRad / 2).sin() +
        lat1Rad.cos() * lat2Rad.cos() *
        (deltaLngRad / 2).sin() * (deltaLngRad / 2).sin();
    
    final c = 2 * (a.sqrt()).atan2((1 - a).sqrt());
    
    return earthRadius * c;
  }

  /// Get formatted coordinates string
  String get coordinatesString => '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  /// Get Google Maps URL
  String get googleMapsUrl => 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

  /// Get navigation URL for Google Maps app
  String get navigationUrl => 'google.navigation:q=$latitude,$longitude&mode=d';

  @override
  String toString() {
    return 'LocationModel(id: $id, name: $name, coordinates: $coordinatesString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
