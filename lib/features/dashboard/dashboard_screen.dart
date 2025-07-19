import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../camera/camera_screen.dart';
import '../todolist/todolist_screen.dart';
import '../fintech/fintech_screen.dart';
import '../pddikti/pddikti_screen.dart';
import '../botcahx/botcahx_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/dashboard_stats_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/recent_activities_widget.dart';

/// Screen Dashboard utama aplikasi
/// Author: Tamas dari TamsHub
///
/// Screen ini merupakan halaman utama yang menampilkan berbagai fitur
/// aplikasi dalam bentuk grid card yang mudah diakses.

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Sample data for dashboard
  final Map<String, dynamic> _dashboardStats = {
    'media_count': 12,
    'active_todos': 5,
    'today_expenses': 150000,
    'pddikti_searches': 3,
  };

  final List<ActivityItem> _recentActivities = [
    ActivityItem.photo(
      fileName: 'IMG_20250119_001.jpg',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ActivityItem.todoAdded(
      todoTitle: 'Beli groceries',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ActivityItem.expenseAdded(
      expenseTitle: 'Makan siang',
      amount: 25000,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
    ),
  ];

  final List<DashboardFeature> _features = [
    DashboardFeature(
      title: 'Foto & Rekam',
      subtitle: 'Ambil foto dan rekam video',
      icon: Icons.camera_alt_rounded,
      color: Colors.blue,
      isEnabled: AppConstants.featurePhotoEnabled,
    ),
    DashboardFeature(
      title: 'TodoList',
      subtitle: 'Kelola tugas dengan lokasi',
      icon: Icons.task_alt_rounded,
      color: Colors.green,
      isEnabled: AppConstants.featureTodolistEnabled,
    ),
    DashboardFeature(
      title: 'FinTech',
      subtitle: 'Manajemen keuangan',
      icon: Icons.account_balance_wallet_rounded,
      color: Colors.orange,
      isEnabled: AppConstants.featureFintechEnabled,
    ),
    DashboardFeature(
      title: 'PDDIKTI',
      subtitle: 'Cari data mahasiswa & dosen',
      icon: Icons.school_rounded,
      color: Colors.purple,
      isEnabled: AppConstants.featurePddiktiEnabled,
    ),
    DashboardFeature(
      title: 'BotcahX API',
      subtitle: 'Akses 700+ API endpoint',
      icon: Icons.api_rounded,
      color: Colors.red,
      isEnabled: AppConstants.featureBotcahxEnabled,
    ),
    DashboardFeature(
      title: 'Maps',
      subtitle: 'Integrasi Google Maps',
      icon: Icons.map_rounded,
      color: Colors.teal,
      isEnabled: AppConstants.featureMapsEnabled,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(AppConstants.appName),
      actions: [
        // Theme Toggle
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.themeMode == ThemeMode.dark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
            );
          },
        ),

        // Profile Menu
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  authProvider.currentUser?.initials ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onSelected: (value) {
                switch (value) {
                  case 'profile':
                    _showProfile();
                    break;
                  case 'settings':
                    _showSettings();
                    break;
                  case 'logout':
                    _handleLogout();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'profile',
                  child: ListTile(
                    leading: Icon(Icons.person_rounded),
                    title: Text('Profil'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: ListTile(
                    leading: Icon(Icons.settings_rounded),
                    title: Text('Pengaturan'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout_rounded, color: Colors.red),
                    title: Text('Keluar', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildProfile();
      case 2:
        return _buildSettings();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          _buildWelcomeCard(),
          const SizedBox(height: 24),

          // Dashboard Statistics
          DashboardStatsWidget(stats: _dashboardStats),
          const SizedBox(height: 24),

          // Quick Actions
          QuickActionsWidget(onActionTap: _handleQuickAction),
          const SizedBox(height: 24),

          // Recent Activities
          RecentActivitiesWidget(
            activities: _recentActivities,
            onViewAll: () {
              // TODO: Navigate to activities screen
            },
          ),
          const SizedBox(height: 24),

          // Features Grid
          Text(
            'Semua Fitur',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: _features.length,
            itemBuilder: (context, index) {
              return _buildFeatureCard(_features[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.currentUser?.displayName ?? 'User',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jelajahi berbagai fitur menarik yang tersedia',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.waving_hand_rounded,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCard(DashboardFeature feature) {
    return Card(
      child: InkWell(
        onTap: feature.isEnabled ? () => _handleFeatureTap(feature) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: feature.isEnabled
                      ? feature.color.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  feature.icon,
                  size: 28,
                  color: feature.isEnabled ? feature.color : Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                feature.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: feature.isEnabled ? null : Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                feature.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: feature.isEnabled ? Colors.grey[600] : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (!feature.isEnabled)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Segera Hadir',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettings() {
    return const SettingsScreen();
  }

  Widget _buildProfile() {
    return const ProfileScreen();
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Profil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_rounded),
          label: 'Pengaturan',
        ),
      ],
    );
  }

  void _handleFeatureTap(DashboardFeature feature) {
    switch (feature.title) {
      case 'Foto & Rekam':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const CameraScreen()));
        break;
      case 'TodoList':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const TodoListScreen()));
        break;
      case 'FinTech':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const FinTechScreen()));
        break;
      case 'PDDIKTI':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const PDDIKTIScreen()));
        break;
      case 'BotcahX':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const BotcahXScreen()));
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fitur ${feature.title} - Segera Hadir'),
            backgroundColor: feature.color,
          ),
        );
    }
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'take_photo':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const CameraScreen()));
        break;
      case 'add_todo':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const TodoListScreen()));
        break;
      case 'add_expense':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const FinTechScreen()));
        break;
      case 'search_pddikti':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const PDDIKTIScreen()));
        break;
      case 'chat_ai':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const BotcahXScreen()));
        break;
      case 'generate_qr':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const BotcahXScreen()));
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Aksi $action - Segera Hadir')));
    }
  }

  void _showProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Halaman Profil - Segera Hadir')),
    );
  }

  void _showSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Halaman Pengaturan - Segera Hadir')),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    }
  }
}

/// Model untuk fitur dashboard
class DashboardFeature {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isEnabled;

  const DashboardFeature({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isEnabled = true,
  });
}
