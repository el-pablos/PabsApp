import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/location_model.dart';

/// Service untuk mengelola lokasi dan GPS
/// Author: Tamas dari TamsHub
///
/// Service ini mengelola operasi lokasi menggunakan device GPS
/// tanpa memerlukan Google Maps API, dengan fitur penyimpanan lokal

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static const String _locationsKey = 'saved_locations';

  /// Check dan request location permission
  Future<bool> checkLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Get current position
  Future<Position> getCurrentPosition() async {
    try {
      final hasPermission = await checkLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      throw Exception('Failed to get current position: $e');
    }
  }

  /// Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      // Using a free reverse geocoding service
      final url = 'https://api.bigdatacloud.net/data/reverse-geocode-client'
          '?latitude=$latitude&longitude=$longitude&localityLanguage=id';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'PabsApp/1.0'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Build address from components
        final components = <String>[];
        
        if (data['locality'] != null && data['locality'].toString().isNotEmpty) {
          components.add(data['locality'].toString());
        }
        if (data['city'] != null && data['city'].toString().isNotEmpty) {
          components.add(data['city'].toString());
        }
        if (data['principalSubdivision'] != null && data['principalSubdivision'].toString().isNotEmpty) {
          components.add(data['principalSubdivision'].toString());
        }
        if (data['countryName'] != null && data['countryName'].toString().isNotEmpty) {
          components.add(data['countryName'].toString());
        }
        
        return components.isNotEmpty ? components.join(', ') : null;
      }
      
      return null;
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Save location to local storage
  Future<void> saveLocation(LocationModel location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locations = await getSavedLocations();
      
      // Add new location
      locations.add(location);
      
      // Convert to JSON and save
      final locationsJson = locations.map((loc) => loc.toJson()).toList();
      await prefs.setString(_locationsKey, jsonEncode(locationsJson));
      
      debugPrint('Location saved successfully: ${location.name}');
    } catch (e) {
      debugPrint('Error saving location: $e');
      throw Exception('Failed to save location: $e');
    }
  }

  /// Get all saved locations
  Future<List<LocationModel>> getSavedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = prefs.getString(_locationsKey);
      
      if (locationsJson != null) {
        final locationsList = jsonDecode(locationsJson) as List;
        return locationsList
            .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error getting saved locations: $e');
      return [];
    }
  }

  /// Delete saved location
  Future<void> deleteLocation(String locationId) async {
    try {
      final locations = await getSavedLocations();
      locations.removeWhere((loc) => loc.id == locationId);
      
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = locations.map((loc) => loc.toJson()).toList();
      await prefs.setString(_locationsKey, jsonEncode(locationsJson));
      
      debugPrint('Location deleted successfully: $locationId');
    } catch (e) {
      debugPrint('Error deleting location: $e');
      throw Exception('Failed to delete location: $e');
    }
  }

  /// Update saved location
  Future<void> updateLocation(LocationModel location) async {
    try {
      final locations = await getSavedLocations();
      final index = locations.indexWhere((loc) => loc.id == location.id);
      
      if (index != -1) {
        locations[index] = location.copyWith(updatedAt: DateTime.now());
        
        final prefs = await SharedPreferences.getInstance();
        final locationsJson = locations.map((loc) => loc.toJson()).toList();
        await prefs.setString(_locationsKey, jsonEncode(locationsJson));
        
        debugPrint('Location updated successfully: ${location.name}');
      } else {
        throw Exception('Location not found');
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
      throw Exception('Failed to update location: $e');
    }
  }

  /// Get distance between two coordinates
  double getDistanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Get bearing between two coordinates
  double getBearingBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }

  /// Get location accuracy
  Future<LocationAccuracyStatus> getLocationAccuracy() async {
    try {
      return await Geolocator.getLocationAccuracy();
    } catch (e) {
      debugPrint('Error getting location accuracy: $e');
      return LocationAccuracyStatus.unknown;
    }
  }

  /// Watch position changes (stream)
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  /// Get last known position
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      debugPrint('Error getting last known position: $e');
      return null;
    }
  }

  /// Find nearby saved locations
  Future<List<LocationModel>> findNearbyLocations(
    double latitude,
    double longitude,
    double radiusInMeters,
  ) async {
    try {
      final allLocations = await getSavedLocations();
      final nearbyLocations = <LocationModel>[];
      
      for (final location in allLocations) {
        final distance = getDistanceBetween(
          latitude,
          longitude,
          location.latitude,
          location.longitude,
        );
        
        if (distance <= radiusInMeters) {
          nearbyLocations.add(location);
        }
      }
      
      // Sort by distance
      nearbyLocations.sort((a, b) {
        final distanceA = getDistanceBetween(latitude, longitude, a.latitude, a.longitude);
        final distanceB = getDistanceBetween(latitude, longitude, b.latitude, b.longitude);
        return distanceA.compareTo(distanceB);
      });
      
      return nearbyLocations;
    } catch (e) {
      debugPrint('Error finding nearby locations: $e');
      return [];
    }
  }

  /// Export locations to JSON
  Future<String> exportLocations() async {
    try {
      final locations = await getSavedLocations();
      final export = {
        'export_date': DateTime.now().toIso8601String(),
        'total_locations': locations.length,
        'locations': locations.map((loc) => loc.toJson()).toList(),
      };
      
      return jsonEncode(export);
    } catch (e) {
      debugPrint('Error exporting locations: $e');
      throw Exception('Failed to export locations: $e');
    }
  }

  /// Import locations from JSON
  Future<void> importLocations(String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      final locationsList = data['locations'] as List;
      
      final locations = locationsList
          .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Save imported locations
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = locations.map((loc) => loc.toJson()).toList();
      await prefs.setString(_locationsKey, jsonEncode(locationsJson));
      
      debugPrint('Locations imported successfully: ${locations.length} locations');
    } catch (e) {
      debugPrint('Error importing locations: $e');
      throw Exception('Failed to import locations: $e');
    }
  }

  /// Clear all saved locations
  Future<void> clearAllLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_locationsKey);
      
      debugPrint('All locations cleared successfully');
    } catch (e) {
      debugPrint('Error clearing locations: $e');
      throw Exception('Failed to clear locations: $e');
    }
  }
}
