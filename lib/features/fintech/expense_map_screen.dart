import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/expense_model.dart';

/// Screen untuk menampilkan expense dengan lokasi di Google Maps
/// Author: Tamas dari TamsHub
/// 
/// Screen ini menampilkan semua expense yang memiliki lokasi dalam
/// bentuk marker di Google Maps dengan info window.

class ExpenseMapScreen extends StatefulWidget {
  final List<ExpenseModel> expenses;

  const ExpenseMapScreen({
    super.key,
    required this.expenses,
  });

  @override
  State<ExpenseMapScreen> createState() => _ExpenseMapScreenState();
}

class _ExpenseMapScreenState extends State<ExpenseMapScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  // Default location (Jakarta)
  static const LatLng _defaultLocation = LatLng(-6.2088, 106.8456);

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    final expensesWithLocation = widget.expenses.where((expense) => expense.location != null).toList();
    
    _markers = expensesWithLocation.map((expense) {
      return Marker(
        markerId: MarkerId(expense.id),
        position: LatLng(
          expense.location!.latitude,
          expense.location!.longitude,
        ),
        infoWindow: InfoWindow(
          title: expense.title,
          snippet: '${expense.formattedAmount} - ${expense.categoryDisplayName}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerHue(expense.category),
        ),
        onTap: () => _showExpenseDetails(expense),
      );
    }).toSet();
  }

  double _getMarkerHue(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return BitmapDescriptor.hueOrange;
      case 'transportation':
        return BitmapDescriptor.hueBlue;
      case 'shopping':
        return BitmapDescriptor.hueMagenta;
      case 'entertainment':
        return BitmapDescriptor.hueViolet;
      case 'health':
        return BitmapDescriptor.hueGreen;
      case 'education':
        return BitmapDescriptor.hueAzure;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesWithLocation = widget.expenses.where((expense) => expense.location != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Peta Pengeluaran (${expensesWithLocation.length})'),
        actions: [
          IconButton(
            onPressed: _showMapLegend,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Legenda',
          ),
        ],
      ),
      body: expensesWithLocation.isEmpty
          ? _buildEmptyState()
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: expensesWithLocation.isNotEmpty
                    ? LatLng(
                        expensesWithLocation.first.location!.latitude,
                        expensesWithLocation.first.location!.longitude,
                      )
                    : _defaultLocation,
                zoom: 12,
              ),
              markers: _markers,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
                _fitMarkersInView();
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: false,
            ),
      floatingActionButton: expensesWithLocation.isNotEmpty
          ? FloatingActionButton(
              onPressed: _fitMarkersInView,
              child: const Icon(Icons.center_focus_strong),
              tooltip: 'Tampilkan Semua',
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada pengeluaran dengan lokasi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan lokasi saat membuat pengeluaran untuk melihatnya di peta',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _fitMarkersInView() {
    if (_mapController == null || _markers.isEmpty) return;

    final bounds = _calculateBounds(_markers);
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }

  LatLngBounds _calculateBounds(Set<Marker> markers) {
    double minLat = markers.first.position.latitude;
    double maxLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLng = markers.first.position.longitude;

    for (final marker in markers) {
      minLat = minLat < marker.position.latitude ? minLat : marker.position.latitude;
      maxLat = maxLat > marker.position.latitude ? maxLat : marker.position.latitude;
      minLng = minLng < marker.position.longitude ? minLng : marker.position.longitude;
      maxLng = maxLng > marker.position.longitude ? maxLng : marker.position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _showExpenseDetails(ExpenseModel expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title and amount
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(expense.category).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            expense.categoryIcon,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.title,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              expense.formattedAmount,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.red[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (expense.description != null && expense.description!.isNotEmpty) ...[
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      expense.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Category
                  Row(
                    children: [
                      const Icon(Icons.category, size: 20),
                      const SizedBox(width: 8),
                      Text('Kategori: ${expense.categoryDisplayName}'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Payment Method
                  Row(
                    children: [
                      const Icon(Icons.payment, size: 20),
                      const SizedBox(width: 8),
                      Text('Pembayaran: ${expense.paymentMethodDisplayName}'),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Transaction Date
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(expense.transactionDate)}',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  if (expense.location != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            expense.location!.address ?? 
                            '${expense.location!.latitude.toStringAsFixed(6)}, ${expense.location!.longitude.toStringAsFixed(6)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (expense.tags != null && expense.tags!.isNotEmpty) ...[
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: expense.tags!.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showMapLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Legenda Peta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem('Makanan & Minuman', Colors.orange),
            _buildLegendItem('Transportasi', Colors.blue),
            _buildLegendItem('Belanja', Colors.pink),
            _buildLegendItem('Hiburan', Colors.purple),
            _buildLegendItem('Kesehatan', Colors.green),
            _buildLegendItem('Pendidikan', Colors.indigo),
            _buildLegendItem('Lainnya', Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transportation':
        return Colors.blue;
      case 'shopping':
        return Colors.pink;
      case 'entertainment':
        return Colors.purple;
      case 'health':
        return Colors.green;
      case 'education':
        return Colors.indigo;
      default:
        return Colors.red;
    }
  }
}
