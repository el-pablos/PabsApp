import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/todo_model.dart';

/// Widget untuk menampilkan item todo
/// Author: Tamas dari TamsHub
///
/// Widget ini menampilkan informasi todo dengan checkbox, prioritas,
/// lokasi, dan aksi untuk edit/delete.

class TodoItemWidget extends StatelessWidget {
  final TodoModel todo;
  final Function(bool) onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with checkbox and priority
              Row(
                children: [
                  Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) => onToggle(value ?? false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      todo.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: todo.isCompleted ? Colors.grey[600] : null,
                      ),
                    ),
                  ),
                  _buildPriorityChip(),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          onEdit?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Description
              if (todo.description != null && todo.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  todo.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: todo.isCompleted
                        ? Colors.grey[500]
                        : Colors.grey[700],
                  ),
                ),
              ],

              // Tags
              if (todo.tags != null && todo.tags!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: todo.tags!
                      .map((tag) => _buildTagChip(tag))
                      .toList(),
                ),
              ],

              // Footer with due date, location, and category
              const SizedBox(height: 12),
              Row(
                children: [
                  // Due Date
                  if (todo.dueDate != null) ...[
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: todo.isOverdue
                          ? Colors.red
                          : todo.isDueToday
                          ? Colors.orange
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(todo.dueDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: todo.isOverdue
                            ? Colors.red
                            : todo.isDueToday
                            ? Colors.orange
                            : Colors.grey[600],
                        fontWeight: todo.isOverdue || todo.isDueToday
                            ? FontWeight.bold
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],

                  // Location
                  if (todo.location != null) ...[
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        todo.location!.address ??
                            '${todo.location!.latitude.toStringAsFixed(4)}, ${todo.location!.longitude.toStringAsFixed(4)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    const Spacer(),
                  ],

                  // Category
                  if (todo.category != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        todo.category!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Overdue warning
              if (todo.isOverdue && !todo.isCompleted) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Terlambat',
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    Color color;
    IconData icon;

    switch (todo.priorityEnum) {
      case TodoPriority.high:
        color = Colors.red;
        icon = Icons.keyboard_arrow_up;
        break;
      case TodoPriority.medium:
        color = Colors.orange;
        icon = Icons.remove;
        break;
      case TodoPriority.low:
        color = Colors.green;
        icon = Icons.keyboard_arrow_down;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 2),
          Text(
            todo.priority.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(tag, style: TextStyle(color: Colors.blue[700], fontSize: 10)),
    );
  }
}
