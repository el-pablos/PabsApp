/// Model untuk data PDDIKTI
/// Author: Tamas dari TamsHub
/// 
/// Model ini merepresentasikan data dari API PDDIKTI seperti
/// mahasiswa, dosen, dan perguruan tinggi.

/// Model untuk data mahasiswa
class MahasiswaModel {
  final String id;
  final String nama;
  final String? nim;
  final String? namaPerguruanTinggi;
  final String? namaProdi;
  final String? angkatan;
  final String? status;

  MahasiswaModel({
    required this.id,
    required this.nama,
    this.nim,
    this.namaPerguruanTinggi,
    this.namaProdi,
    this.angkatan,
    this.status,
  });

  factory MahasiswaModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nim: json['nim']?.toString(),
      namaPerguruanTinggi: json['nama_pt']?.toString(),
      namaProdi: json['nama_prodi']?.toString(),
      angkatan: json['angkatan']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nim': nim,
      'nama_pt': namaPerguruanTinggi,
      'nama_prodi': namaProdi,
      'angkatan': angkatan,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'MahasiswaModel(id: $id, nama: $nama, nim: $nim)';
  }
}

/// Model untuk detail mahasiswa
class MahasiswaDetailModel {
  final String id;
  final String nama;
  final String? nim;
  final String? namaPerguruanTinggi;
  final String? namaProdi;
  final String? jenjang;
  final String? angkatan;
  final String? status;
  final String? tanggalLahir;
  final String? jenisKelamin;
  final String? alamat;
  final List<RiwayatPendidikanModel>? riwayatPendidikan;

  MahasiswaDetailModel({
    required this.id,
    required this.nama,
    this.nim,
    this.namaPerguruanTinggi,
    this.namaProdi,
    this.jenjang,
    this.angkatan,
    this.status,
    this.tanggalLahir,
    this.jenisKelamin,
    this.alamat,
    this.riwayatPendidikan,
  });

  factory MahasiswaDetailModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaDetailModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nim: json['nim']?.toString(),
      namaPerguruanTinggi: json['nama_pt']?.toString(),
      namaProdi: json['nama_prodi']?.toString(),
      jenjang: json['jenjang']?.toString(),
      angkatan: json['angkatan']?.toString(),
      status: json['status']?.toString(),
      tanggalLahir: json['tgl_lahir']?.toString(),
      jenisKelamin: json['jenis_kelamin']?.toString(),
      alamat: json['alamat']?.toString(),
      riwayatPendidikan: json['riwayat_pendidikan'] != null
          ? (json['riwayat_pendidikan'] as List)
              .map((e) => RiwayatPendidikanModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

/// Model untuk data dosen
class DosenModel {
  final String id;
  final String nama;
  final String? nidn;
  final String? namaPerguruanTinggi;
  final String? programStudi;
  final String? jabatan;

  DosenModel({
    required this.id,
    required this.nama,
    this.nidn,
    this.namaPerguruanTinggi,
    this.programStudi,
    this.jabatan,
  });

  factory DosenModel.fromJson(Map<String, dynamic> json) {
    return DosenModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nidn: json['nidn']?.toString(),
      namaPerguruanTinggi: json['nama_pt']?.toString(),
      programStudi: json['prodi']?.toString(),
      jabatan: json['jabatan']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nidn': nidn,
      'nama_pt': namaPerguruanTinggi,
      'prodi': programStudi,
      'jabatan': jabatan,
    };
  }

  @override
  String toString() {
    return 'DosenModel(id: $id, nama: $nama, nidn: $nidn)';
  }
}

/// Model untuk detail dosen
class DosenDetailModel {
  final String id;
  final String nama;
  final String? nidn;
  final String? namaPerguruanTinggi;
  final String? programStudi;
  final String? jabatan;
  final String? pendidikanTerakhir;
  final String? bidangKeahlian;
  final List<RiwayatMengajarModel>? riwayatMengajar;

  DosenDetailModel({
    required this.id,
    required this.nama,
    this.nidn,
    this.namaPerguruanTinggi,
    this.programStudi,
    this.jabatan,
    this.pendidikanTerakhir,
    this.bidangKeahlian,
    this.riwayatMengajar,
  });

