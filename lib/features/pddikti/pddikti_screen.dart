import 'package:flutter/material.dart';

import '../../core/services/pddikti_service.dart';
import '../../models/pddikti_model.dart';
// import 'widgets/mahasiswa_item_widget.dart';
// import 'widgets/dosen_item_widget.dart';
// import 'widgets/perguruan_tinggi_item_widget.dart';
// import 'widgets/pddikti_statistics_widget.dart';

/// Screen untuk fitur PDDIKTI Scrapper
/// Author: Tamas dari TamsHub
///
/// Screen ini menyediakan interface untuk mencari data mahasiswa,
/// dosen, dan perguruan tinggi dari database PDDIKTI.

class PDDIKTIScreen extends StatefulWidget {
  const PDDIKTIScreen({super.key});

  @override
  State<PDDIKTIScreen> createState() => _PDDIKTIScreenState();
}

class _PDDIKTIScreenState extends State<PDDIKTIScreen>
    with TickerProviderStateMixin {
  final PDDIKTIService _pddiktiService = PDDIKTIService.instance;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  bool _isLoading = false;
  bool _hasSearched = false;
  PDDIKTISearchResult? _searchResult;
  PDDIKTIStatistics? _statistics;
  PDDIKTISearchType _searchType = PDDIKTISearchType.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkConnection();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final connectionResult = await _pddiktiService.validateConnection();
    if (!connectionResult['success'] && mounted) {
      final message =
          connectionResult['message'] ??
          'Tidak dapat terhubung ke server PDDIKTI';
      _showErrorSnackBar(message);
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _showErrorSnackBar('Masukkan kata kunci pencarian');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = false;
    });

    try {
      final result = await _pddiktiService.searchAll(
        query: query,
        type: _searchType,
        limit: 50,
      );

      final statistics = await _pddiktiService.getSearchStatistics(
        query: query,
      );

      setState(() {
        _searchResult = result;
        _statistics = statistics;
        _hasSearched = true;
      });

      if (result.totalResults == 0) {
        _showInfoSnackBar('Tidak ditemukan hasil untuk "$query"');
      } else {
        _showSuccessSnackBar('Ditemukan ${result.totalResults} hasil');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal melakukan pencarian: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDDIKTI Scrapper'),
        actions: [
          IconButton(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear),
            tooltip: 'Clear',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Cari mahasiswa, dosen, atau perguruan tinggi...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _isLoading
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  onPressed: _performSearch,
                                  icon: const Icon(Icons.send),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<PDDIKTISearchType>(
                      initialValue: _searchType,
                      onSelected: (type) {
                        setState(() {
                          _searchType = type;
                        });
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: PDDIKTISearchType.all,
                          child: Text('Semua'),
                        ),
                        const PopupMenuItem(
                          value: PDDIKTISearchType.mahasiswa,
                          child: Text('Mahasiswa'),
                        ),
                        const PopupMenuItem(
                          value: PDDIKTISearchType.dosen,
                          child: Text('Dosen'),
                        ),
                        const PopupMenuItem(
                          value: PDDIKTISearchType.perguruanTinggi,
                          child: Text('Perguruan Tinggi'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getSearchTypeIcon(),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Bar
              if (_hasSearched && _searchResult != null)
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.school),
                      text: 'Mahasiswa (${_searchResult!.mahasiswa.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.person),
                      text: 'Dosen (${_searchResult!.dosen.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.business),
                      text: 'PT (${_searchResult!.perguruanTinggi.length})',
                    ),
                    Tab(icon: const Icon(Icons.analytics), text: 'Statistik'),
                  ],
                ),
            ],
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_hasSearched) {
      return _buildWelcomeScreen();
    }

    if (_searchResult == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildMahasiswaTab(),
        _buildDosenTab(),
        _buildPerguruanTinggiTab(),
        _buildStatisticsTab(),
      ],
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'PDDIKTI Scrapper',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cari data mahasiswa, dosen, dan perguruan tinggi dari database PDDIKTI',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitur yang tersedia:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.school, 'Pencarian data mahasiswa'),
                    _buildFeatureItem(Icons.person, 'Pencarian data dosen'),
                    _buildFeatureItem(
                      Icons.business,
                      'Pencarian perguruan tinggi',
                    ),
                    _buildFeatureItem(Icons.analytics, 'Statistik pencarian'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildMahasiswaTab() {
    if (_searchResult!.mahasiswa.isEmpty) {
      return _buildEmptyState('Tidak ditemukan data mahasiswa', Icons.school);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResult!.mahasiswa.length,
      itemBuilder: (context, index) {
        final mahasiswa = _searchResult!.mahasiswa[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.school)),
            title: Text(mahasiswa.nama),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mahasiswa.nim != null) Text('NIM: ${mahasiswa.nim}'),
                if (mahasiswa.namaPerguruanTinggi != null)
                  Text(mahasiswa.namaPerguruanTinggi!),
                if (mahasiswa.namaProdi != null) Text(mahasiswa.namaProdi!),
              ],
            ),
            trailing: mahasiswa.angkatan != null
                ? Chip(label: Text(mahasiswa.angkatan!))
                : null,
            onTap: () => _showMahasiswaDetail(mahasiswa),
          ),
        );
      },
    );
  }

  Widget _buildDosenTab() {
    if (_searchResult!.dosen.isEmpty) {
      return _buildEmptyState('Tidak ditemukan data dosen', Icons.person);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResult!.dosen.length,
      itemBuilder: (context, index) {
        final dosen = _searchResult!.dosen[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(dosen.nama),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (dosen.nidn != null) Text('NIDN: ${dosen.nidn}'),
                if (dosen.namaPerguruanTinggi != null)
                  Text(dosen.namaPerguruanTinggi!),
                if (dosen.programStudi != null) Text(dosen.programStudi!),
              ],
            ),
            trailing: dosen.jabatan != null
                ? Chip(label: Text(dosen.jabatan!))
                : null,
            onTap: () => _showDosenDetail(dosen),
          ),
        );
      },
    );
  }

  Widget _buildPerguruanTinggiTab() {
    if (_searchResult!.perguruanTinggi.isEmpty) {
      return _buildEmptyState(
        'Tidak ditemukan data perguruan tinggi',
        Icons.business,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResult!.perguruanTinggi.length,
      itemBuilder: (context, index) {
        final pt = _searchResult!.perguruanTinggi[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.business)),
            title: Text(pt.nama),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pt.npsn != null) Text('NPSN: ${pt.npsn}'),
                if (pt.alamat != null) Text(pt.alamat!),
                if (pt.kota != null && pt.provinsi != null)
                  Text('${pt.kota}, ${pt.provinsi}'),
              ],
            ),
            trailing: pt.status != null ? Chip(label: Text(pt.status!)) : null,
            onTap: () => _showPerguruanTinggiDetail(pt),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik Pencarian: "${_statistics!.query}"',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Mahasiswa',
                          _statistics!.totalMahasiswa.toString(),
                          Icons.school,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'Dosen',
                          _statistics!.totalDosen.toString(),
                          Icons.person,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          'PT',
                          _statistics!.totalPerguruanTinggi.toString(),
                          Icons.business,
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_statistics!.topPerguruanTinggi.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Perguruan Tinggi',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_statistics!.topPerguruanTinggi),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  IconData _getSearchTypeIcon() {
    switch (_searchType) {
      case PDDIKTISearchType.mahasiswa:
        return Icons.school;
      case PDDIKTISearchType.dosen:
        return Icons.person;
      case PDDIKTISearchType.perguruanTinggi:
        return Icons.business;
      default:
        return Icons.all_inclusive;
    }
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _hasSearched = false;
      _searchResult = null;
      _statistics = null;
    });
  }

  void _showMahasiswaDetail(MahasiswaModel mahasiswa) {
    // TODO: Implement detail view
    _showInfoSnackBar('Detail mahasiswa - Coming Soon');
  }

  void _showDosenDetail(DosenModel dosen) {
    // TODO: Implement detail view
    _showInfoSnackBar('Detail dosen - Coming Soon');
  }

  void _showPerguruanTinggiDetail(PerguruanTinggiModel pt) {
    // TODO: Implement detail view
    _showInfoSnackBar('Detail perguruan tinggi - Coming Soon');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue),
    );
  }
}
