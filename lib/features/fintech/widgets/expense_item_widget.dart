import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/expense_model.dart';

/// Simplified widget untuk menampilkan item expense
/// Author: Tamas dari TamsHub

class ExpenseItemWidget extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ExpenseItemWidget({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor().withValues(alpha: 0.1),
          child: Text(
            _getCategoryIcon(),
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.description),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  expense.category,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 16),
                Icon(Icons.payment, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  expense.paymentMethod,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(expense.date),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (expense.locationName != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      expense.locationName!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _getFormattedAmount(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _getCategoryColor(),
              ),
            ),
            if (onEdit != null || onDelete != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  /// Get category icon
  String _getCategoryIcon() {
    switch (expense.category.toLowerCase()) {
      case 'makanan':
        return '🍽️';
      case 'transportasi':
        return '🚗';
      case 'belanja':
        return '🛒';
      case 'hiburan':
        return '🎬';
      case 'kesehatan':
        return '🏥';
      case 'pendidikan':
        return '📚';
      default:
        return '💰';
    }
  }

  /// Get category color
  Color _getCategoryColor() {
    switch (expense.category.toLowerCase()) {
      case 'makanan':
        return Colors.orange;
      case 'transportasi':
        return Colors.blue;
      case 'belanja':
        return Colors.pink;
      case 'hiburan':
        return Colors.purple;
      case 'kesehatan':
        return Colors.red;
      case 'pendidikan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Get formatted amount
  String _getFormattedAmount() {
    return 'Rp ${expense.amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}
