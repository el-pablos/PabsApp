/// Models untuk Health Status monitoring
/// Author: Tamas dari TamsHub
/// 
/// Models ini merepresentasikan data status kesehatan sistem

class ApiStatus {
  final String name;
  final String endpoint;
  final bool isOnline;
  final int responseTime;
  final String status;
  final DateTime lastChecked;

  ApiStatus({
    required this.name,
    required this.endpoint,
    required this.isOnline,
    required this.responseTime,
    required this.status,
    required this.lastChecked,
  });

  factory ApiStatus.fromJson(Map<String, dynamic> json) {
    return ApiStatus(
      name: json['name'] as String,
      endpoint: json['endpoint'] as String,
      isOnline: json['isOnline'] as bool,
      responseTime: json['responseTime'] as int,
      status: json['status'] as String,
      lastChecked: DateTime.parse(json['lastChecked'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'endpoint': endpoint,
      'isOnline': isOnline,
      'responseTime': responseTime,
      'status': status,
      'lastChecked': lastChecked.toIso8601String(),
    };
  }
}

class WeatherInfo {
  final double temperature;
  final String description;
  final String location;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final DateTime lastUpdated;

  WeatherInfo({
    required this.temperature,
    required this.description,
    required this.location,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.lastUpdated,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    return WeatherInfo(
      temperature: (json['temperature'] as num).toDouble(),
      description: json['description'] as String,
      location: json['location'] as String,
      humidity: json['humidity'] as int,
      windSpeed: (json['windSpeed'] as num).toDouble(),
      pressure: json['pressure'] as int,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'description': description,
      'location': location,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'pressure': pressure,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class SystemInfo {
  final String platform;
  final String osVersion;
  final String deviceModel;
  final int availableMemory;
  final int freeStorage;
  final int cpuUsage;
  final int memoryUsage;
  final int batteryLevel;
  final int appUptime;

  SystemInfo({
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
    required this.availableMemory,
    required this.freeStorage,
    required this.cpuUsage,
    required this.memoryUsage,
    required this.batteryLevel,
    required this.appUptime,
  });

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      platform: json['platform'] as String,
      osVersion: json['osVersion'] as String,
      deviceModel: json['deviceModel'] as String,
      availableMemory: json['availableMemory'] as int,
      freeStorage: json['freeStorage'] as int,
      cpuUsage: json['cpuUsage'] as int,
      memoryUsage: json['memoryUsage'] as int,
      batteryLevel: json['batteryLevel'] as int,
      appUptime: json['appUptime'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform': platform,
      'osVersion': osVersion,
      'deviceModel': deviceModel,
      'availableMemory': availableMemory,
      'freeStorage': freeStorage,
      'cpuUsage': cpuUsage,
      'memoryUsage': memoryUsage,
      'batteryLevel': batteryLevel,
      'appUptime': appUptime,
    };
  }
}

class NetworkInfo {
  final bool isConnected;
  final String connectionType;
  final int? signalStrength;
  final String? ipAddress;
  final DateTime lastChecked;

  NetworkInfo({
    required this.isConnected,
    required this.connectionType,
    this.signalStrength,
    this.ipAddress,
    required this.lastChecked,
  });

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    return NetworkInfo(
      isConnected: json['isConnected'] as bool,
      connectionType: json['connectionType'] as String,
      signalStrength: json['signalStrength'] as int?,
      ipAddress: json['ipAddress'] as String?,
      lastChecked: DateTime.parse(json['lastChecked'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isConnected': isConnected,
      'connectionType': connectionType,
      'signalStrength': signalStrength,
      'ipAddress': ipAddress,
      'lastChecked': lastChecked.toIso8601String(),
    };
  }
}
