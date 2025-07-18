import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/todo_model.dart';

/// Screen untuk menampilkan todo dengan lokasi di Google Maps
/// Author: Tamas dari TamsHub
/// 
/// Screen ini menampilkan semua todo yang memiliki lokasi dalam
/// bentuk marker di Google Maps dengan info window.

class TodoMapScreen extends StatefulWidget {
  final List<TodoModel> todos;

  const TodoMapScreen({
    super.key,
    required this.todos,
  });

  @override
  State<TodoMapScreen> createState() => _TodoMapScreenState();
}

class _TodoMapScreenState extends State<TodoMapScreen> {
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
    final todosWithLocation = widget.todos.where((todo) => todo.location != null).toList();
    
    _markers = todosWithLocation.map((todo) {
      return Marker(
        markerId: MarkerId(todo.id),
        position: LatLng(
          todo.location!.latitude,
          todo.location!.longitude,
        ),
        infoWindow: InfoWindow(
          title: todo.title,
          snippet: todo.description ?? 'Tidak ada deskripsi',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          todo.isCompleted 
              ? BitmapDescriptor.hueGreen 
              : _getMarkerHue(todo.priority),
        ),
        onTap: () => _showTodoDetails(todo),
      );
    }).toSet();
  }

  double _getMarkerHue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return BitmapDescriptor.hueRed;
      case 'medium':
        return BitmapDescriptor.hueOrange;
      case 'low':
        return BitmapDescriptor.hueBlue;
      default:
        return BitmapDescriptor.hueBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final todosWithLocation = widget.todos.where((todo) => todo.location != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Peta Todo (${todosWithLocation.length})'),
        actions: [
          IconButton(
            onPressed: _showMapLegend,
            icon: const Icon(Icons.info_outline),
            tooltip: 'Legenda',
          ),
        ],
      ),
      body: todosWithLocation.isEmpty
          ? _buildEmptyState()
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: todosWithLocation.isNotEmpty
                    ? LatLng(
                        todosWithLocation.first.location!.latitude,
                        todosWithLocation.first.location!.longitude,
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
      floatingActionButton: todosWithLocation.isNotEmpty
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
              'Tidak ada todo dengan lokasi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan lokasi saat membuat todo untuk melihatnya di peta',
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

  void _showTodoDetails(TodoModel todo) {
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

                  // Title and status
                  Row(
                    children: [
                      Icon(
                        todo.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: todo.isCompleted ? Colors.green : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          todo.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  if (todo.description != null && todo.description!.isNotEmpty) ...[
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      todo.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Priority
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Prioritas: ${todo.priority.toUpperCase()}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _getPriorityColor(todo.priority),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Category
                  if (todo.category != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.category, size: 20),
                        const SizedBox(width: 8),
                        Text('Kategori: ${todo.category}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Due date
                  if (todo.dueDate != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 20,
                          color: todo.isOverdue ? Colors.red : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Jatuh tempo: ${todo.dueDate!.day}/${todo.dueDate!.month}/${todo.dueDate!.year} ${todo.dueDate!.hour}:${todo.dueDate!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: todo.isOverdue ? Colors.red : null,
                            fontWeight: todo.isOverdue ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Location
                  if (todo.location != null) ...[
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            todo.location!.address ?? 
                            '${todo.location!.latitude.toStringAsFixed(6)}, ${todo.location!.longitude.toStringAsFixed(6)}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (todo.tags != null && todo.tags!.isNotEmpty) ...[
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
                      children: todo.tags!.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: Colors.blue[700],
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
            _buildLegendItem('Todo Selesai', Colors.green),
            _buildLegendItem('Prioritas Tinggi', Colors.red),
            _buildLegendItem('Prioritas Sedang', Colors.orange),
            _buildLegendItem('Prioritas Rendah', Colors.blue),
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