  factory DosenDetailModel.fromJson(Map<String, dynamic> json) {
    return DosenDetailModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      nidn: json['nidn']?.toString(),
      namaPerguruanTinggi: json['nama_pt']?.toString(),
      programStudi: json['prodi']?.toString(),
      jabatan: json['jabatan']?.toString(),
      pendidikanTerakhir: json['pendidikan_terakhir']?.toString(),
      bidangKeahlian: json['bidang_keahlian']?.toString(),
      riwayatMengajar: json['riwayat_mengajar'] != null
          ? (json['riwayat_mengajar'] as List)
              .map((e) => RiwayatMengajarModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

/// Model untuk perguruan tinggi
class PerguruanTinggiModel {
  final String id;
  final String nama;
  final String? npsn;
  final String? status;
  final String? bentuk;
  final String? alamat;
  final String? kota;
  final String? provinsi;

  PerguruanTinggiModel({
    required this.id,
    required this.nama,
    this.npsn,
    this.status,
    this.bentuk,
    this.alamat,
    this.kota,
    this.provinsi,
  });

  factory PerguruanTinggiModel.fromJson(Map<String, dynamic> json) {
    return PerguruanTinggiModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      npsn: json['npsn']?.toString(),
      status: json['status']?.toString(),
      bentuk: json['bentuk']?.toString(),
      alamat: json['alamat']?.toString(),
      kota: json['kota']?.toString(),
      provinsi: json['provinsi']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'npsn': npsn,
      'status': status,
      'bentuk': bentuk,
      'alamat': alamat,
      'kota': kota,
      'provinsi': provinsi,
    };
  }

  @override
  String toString() {
    return 'PerguruanTinggiModel(id: $id, nama: $nama)';
  }
}

/// Model untuk detail perguruan tinggi
class PerguruanTinggiDetailModel {
  final String id;
  final String nama;
  final String? npsn;
  final String? status;
  final String? bentuk;
  final String? alamat;
  final String? kota;
  final String? provinsi;
  final String? website;
  final String? email;
  final String? telepon;
  final List<ProdiModel>? programStudi;

  PerguruanTinggiDetailModel({
    required this.id,
    required this.nama,
    this.npsn,
    this.status,
    this.bentuk,
    this.alamat,
    this.kota,
    this.provinsi,
    this.website,
    this.email,
    this.telepon,
    this.programStudi,
  });

  factory PerguruanTinggiDetailModel.fromJson(Map<String, dynamic> json) {
    return PerguruanTinggiDetailModel(
      id: json['id']?.toString() ?? '',
      nama: json['nama']?.toString() ?? '',
      npsn: json['npsn']?.toString(),
      status: json['status']?.toString(),
      bentuk: json['bentuk']?.toString(),
      alamat: json['alamat']?.toString(),
      kota: json['kota']?.toString(),
      provinsi: json['provinsi']?.toString(),
      website: json['website']?.toString(),
      email: json['email']?.toString(),
      telepon: json['telepon']?.toString(),
      programStudi: json['program_studi'] != null
          ? (json['program_studi'] as List)
              .map((e) => ProdiModel.fromJson(e))
              .toList()
          : null,
    );
  }
}

/// Model untuk riwayat pendidikan
class RiwayatPendidikanModel {
  final String? jenjang;
  final String? namaPerguruanTinggi;
  final String? namaProdi;
  final String? tahunMasuk;
  final String? tahunLulus;

  RiwayatPendidikanModel({
    this.jenjang,
    this.namaPerguruanTinggi,
    this.namaProdi,
    this.tahunMasuk,
    this.tahunLulus,
  });

  factory RiwayatPendidikanModel.fromJson(Map<String, dynamic> json) {
    return RiwayatPendidikanModel(
      jenjang: json['jenjang']?.toString(),
      namaPerguruanTinggi: json['nama_pt']?.toString(),
      namaProdi: json['nama_prodi']?.toString(),
      tahunMasuk: json['tahun_masuk']?.toString(),
      tahunLulus: json['tahun_lulus']?.toString(),
    );
  }
}

/// Model untuk riwayat mengajar
class RiwayatMengajarModel {
  final String? namaPerguruanTinggi;
  final String? programStudi;
  final String? mataKuliah;
  final String? tahunAjaran;

  RiwayatMengajarModel({
    this.namaPerguruanTinggi,
    this.programStudi,
    this.mataKuliah,
    this.tahunAjaran,
  });

  factory RiwayatMengajarModel.fromJson(Map<String, dynamic> json) {
    return RiwayatMengajarModel(
      namaPerguruanTinggi: json['nama_pt']?.toString(),
      programStudi: json['prodi']?.toString(),
      mataKuliah: json['mata_kuliah']?.toString(),
      tahunAjaran: json['tahun_ajaran']?.toString(),
    );
  }
}

/// Model untuk program studi
class ProdiModel {
  final String? nama;
  final String? jenjang;
  final String? status;

  ProdiModel({
    this.nama,
    this.jenjang,
    this.status,
  });

  factory ProdiModel.fromJson(Map<String, dynamic> json) {
    return ProdiModel(
      nama: json['nama']?.toString(),
      jenjang: json['jenjang']?.toString(),
      status: json['status']?.toString(),
    );
  }
}

/// Model untuk hasil pencarian
class PDDIKTISearchResult {
  final String query;
  final List<MahasiswaModel> mahasiswa;
  final List<DosenModel> dosen;
  final List<PerguruanTinggiModel> perguruanTinggi;
  final int totalResults;

  PDDIKTISearchResult({
    required this.query,
    required this.mahasiswa,
    required this.dosen,
    required this.perguruanTinggi,
    required this.totalResults,
  });
}

/// Model untuk statistik pencarian
class PDDIKTIStatistics {
  final String query;
  final int totalMahasiswa;
  final int totalDosen;
  final int totalPerguruanTinggi;
  final String topPerguruanTinggi;
  final String topProdi;
  final Map<String, int> perguruanTinggiBreakdown;
  final Map<String, int> prodiBreakdown;

  PDDIKTIStatistics({
    required this.query,
    required this.totalMahasiswa,
    required this.totalDosen,
    required this.totalPerguruanTinggi,
    required this.topPerguruanTinggi,
    required this.topProdi,
    required this.perguruanTinggiBreakdown,
    required this.prodiBreakdown,
  });
}

/// Enum untuk tipe pencarian
enum PDDIKTISearchType {
  all,
  mahasiswa,
  dosen,
  perguruanTinggi,
}
