/// Model untuk Settings User
/// Author: Tamas dari TamsHub
/// 
/// Model ini merepresentasikan pengaturan aplikasi user

class SettingsModel {
  final String userId;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool autoBackup;
  final bool biometricEnabled;
  final String language;
  final String theme;
  final DateTime createdAt;
  final DateTime updatedAt;

  SettingsModel({
    required this.userId,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.autoBackup = true,
    this.biometricEnabled = false,
    this.language = 'Indonesia',
    this.theme = 'system',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'notifications_enabled': notificationsEnabled,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
      'auto_backup': autoBackup,
      'biometric_enabled': biometricEnabled,
      'language': language,
      'theme': theme,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from JSON
  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      userId: json['user_id'] as String,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      vibrationEnabled: json['vibration_enabled'] as bool? ?? true,
      autoBackup: json['auto_backup'] as bool? ?? true,
      biometricEnabled: json['biometric_enabled'] as bool? ?? false,
      language: json['language'] as String? ?? 'Indonesia',
      theme: json['theme'] as String? ?? 'system',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Copy with new values
  SettingsModel copyWith({
    String? userId,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? autoBackup,
    bool? biometricEnabled,
    String? language,
    String? theme,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettingsModel(
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      autoBackup: autoBackup ?? this.autoBackup,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create default settings for user
  factory SettingsModel.defaultSettings(String userId) {
    final now = DateTime.now();
    return SettingsModel(
      userId: userId,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  String toString() {
    return 'SettingsModel(userId: $userId, notifications: $notificationsEnabled, theme: $theme)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsModel && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
