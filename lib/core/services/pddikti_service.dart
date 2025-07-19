import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/pddikti_model.dart';

/// Service untuk scrapping data PDDIKTI
/// Author: Tamas dari TamsHub
///
/// Service ini menyediakan fungsi-fungsi untuk mengambil data
/// dari API PDDIKTI seperti data mahasiswa, dosen, dan perguruan tinggi.

class PDDIKTIService {
  static PDDIKTIService? _instance;
  static PDDIKTIService get instance => _instance ??= PDDIKTIService._();

  PDDIKTIService._();

  static const String _baseUrl = 'https://api-frontend.kemdikbud.go.id';
  static const String _searchMahasiswaUrl = '$_baseUrl/hit_mhs';
  static const String _searchDosenUrl = '$_baseUrl/hit_dosen';
  static const String _searchPTUrl = '$_baseUrl/hit_pt';
  static const String _detailMahasiswaUrl = '$_baseUrl/detail_mhs';
  static const String _detailDosenUrl = '$_baseUrl/detail_dosen';
  static const String _detailPTUrl = '$_baseUrl/detail_pt';

  final http.Client _client = http.Client();

  /// Mencari data mahasiswa berdasarkan nama
  Future<List<MahasiswaModel>> searchMahasiswa({
    required String nama,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_searchMahasiswaUrl/$nama'),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['mahasiswa'] != null) {
          final List<dynamic> mahasiswaList = data['mahasiswa'];
          return mahasiswaList
              .take(limit)
              .map((json) => MahasiswaModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching mahasiswa: $e');
      rethrow;
    }
  }

  /// Mencari data dosen berdasarkan nama
  Future<List<DosenModel>> searchDosen({
    required String nama,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_searchDosenUrl/$nama'),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['dosen'] != null) {
          final List<dynamic> dosenList = data['dosen'];
          return dosenList
              .take(limit)
              .map((json) => DosenModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching dosen: $e');
      rethrow;
    }
  }

  /// Mencari data perguruan tinggi berdasarkan nama
  Future<List<PerguruanTinggiModel>> searchPerguruanTinggi({
    required String nama,
    int limit = 20,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse('$_searchPTUrl/$nama'),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['pt'] != null) {
          final List<dynamic> ptList = data['pt'];
          return ptList
              .take(limit)
              .map((json) => PerguruanTinggiModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error searching perguruan tinggi: $e');
      rethrow;
    }
  }

  /// Mendapatkan detail mahasiswa berdasarkan ID
  Future<MahasiswaDetailModel?> getDetailMahasiswa(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_detailMahasiswaUrl/$id'),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MahasiswaDetailModel.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting detail mahasiswa: $e');
      rethrow;
    }
  }

  /// Mendapatkan detail dosen berdasarkan ID
  Future<DosenDetailModel?> getDetailDosen(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_detailDosenUrl/$id'),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DosenDetailModel.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting detail dosen: $e');
      rethrow;
    }
  }

  /// Mendapatkan detail perguruan tinggi berdasarkan ID
  Future<PerguruanTinggiDetailModel?> getDetailPerguruanTinggi(
    String id,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('$_detailPTUrl/$id'),
        headers: {
          'Accept': 'application/json',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PerguruanTinggiDetailModel.fromJson(data);
      }

      return null;
    } catch (e) {
      debugPrint('Error getting detail perguruan tinggi: $e');
      rethrow;
    }
  }

  /// Mencari data berdasarkan tipe dan query
  Future<PDDIKTISearchResult> searchAll({
    required String query,
    PDDIKTISearchType type = PDDIKTISearchType.all,
    int limit = 20,
  }) async {
    try {
      List<MahasiswaModel> mahasiswa = [];
      List<DosenModel> dosen = [];
      List<PerguruanTinggiModel> perguruanTinggi = [];

      if (type == PDDIKTISearchType.all ||
          type == PDDIKTISearchType.mahasiswa) {
        mahasiswa = await searchMahasiswa(nama: query, limit: limit);
      }

      if (type == PDDIKTISearchType.all || type == PDDIKTISearchType.dosen) {
        dosen = await searchDosen(nama: query, limit: limit);
      }

      if (type == PDDIKTISearchType.all ||
          type == PDDIKTISearchType.perguruanTinggi) {
        perguruanTinggi = await searchPerguruanTinggi(
          nama: query,
          limit: limit,
        );
      }

      return PDDIKTISearchResult(
        query: query,
        mahasiswa: mahasiswa,
        dosen: dosen,
        perguruanTinggi: perguruanTinggi,
        totalResults: mahasiswa.length + dosen.length + perguruanTinggi.length,
      );
    } catch (e) {
      debugPrint('Error searching all: $e');
      rethrow;
    }
  }

  /// Mendapatkan statistik pencarian
  Future<PDDIKTIStatistics> getSearchStatistics({required String query}) async {
    try {
      final result = await searchAll(query: query, limit: 100);

      // Analisis data untuk statistik
      final Map<String, int> ptCount = {};
      final Map<String, int> prodiCount = {};

      // Hitung berdasarkan mahasiswa
      for (final mhs in result.mahasiswa) {
        if (mhs.namaPerguruanTinggi != null) {
          ptCount[mhs.namaPerguruanTinggi!] =
              (ptCount[mhs.namaPerguruanTinggi!] ?? 0) + 1;
        }
        if (mhs.namaProdi != null) {
          prodiCount[mhs.namaProdi!] = (prodiCount[mhs.namaProdi!] ?? 0) + 1;
        }
      }

      // Hitung berdasarkan dosen
      for (final dsn in result.dosen) {
        if (dsn.namaPerguruanTinggi != null) {
          ptCount[dsn.namaPerguruanTinggi!] =
              (ptCount[dsn.namaPerguruanTinggi!] ?? 0) + 1;
        }
      }

      return PDDIKTIStatistics(
        query: query,
        totalMahasiswa: result.mahasiswa.length,
        totalDosen: result.dosen.length,
        totalPerguruanTinggi: result.perguruanTinggi.length,
        topPerguruanTinggi: ptCount.entries.isNotEmpty
            ? ptCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : '',
        topProdi: prodiCount.entries.isNotEmpty
            ? prodiCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
            : '',
        perguruanTinggiBreakdown: ptCount,
        prodiBreakdown: prodiCount,
      );
    } catch (e) {
      debugPrint('Error getting search statistics: $e');
      rethrow;
    }
  }

  /// Validasi koneksi ke API PDDIKTI dengan retry mechanism
  Future<Map<String, dynamic>> validateConnection({int maxRetries = 3}) async {
    int attempts = 0;
    String? lastError;

    while (attempts < maxRetries) {
      try {
        attempts++;
        debugPrint('PDDIKTI: Connection attempt $attempts/$maxRetries');

        final response = await _client
            .get(
              Uri.parse('$_searchMahasiswaUrl/test'),
              headers: {
                'Accept': 'application/json',
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                'Connection': 'keep-alive',
              },
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          debugPrint('PDDIKTI: Connection successful');
          return {
            'success': true,
            'message': 'Berhasil terhubung ke server PDDIKTI',
            'attempts': attempts,
            'statusCode': response.statusCode,
          };
        } else {
          lastError = 'HTTP ${response.statusCode}: ${response.reasonPhrase}';
          debugPrint('PDDIKTI: Connection failed - $lastError');
        }
      } catch (e) {
        lastError = e.toString();
        debugPrint('PDDIKTI: Connection error (attempt $attempts) - $e');

        if (attempts < maxRetries) {
          // Wait before retry with exponential backoff
          final delay = Duration(seconds: attempts * 2);
          debugPrint('PDDIKTI: Retrying in ${delay.inSeconds} seconds...');
          await Future.delayed(delay);
        }
      }
    }

    return {
      'success': false,
      'message':
          'Tidak bisa terhubung ke server PDDIKTI setelah $maxRetries percobaan',
      'error': lastError,
      'attempts': attempts,
    };
  }

  /// Get mock data when server is unavailable
  Future<List<MahasiswaModel>> _getMockMahasiswaData(String query) async {
    debugPrint('PDDIKTI: Using mock data for mahasiswa search: $query');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final mockData = [
      {
        'nama': 'Ahmad Budi Santoso',
        'nim': '1234567890',
        'nama_prodi': 'Teknik Informatika',
        'nama_pt': 'Universitas Indonesia',
        'angkatan': '2020',
        'status_mahasiswa': 'Aktif',
        'id': 'mock_1',
      },
      {
        'nama': 'Siti Nurhaliza',
        'nim': '0987654321',
        'nama_prodi': 'Sistem Informasi',
        'nama_pt': 'Institut Teknologi Bandung',
        'angkatan': '2019',
        'status_mahasiswa': 'Aktif',
        'id': 'mock_2',
      },
      {
        'nama': 'Muhammad Rizki Pratama',
        'nim': '1122334455',
        'nama_prodi': 'Teknik Komputer',
        'nama_pt': 'Universitas Gadjah Mada',
        'angkatan': '2021',
        'status_mahasiswa': 'Aktif',
        'id': 'mock_3',
      },
    ];

    // Filter based on query
    final filteredData = mockData.where((item) {
      final name = item['nama'].toString().toLowerCase();
      final nim = item['nim'].toString().toLowerCase();
      final searchQuery = query.toLowerCase();
      return name.contains(searchQuery) || nim.contains(searchQuery);
    }).toList();

    return filteredData.map((json) => MahasiswaModel.fromJson(json)).toList();
  }

  /// Enhanced search with fallback to mock data
  Future<List<MahasiswaModel>> searchMahasiswaWithFallback({
    required String nama,
    int limit = 20,
  }) async {
    try {
      // First, try to validate connection
      final connectionResult = await validateConnection(maxRetries: 2);

      if (!connectionResult['success']) {
        debugPrint('PDDIKTI: Server unavailable, using mock data');
        return await _getMockMahasiswaData(nama);
      }

      // If connection is good, proceed with normal search
      return await searchMahasiswa(nama: nama, limit: limit);
    } catch (e) {
      debugPrint('PDDIKTI: Search failed, falling back to mock data - $e');
      return await _getMockMahasiswaData(nama);
    }
  }

  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
