import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
// import 'package:connectivity_plus/connectivity_plus.dart'; // Will add later

import '../../core/services/health_service.dart';
import '../../core/models/health_status_model.dart';
import '../../core/widgets/loading_widget.dart';

/// Screen untuk monitoring kesehatan sistem dan runtime
/// Author: Tamas dari TamsHub
///
/// Screen ini menampilkan status real-time dari semua API,
/// koneksi jaringan, cuaca, waktu sistem, dan performa aplikasi.

class HealthRuntimeScreen extends StatefulWidget {
  const HealthRuntimeScreen({super.key});

  @override
  State<HealthRuntimeScreen> createState() => _HealthRuntimeScreenState();
}

class _HealthRuntimeScreenState extends State<HealthRuntimeScreen> {
  final HealthService _healthService = HealthService();

  Timer? _refreshTimer;
  bool _isLoading = false;
  DateTime _lastUpdated = DateTime.now();

  // Status data
  List<ApiStatus> _apiStatuses = [];
  WeatherInfo? _weatherInfo;
  SystemInfo? _systemInfo;
  NetworkInfo? _networkInfo;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadHealthData();
      }
    });
  }

  Future<void> _loadHealthData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Load all health data concurrently
      final results = await Future.wait([
        _healthService.checkApiStatuses(),
        _healthService.getWeatherInfo(),
        _healthService.getSystemInfo(),
        _healthService.getNetworkInfo(),
      ]);

      setState(() {
        _apiStatuses = results[0] as List<ApiStatus>;
        _weatherInfo = results[1] as WeatherInfo?;
        _systemInfo = results[2] as SystemInfo?;
        _networkInfo = results[3] as NetworkInfo?;
        _lastUpdated = DateTime.now();
      });
    } catch (e) {
      debugPrint('Error loading health data: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Runtime'),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadHealthData,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHealthData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Last Updated Info
            _buildLastUpdatedCard(),
            const SizedBox(height: 16),

            // System Clock
            _buildSystemClockCard(),
            const SizedBox(height: 16),

            // Network Status
            _buildNetworkStatusCard(),
            const SizedBox(height: 16),

            // API Status Section
            _buildApiStatusSection(),
            const SizedBox(height: 16),

            // Weather Information
            _buildWeatherCard(),
            const SizedBox(height: 16),

            // System Information
            _buildSystemInfoCard(),
            const SizedBox(height: 16),

            // Performance Metrics
            _buildPerformanceCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildLastUpdatedCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.update, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Terakhir Diperbarui',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm:ss').format(_lastUpdated),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'ONLINE',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemClockCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Waktu Sistem',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StreamBuilder<DateTime>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => DateTime.now(),
              ),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();
                return Column(
                  children: [
                    Text(
                      DateFormat('HH:mm:ss').format(now),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now),
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wifi, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Status Jaringan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_networkInfo != null) ...[
              _buildStatusRow(
                'Koneksi',
                _networkInfo!.isConnected ? 'Terhubung' : 'Terputus',
                _networkInfo!.isConnected ? Colors.green : Colors.red,
              ),
              _buildStatusRow(
                'Tipe',
                _networkInfo!.connectionType,
                Colors.blue,
              ),
              if (_networkInfo!.signalStrength != null)
                _buildStatusRow(
                  'Kekuatan Sinyal',
                  '${_networkInfo!.signalStrength}%',
                  Colors.orange,
                ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApiStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.api, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Status API',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_apiStatuses.isNotEmpty) ...[
              ..._apiStatuses.map((api) => _buildApiStatusTile(api)),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildApiStatusTile(ApiStatus api) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: api.isOnline ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  api.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${api.responseTime}ms - ${api.status}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            api.isOnline ? 'ONLINE' : 'OFFLINE',
            style: TextStyle(
              color: api.isOnline ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Informasi Cuaca',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_weatherInfo != null) ...[
              Row(
                children: [
                  Text(
                    '${_weatherInfo!.temperature}°C',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _weatherInfo!.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          _weatherInfo!.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWeatherDetail(
                    'Kelembaban',
                    '${_weatherInfo!.humidity}%',
                  ),
                  _buildWeatherDetail(
                    'Angin',
                    '${_weatherInfo!.windSpeed} km/h',
                  ),
                  _buildWeatherDetail(
                    'Tekanan',
                    '${_weatherInfo!.pressure} hPa',
                  ),
                ],
              ),
            ] else ...[
              const Center(child: Text('Data cuaca tidak tersedia')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildSystemInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Informasi Sistem',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_systemInfo != null) ...[
              _buildStatusRow('Platform', _systemInfo!.platform, Colors.blue),
              _buildStatusRow('Versi OS', _systemInfo!.osVersion, Colors.green),
              _buildStatusRow(
                'Model Device',
                _systemInfo!.deviceModel,
                Colors.orange,
              ),
              _buildStatusRow(
                'RAM Tersedia',
                '${_systemInfo!.availableMemory}MB',
                Colors.purple,
              ),
              _buildStatusRow(
                'Storage Tersisa',
                '${_systemInfo!.freeStorage}GB',
                Colors.teal,
              ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'Performa Aplikasi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              'CPU Usage',
              '${_systemInfo?.cpuUsage ?? 0}%',
              Colors.red,
            ),
            _buildStatusRow(
              'Memory Usage',
              '${_systemInfo?.memoryUsage ?? 0}%',
              Colors.orange,
            ),
            _buildStatusRow(
              'Battery Level',
              '${_systemInfo?.batteryLevel ?? 0}%',
              Colors.green,
            ),
            _buildStatusRow(
              'App Uptime',
              _formatUptime(_systemInfo?.appUptime ?? 0),
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatUptime(int seconds) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
