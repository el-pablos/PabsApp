import 'package:flutter/material.dart';

/// Widget untuk quick actions di dashboard
/// Author: Tamas dari TamsHub
///
/// Widget ini menampilkan tombol-tombol aksi cepat untuk
/// fitur-fitur yang sering digunakan.

class QuickActionsWidget extends StatelessWidget {
  final Function(String action) onActionTap;

  const QuickActionsWidget({super.key, required this.onActionTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aksi Cepat',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Quick Actions Row
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Ambil Foto',
                  Icons.camera_alt,
                  Colors.blue,
                  'take_photo',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Tambah Todo',
                  Icons.add_task,
                  Colors.green,
                  'add_todo',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Catat Expense',
                  Icons.add_circle,
                  Colors.red,
                  'add_expense',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second Row
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Cari PDDIKTI',
                  Icons.search,
                  Colors.purple,
                  'search_pddikti',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Chat AI',
                  Icons.smart_toy,
                  Colors.orange,
                  'chat_ai',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'QR Code',
                  Icons.qr_code,
                  Colors.teal,
                  'generate_qr',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Fourth Row
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Lokasi',
                  Icons.location_on,
                  Colors.green,
                  'location',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'API Debug',
                  Icons.bug_report,
                  Colors.deepOrange,
                  'debug',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Container()), // Empty space
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String action,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => onActionTap(action),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
