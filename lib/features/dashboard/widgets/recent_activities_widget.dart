import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget untuk menampilkan aktivitas terbaru
/// Author: Tamas dari TamsHub
/// 
/// Widget ini menampilkan daftar aktivitas terbaru user
/// dari berbagai fitur aplikasi.

class RecentActivitiesWidget extends StatelessWidget {
  final List<ActivityItem> activities;
  final VoidCallback? onViewAll;

  const RecentActivitiesWidget({
    super.key,
    required this.activities,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Aktivitas Terbaru',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (activities.isEmpty)
            _buildEmptyState(context)
          else
            ...activities.take(5).map((activity) => _buildActivityItem(context, activity)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada aktivitas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Mulai gunakan fitur-fitur aplikasi untuk melihat aktivitas',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, ActivityItem activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activity.color.withValues(alpha: 0.1),
          child: Icon(
            activity.icon,
            color: activity.color,
            size: 20,
          ),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.description != null) ...[
              const SizedBox(height: 2),
              Text(
                activity.description!,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatTime(activity.timestamp),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: activity.badge != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: activity.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity.badge!,
                  style: TextStyle(
                    color: activity.color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: activity.onTap,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }
}

/// Model untuk item aktivitas
class ActivityItem {
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  final String? badge;
  final VoidCallback? onTap;

  ActivityItem({
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    required this.timestamp,
    this.badge,
    this.onTap,
  });

  factory ActivityItem.photo({
    required String fileName,
    required DateTime timestamp,
    VoidCallback? onTap,
  }) {
    return ActivityItem(
      title: 'Foto diambil',
      description: fileName,
      icon: Icons.camera_alt,
      color: Colors.blue,
      timestamp: timestamp,
      badge: 'FOTO',
      onTap: onTap,
    );
  }

  factory ActivityItem.video({
    required String fileName,
    required DateTime timestamp,
    VoidCallback? onTap,
  }) {
    return ActivityItem(
      title: 'Video direkam',
      description: fileName,
      icon: Icons.videocam,
      color: Colors.red,
      timestamp: timestamp,
      badge: 'VIDEO',
      onTap: onTap,
    );
  }

  factory ActivityItem.todoAdded({
    required String todoTitle,
    required DateTime timestamp,
    VoidCallback? onTap,
  }) {
    return ActivityItem(
      title: 'Todo ditambahkan',
      description: todoTitle,
      icon: Icons.add_task,
      color: Colors.green,
      timestamp: timestamp,
      badge: 'TODO',
      onTap: onTap,
    );
  }

  factory ActivityItem.todoCompleted({
    required String todoTitle,
    required DateTime timestamp,
    VoidCallback? onTap,
  }) {
    return ActivityItem(
      title: 'Todo diselesaikan',
      description: todoTitle,
      icon: Icons.check_circle,
      color: Colors.green,
      timestamp: timestamp,
      badge: 'SELESAI',
      onTap: onTap,
    );
  }

  factory ActivityItem.expenseAdded({
    required String expenseTitle,
    required double amount,
    required DateTime timestamp,
    VoidCallback? onTap,
  }) {
    return ActivityItem(
      title: 'Pengeluaran dicatat',
      description: '$expenseTitle - ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount)}',
      icon: Icons.account_balance_wallet,
      color: Colors.red,
      timestamp: timestamp,
      badge: 'EXPENSE',
      onTap: onTap,
    );
  }

  factory ActivityItem.pddiktiSearch({
    required String query,
    required int results,
    required DateTime timestamp,
    VoidCallback? onTap,
  }) {
    return ActivityItem(
      title: 'Pencarian PDDIKTI',
      description: '$query - $results hasil',
      icon: Icons.search,
      color: Colors.purple,
      timestamp: timestamp,
      badge: 'PDDIKTI',
      onTap: onTap,
    );
  }

  factory ActivityItem.aiChat({
    required String message,
    required DateTime timestamp,
    VoidCallback? onTap,
  }) {
    return ActivityItem(
      title: 'Chat dengan AI',
      description: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      icon: Icons.smart_toy,
      color: Colors.orange,
      timestamp: timestamp,
      badge: 'AI',
      onTap: onTap,
    );
  }
}
