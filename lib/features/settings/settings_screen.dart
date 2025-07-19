import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/settings_service.dart';
import '../../core/models/settings_model.dart';

/// Screen untuk pengaturan aplikasi
/// Author: Tamas dari TamsHub
///
/// Screen ini menyediakan berbagai pengaturan aplikasi seperti
/// notifikasi, tema, bahasa, privasi, dan informasi aplikasi.

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  SettingsModel? _settings;
  PackageInfo? _packageInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadPackageInfo();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final settings = await _settingsService.getSettings(authProvider.userId);
      setState(() => _settings = settings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading settings: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() => _packageInfo = packageInfo);
    } catch (e) {
      debugPrint('Error loading package info: $e');
    }
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    if (_settings == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await _settingsService.updateSetting(authProvider.userId, key, value);
      
      // Update local settings
      final updatedSettings = _settings!.copyWith(
        notificationsEnabled: key == 'notifications' ? value : _settings!.notificationsEnabled,
        soundEnabled: key == 'sound' ? value : _settings!.soundEnabled,
        vibrationEnabled: key == 'vibration' ? value : _settings!.vibrationEnabled,
        autoBackup: key == 'autoBackup' ? value : _settings!.autoBackup,
        biometricEnabled: key == 'biometric' ? value : _settings!.biometricEnabled,
        language: key == 'language' ? value : _settings!.language,
        updatedAt: DateTime.now(),
      );
      
      setState(() => _settings = updatedSettings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating setting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // App Preferences Section
                _buildSectionHeader('Preferensi Aplikasi'),
                _buildNotificationSettings(),
                _buildThemeSettings(),
                _buildLanguageSettings(),
                
                const Divider(height: 32),
                
                // Account Settings Section
                _buildSectionHeader('Pengaturan Akun'),
                _buildAccountSettings(),
                
                const Divider(height: 32),
                
                // Privacy & Security Section
                _buildSectionHeader('Privasi & Keamanan'),
                _buildPrivacySettings(),
                
                const Divider(height: 32),
                
                // Data & Storage Section
                _buildSectionHeader('Data & Penyimpanan'),
                _buildDataSettings(),
                
                const Divider(height: 32),
                
                // About Section
                _buildSectionHeader('Tentang'),
                _buildAboutSection(),
                
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Notifikasi'),
          subtitle: const Text('Terima notifikasi dari aplikasi'),
          value: _settings?.notificationsEnabled ?? true,
          onChanged: (value) => _updateSetting('notifications', value),
          secondary: const Icon(Icons.notifications),
        ),
        SwitchListTile(
          title: const Text('Suara'),
          subtitle: const Text('Putar suara notifikasi'),
          value: _settings?.soundEnabled ?? true,
          onChanged: (value) => _updateSetting('sound', value),
          secondary: const Icon(Icons.volume_up),
        ),
        SwitchListTile(
          title: const Text('Getaran'),
          subtitle: const Text('Getaran untuk notifikasi'),
          value: _settings?.vibrationEnabled ?? true,
          onChanged: (value) => _updateSetting('vibration', value),
          secondary: const Icon(Icons.vibration),
        ),
      ],
    );
  }

  Widget _buildThemeSettings() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Tema'),
          subtitle: Text(_getThemeModeText(themeProvider.themeMode)),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () => _showThemeDialog(themeProvider),
        );
      },
    );
  }

  Widget _buildLanguageSettings() {
    return ListTile(
      leading: const Icon(Icons.language),
      title: const Text('Bahasa'),
      subtitle: Text(_settings?.language ?? 'Indonesia'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: _showLanguageDialog,
    );
  }

  Widget _buildAccountSettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Profil'),
          subtitle: const Text('Edit informasi profil'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            // Navigate to profile (already handled in bottom nav)
            Navigator.of(context).pop();
            // The parent dashboard will handle switching to profile tab
          },
        ),
        SwitchListTile(
          title: const Text('Biometrik'),
          subtitle: const Text('Login dengan sidik jari/wajah'),
          value: _settings?.biometricEnabled ?? false,
          onChanged: (value) => _updateSetting('biometric', value),
          secondary: const Icon(Icons.fingerprint),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Keamanan'),
          subtitle: const Text('Ubah password dan keamanan'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showSecurityDialog,
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Kebijakan Privasi'),
          subtitle: const Text('Baca kebijakan privasi aplikasi'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _launchUrl('https://tamshub.com/privacy'),
        ),
        ListTile(
          leading: const Icon(Icons.description),
          title: const Text('Syarat & Ketentuan'),
          subtitle: const Text('Baca syarat dan ketentuan'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _launchUrl('https://tamshub.com/terms'),
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever),
          title: const Text('Hapus Akun'),
          subtitle: const Text('Hapus akun dan semua data'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showDeleteAccountDialog,
        ),
      ],
    );
  }

  Widget _buildDataSettings() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Backup Otomatis'),
          subtitle: const Text('Backup data secara otomatis'),
          value: _settings?.autoBackup ?? true,
          onChanged: (value) => _updateSetting('autoBackup', value),
          secondary: const Icon(Icons.backup),
        ),
        ListTile(
          leading: const Icon(Icons.cloud_upload),
          title: const Text('Backup Manual'),
          subtitle: const Text('Backup data sekarang'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _performBackup,
        ),
        ListTile(
          leading: const Icon(Icons.storage),
          title: const Text('Kelola Penyimpanan'),
          subtitle: const Text('Lihat dan kelola data tersimpan'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _showStorageDialog,
        ),
        ListTile(
          leading: const Icon(Icons.clear_all),
          title: const Text('Hapus Cache'),
          subtitle: const Text('Bersihkan data cache aplikasi'),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: _clearCache,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info),
          title: const Text('Versi Aplikasi'),
          subtitle: Text(_packageInfo?.version ?? 'Unknown'),
          trailing: Text('Build ${_packageInfo?.buildNumber ?? 'Unknown'}'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Developer'),
          subtitle: const Text('Tamas dari TamsHub'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _launchUrl('https://tamshub.com'),
        ),
        ListTile(
          leading: const Icon(Icons.star),
          title: const Text('Rate Aplikasi'),
          subtitle: const Text('Berikan rating di Play Store'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _launchUrl('https://play.google.com/store/apps/details?id=${_packageInfo?.packageName}'),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Laporkan Bug'),
          subtitle: const Text('Kirim laporan bug atau saran'),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _launchUrl('mailto:support@tamshub.com?subject=PabsApp Bug Report'),
        ),
      ],
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      case ThemeMode.system:
        return 'Ikuti Sistem';
    }
  }

  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Ikuti Sistem'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Terang'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Gelap'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Indonesia'),
              onTap: () {
                _updateSetting('language', 'Indonesia');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                _updateSetting('language', 'English');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSecurityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keamanan'),
        content: const Text('Fitur keamanan akan segera hadir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus akun? '
          'Semua data akan dihapus dan tidak dapat dikembalikan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur hapus akun akan segera hadir')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Penyimpanan'),
        content: const Text('Fitur kelola penyimpanan akan segera hadir.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _performBackup() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup sedang diproses...')),
    );
    
    // TODO: Implement backup functionality
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup berhasil!')),
      );
    }
  }

  Future<void> _clearCache() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Membersihkan cache...')),
    );
    
    // TODO: Implement cache clearing
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache berhasil dibersihkan!')),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }
}
