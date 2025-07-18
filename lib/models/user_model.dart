import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Model untuk data User
/// Author: Tamas dari TamsHub
/// 
/// Model ini merepresentasikan data user dalam aplikasi PabsApp
/// dengan semua informasi yang diperlukan untuk profil dan autentikasi.

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? address;
  final String? city;
  final String? province;
  final String? country;
  final String? occupation;
  final String? bio;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.address,
    this.city,
    this.province,
    this.country,
    this.occupation,
    this.bio,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isVerified = false,
  });

  /// Factory constructor untuk membuat UserModel dari JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// Method untuk mengkonversi UserModel ke JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  /// Method untuk membuat copy UserModel dengan perubahan tertentu
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? province,
    String? country,
    String? occupation,
    String? bio,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      province: province ?? this.province,
      country: country ?? this.country,
      occupation: occupation ?? this.occupation,
      bio: bio ?? this.bio,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  /// Method untuk mendapatkan nama tampilan
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    return email.split('@').first;
  }

  /// Method untuk mendapatkan inisial nama
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final names = fullName!.split(' ');
      if (names.length >= 2) {
        return '${names.first[0]}${names.last[0]}'.toUpperCase();
      }
      return fullName![0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// Method untuk mengecek apakah profil lengkap
  bool get isProfileComplete {
    return fullName != null &&
        fullName!.isNotEmpty &&
        phoneNumber != null &&
        phoneNumber!.isNotEmpty &&
        address != null &&
        address!.isNotEmpty;
  }

  /// Method untuk mendapatkan alamat lengkap
  String get fullAddress {
    final addressParts = <String>[];
    
    if (address != null && address!.isNotEmpty) {
      addressParts.add(address!);
    }
    if (city != null && city!.isNotEmpty) {
      addressParts.add(city!);
    }
    if (province != null && province!.isNotEmpty) {
      addressParts.add(province!);
    }
    if (country != null && country!.isNotEmpty) {
      addressParts.add(country!);
    }
    
    return addressParts.join(', ');
  }

  /// Method untuk mendapatkan umur
  int? get age {
    if (dateOfBirth == null) return null;
    
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    
    return age;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.avatarUrl == avatarUrl &&
        other.phoneNumber == phoneNumber &&
        other.dateOfBirth == dateOfBirth &&
        other.address == address &&
        other.city == city &&
        other.province == province &&
        other.country == country &&
        other.occupation == occupation &&
        other.bio == bio &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isActive == isActive &&
        other.isVerified == isVerified;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      fullName,
      avatarUrl,
      phoneNumber,
      dateOfBirth,
      address,
      city,
      province,
      country,
      occupation,
      bio,
      createdAt,
      updatedAt,
      isActive,
      isVerified,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, isActive: $isActive, isVerified: $isVerified)';
  }
}
