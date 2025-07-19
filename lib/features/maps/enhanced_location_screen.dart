import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../core/services/permission_service.dart';
import '../../core/services/location_service.dart';
import '../../core/models/location_model.dart';
import '../../core/widgets/loading_widget.dart';

/// Enhanced Location Screen tanpa Google Maps API
/// Author: Tamas dari TamsHub
///
/// Screen ini menyediakan fitur lokasi yang kreatif dan user-friendly
/// tanpa memerlukan Google Maps API, menggunakan GPS device dan
/// integrasi dengan aplikasi maps native.

class EnhancedLocationScreen extends StatefulWidget {
  const EnhancedLocationScreen({super.key});

  @override
  State<EnhancedLocationScreen> createState() => _EnhancedLocationScreenState();
}

class _EnhancedLocationScreenState extends State<EnhancedLocationScreen> {
  final LocationService _locationService = LocationService();
  
  bool _isLoading = false;
  Position? _currentPosition;
  List<LocationModel> _savedLocations = [];
  String? _currentAddress;
  
  @override
  void initState() {
    super.initState();
    _loadSavedLocations();
  }
  
  Future<void> _loadSavedLocations() async {
    try {
      final locations = await _locationService.getSavedLocations();
      setState(() => _savedLocations = locations);
    } catch (e) {
      debugPrint('Error loading saved locations: $e');
    }
  }
  
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    try {
      // Request location permission
      final hasPermission = await PermissionService.requestLocationPermission(context);
      if (!hasPermission) {
        throw Exception('Location permission denied');
      }
      
      // Get current position
      final position = await _locationService.getCurrentPosition();
      final address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      setState(() {
        _currentPosition = position;
        _currentAddress = address;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lokasi berhasil diperoleh')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _saveCurrentLocation() async {
    if (_currentPosition == null) return;
    
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simpan Lokasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lokasi',
                hintText: 'Contoh: Rumah, Kantor, Sekolah',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (Opsional)',
                hintText: 'Deskripsi tambahan',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    
    if (result == true && nameController.text.isNotEmpty) {
      try {
        final location = LocationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: nameController.text.trim(),
          description: descriptionController.text.trim(),
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          address: _currentAddress,
          createdAt: DateTime.now(),
        );
        
        await _locationService.saveLocation(location);
        await _loadSavedLocations();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lokasi berhasil disimpan')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving location: $e')),
          );
        }
      }
    }
  }
  
  Future<void> _openInMaps(double latitude, double longitude, {String? label}) async {
    try {
      // Try to open in Google Maps app first
      final googleMapsUrl = 'google.navigation:q=$latitude,$longitude&mode=d';
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
        return;
      }
      
      // Fallback to web Google Maps
      final webUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      if (await canLaunchUrl(Uri.parse(webUrl))) {
        await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
        return;
      }
      
      throw Exception('No maps application available');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening maps: $e')),
        );
      }
    }
  }
  
  Future<void> _shareLocation(double latitude, double longitude, String name) async {
    try {
      final shareText = 'Lokasi: $name\n'
          'Koordinat: $latitude, $longitude\n'
          'Google Maps: https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      
      // In a real app, you would use share_plus package
      // For now, we'll copy to clipboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location info: $shareText'),
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing location: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Location'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _getCurrentLocation,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.my_location),
            tooltip: 'Get Current Location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Location Card
          if (_currentPosition != null) _buildCurrentLocationCard(),
          
          // Action Buttons
          if (_currentPosition != null) _buildActionButtons(),
          
          // Saved Locations List
          Expanded(child: _buildSavedLocationsList()),
        ],
      ),
      floatingActionButton: _currentPosition != null
          ? FloatingActionButton(
              onPressed: _saveCurrentLocation,
              child: const Icon(Icons.bookmark_add),
              tooltip: 'Save Current Location',
            )
          : null,
    );
  }
  
  Widget _buildCurrentLocationCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Lokasi Saat Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Koordinat: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            if (_currentAddress != null) ...[
              const SizedBox(height: 8),
              Text(
                'Alamat: $_currentAddress',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Akurasi: ${_currentPosition!.accuracy.toStringAsFixed(1)} meter',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              'Waktu: ${DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(_currentPosition!.timestamp!))}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _openInMaps(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              ),
              icon: const Icon(Icons.map),
              label: const Text('Buka di Maps'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _shareLocation(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
                'Lokasi Saat Ini',
              ),
              icon: const Icon(Icons.share),
              label: const Text('Bagikan'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSavedLocationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Lokasi Tersimpan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: _savedLocations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada lokasi tersimpan',
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Dapatkan lokasi saat ini dan simpan',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _savedLocations.length,
                  itemBuilder: (context, index) {
                    final location = _savedLocations[index];
                    return _buildLocationTile(location);
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildLocationTile(LocationModel location) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(
            Icons.place,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (location.description?.isNotEmpty == true)
              Text(location.description!),
            const SizedBox(height: 4),
            Text(
              '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            if (location.address != null)
              Text(
                location.address!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'navigate':
                await _openInMaps(location.latitude, location.longitude, label: location.name);
                break;
              case 'share':
                await _shareLocation(location.latitude, location.longitude, location.name);
                break;
              case 'delete':
                await _deleteLocation(location);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'navigate',
              child: Row(
                children: [
                  Icon(Icons.navigation),
                  SizedBox(width: 8),
                  Text('Navigate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
  
  Future<void> _deleteLocation(LocationModel location) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Lokasi'),
        content: Text('Apakah Anda yakin ingin menghapus lokasi "${location.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    
    if (result == true) {
      try {
        await _locationService.deleteLocation(location.id);
        await _loadSavedLocations();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lokasi berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting location: $e')),
          );
        }
      }
    }
  }
}
