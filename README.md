# PabsApp

Aplikasi Multi-Fitur Flutter dengan Dashboard Profesional

## Deskripsi

PabsApp adalah aplikasi Android yang dikembangkan menggunakan Flutter dengan berbagai fitur terintegrasi dalam satu aplikasi. Aplikasi ini menyediakan dashboard profesional dengan navigasi yang mudah ke berbagai fitur yang tersedia.

## Fitur Utama

### 📸 Foto & Rekam
- Mengambil foto dengan kamera
- Merekam video
- Galeri media terintegrasi

### 📝 TodoList dengan Maps
- Manajemen tugas harian
- Integrasi dengan Google Maps
- Lokasi otomatis untuk setiap tugas
- Sinkronisasi real-time

### 💰 FinTech
- Manajemen keuangan personal
- Tracking pengeluaran
- Integrasi dengan Google Maps untuk lokasi transaksi
- Kategori pengeluaran yang dapat disesuaikan

### 🎓 Scrapper PDDIKTI
- Pencarian data mahasiswa
- Pencarian data dosen
- Integrasi dengan database PDDIKTI
- Export data hasil pencarian

### 🤖 Integrasi API BotcahX
- Akses ke lebih dari 700+ API endpoint
- Fitur Anime, Download, Game, Tools, dan lainnya
- Antarmuka yang user-friendly
- Response caching untuk performa optimal

## Teknologi yang Digunakan

- **Framework**: Flutter
- **Database**: Supabase
- **Maps**: Google Maps API
- **State Management**: Provider/Riverpod
- **HTTP Client**: Dio
- **Local Storage**: Hive/SharedPreferences
- **Image Processing**: Image Picker, Image Cropper
- **Location Services**: Geolocator
- **Notifications**: Flutter Local Notifications

## Instalasi

### Prasyarat
- Flutter SDK (versi terbaru)
- Android Studio atau VS Code
- Android SDK
- Git

### Langkah Instalasi

1. Clone repository:
```bash
git clone https://github.com/el-pablos/PabsApp.git
cd PabsApp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Konfigurasi environment:
   - Salin file `.env.example` ke `.env`
   - Isi konfigurasi yang diperlukan

4. Setup Google Maps:
   - Dapatkan API key dari Google Cloud Console
   - Tambahkan API key ke file `.env`
   - Konfigurasi di `android/app/src/main/AndroidManifest.xml`

5. Setup Supabase:
   - Konfigurasi sudah tersedia di `.env`
   - Pastikan koneksi database berjalan dengan baik

6. Run aplikasi:
```bash
flutter run
```

## Struktur Proyek

```
lib/
├── core/
│   ├── constants/
│   ├── services/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── camera/
│   ├── todolist/
│   ├── fintech/
│   ├── pddikti/
│   ├── botcahx/
│   └── dashboard/
├── models/
├── providers/
└── main.dart
```

## Konfigurasi

### Environment Variables
Aplikasi menggunakan file `.env` untuk konfigurasi. Pastikan semua variabel environment telah diisi dengan benar.

### Database
Aplikasi menggunakan Supabase sebagai backend database. Konfigurasi koneksi tersedia di file `.env`.

### API Keys
- **BotcahX API**: Sudah dikonfigurasi
- **Google Maps API**: Perlu dikonfigurasi manual
- **Supabase**: Sudah dikonfigurasi

## Kontribusi

1. Fork repository
2. Buat branch fitur baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add: Menambahkan fitur amazing'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

### Format Commit
Gunakan format commit yang konsisten:
- `Add: Menambahkan fitur baru`
- `Fix: Memperbaiki bug`
- `Update: Memperbarui fitur existing`
- `Delete: Menghapus fitur/file`

## Lisensi

Proyek ini dilisensikan di bawah MIT License - lihat file [LICENSE](LICENSE) untuk detail.

## Author

**Tamas dari TamsHub**

## Dukungan

Jika Anda mengalami masalah atau memiliki pertanyaan, silakan buat issue di repository ini.

## Roadmap

- [ ] Implementasi fitur offline mode
- [ ] Integrasi dengan payment gateway
- [ ] Fitur backup dan restore data
- [ ] Implementasi dark mode
- [ ] Optimisasi performa aplikasi
- [ ] Implementasi unit testing
- [ ] Dokumentasi API lengkap

## Changelog

### v1.0.0 (2025-01-18)
- Initial release
- Implementasi semua fitur utama
- Setup database dan API integration
- UI/UX dashboard profesional
