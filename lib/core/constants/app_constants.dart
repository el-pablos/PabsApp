/// Konstanta aplikasi PabsApp
/// Author: Tamas dari TamsHub
///
/// File ini berisi semua konstanta yang digunakan dalam aplikasi
/// termasuk konfigurasi API, database, dan pengaturan aplikasi lainnya.

class AppConstants {
  // Informasi Aplikasi
  static const String appName = 'PabsApp';
  static const String appVersion = '1.0.0';
  static const String appAuthor = 'Tamas dari TamsHub';
  static const String appDescription =
      'Aplikasi Multi-Fitur Flutter dengan Dashboard Profesional';

  // Supabase Configuration
  // Updated URL to use the correct REST API endpoint
  static const String supabaseUrl = 'https://hpnzgrutaclyrweazivw.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwbnpncnV0YWNseXJ3ZWF6aXZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI4Njk4NjMsImV4cCI6MjA2ODQ0NTg2M30.4GXxmh5DguF1zJNlkTOTWO3r7RIVbsWUpGR-AmzG-is';
  static const String supabaseServiceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhwbnpncnV0YWNseXJ3ZWF6aXZ3Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1Mjg2OTg2MywiZXhwIjoyMDY4NDQ1ODYzfQ.lMnAn6szqAhjvoICQpxClgJiQxxeeS8tgzeHDTaa1B8';

  // Database Schema Configuration
  static const String databaseSchema = 'public';

  // BotcahX API Configuration
  static const String botcahxApiUrl = 'https://api.botcahx.eu.org';
  static const String botcahxApiKey = 'kontol';

  // PDDIKTI API Configuration
  static const String pddiktiApiUrl = 'https://api-frontend.kemdikbud.go.id';
  static const String pddiktiSearchEndpoint = '/hit_mhs';

  // Database Tables
  static const String usersTable = 'users';
  static const String todosTable = 'todos';
  static const String expensesTable = 'expenses';
  static const String categoriesTable = 'categories';
  static const String locationsTable = 'locations';
  static const String mediaTable = 'media';
  static const String settingsTable = 'settings';

  // Storage Buckets
  static const String profileImagesBucket = 'profile-images';
  static const String mediaBucket = 'media';
  static const String documentsBucket = 'documents';

  // Default Values
  static const String defaultCurrency = 'IDR';
  static const int maxImageSize = 5242880; // 5MB
  static const int maxVideoDuration = 300; // 5 minutes
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  static const List<String> supportedVideoFormats = ['mp4', 'mov', 'avi'];

  // Expense Categories
  static const List<String> expenseCategories = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Hiburan',
    'Kesehatan',
    'Pendidikan',
    'Lainnya',
  ];

  // Location Settings
  static const String locationAccuracy = 'high';
  static const int locationTimeout = 30000;

  // Cache Settings
  static const int cacheSize = 104857600; // 100MB
  static const int imageCacheSize = 52428800; // 50MB
  static const int networkTimeout = 30000;

  // Session Settings
  static const int sessionTimeout = 3600000; // 1 hour
  static const String encryptionKey = 'PabsApp2025SecureKey';

  // Sync Settings
  static const int todoSyncInterval = 300000; // 5 minutes
  static const bool todoBackupEnabled = true;

  // Feature Flags
  static const bool featurePhotoEnabled = true;
  static const bool featureVideoEnabled = true;
  static const bool featureTodolistEnabled = true;
  static const bool featureFintechEnabled = true;
  static const bool featurePddiktiEnabled = true;
  static const bool featureBotcahxEnabled = true;
  static const bool featureMapsEnabled = true;
  static const bool featureLocationEnabled = true;

  // Notification Settings
  static const bool pushNotificationsEnabled = true;
  static const bool localNotificationsEnabled = true;

  // Performance Settings
  static const bool analyticsEnabled = false;
  static const bool crashReportingEnabled = true;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error Messages
  static const String networkErrorMessage = 'Tidak dapat terhubung ke internet';
  static const String serverErrorMessage = 'Terjadi kesalahan pada server';
  static const String unknownErrorMessage =
      'Terjadi kesalahan yang tidak diketahui';
  static const String permissionDeniedMessage = 'Izin akses ditolak';
  static const String locationDisabledMessage = 'Layanan lokasi tidak aktif';

  // Success Messages
  static const String dataLoadedMessage = 'Data berhasil dimuat';
  static const String dataSavedMessage = 'Data berhasil disimpan';
  static const String dataUpdatedMessage = 'Data berhasil diperbarui';
  static const String dataDeletedMessage = 'Data berhasil dihapus';

  // Validation Messages
  static const String requiredFieldMessage = 'Field ini wajib diisi';
  static const String invalidEmailMessage = 'Format email tidak valid';
  static const String passwordTooShortMessage = 'Password minimal 6 karakter';
  static const String passwordMismatchMessage = 'Password tidak cocok';

  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // API Endpoints BotcahX Categories
  static const Map<String, String> botcahxCategories = {
    'anime': 'Anime',
    'asupan': 'Asupan',
    'cecan': 'Cecan',
    'download': 'Download',
    'emoji': 'Emoji',
    'ephoto': 'Ephoto',
    'game': 'Game',
    'islamic': 'Islamic',
    'maker': 'Maker',
    'news': 'News',
    'nsfw': 'NSFW',
    'photooxy': 'Photooxy',
    'primbon': 'Primbon',
    'randomtext': 'Random Text',
    'search': 'Search',
    'stalk': 'Stalk',
    'sticker': 'Sticker',
    'story': 'Story',
    'textpro': 'Textpro',
    'texttosound': 'Text To Sound',
    'tools': 'Tools',
    'vokal': 'Vokal',
    'wallpaper': 'Wallpaper',
    'webzone': 'Webzone',
  };

  // Regex Patterns
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String phonePattern = r'^(\+62|62|0)8[1-9][0-9]{6,9}$';
  static const String urlPattern =
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$';
}
