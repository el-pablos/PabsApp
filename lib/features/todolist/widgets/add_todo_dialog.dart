import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/services/todo_service.dart';
import '../../../core/models/todo_model.dart';
import '../../../providers/auth_provider.dart';

/// Dialog untuk menambah atau edit todo
/// Author: Tamas dari TamsHub
///
/// Dialog ini menyediakan form untuk membuat todo baru atau mengedit
/// todo yang sudah ada dengan opsi lokasi dan prioritas.

class AddTodoDialog extends StatefulWidget {
  final TodoModel? todo;

  const AddTodoDialog({super.key, this.todo});

  @override
  State<AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final TodoService _todoService = TodoService.instance;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _tagsController;

  String _priority = 'medium';
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _includeLocation = false;
  bool _isLoading = false;

  final List<String> _priorities = ['low', 'medium', 'high'];
  final List<String> _priorityLabels = ['Rendah', 'Sedang', 'Tinggi'];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );
    _categoryController = TextEditingController(
      text: widget.todo?.category ?? '',
    );
    _tagsController = TextEditingController(
      text: '', // Tags removed for simplicity
    );

    if (widget.todo != null) {
      _priority = widget.todo!.priority;
      _dueDate = widget.todo!.dueDate;
      _dueTime = widget.todo!.dueDate != null
          ? TimeOfDay.fromDateTime(widget.todo!.dueDate!)
          : null;
      _includeLocation = widget.todo!.locationName != null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.todo != null;

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(isEdit ? Icons.edit : Icons.add, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Todo' : 'Tambah Todo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul *',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Priority
                      DropdownButtonFormField<String>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Prioritas',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: _priorities.asMap().entries.map((entry) {
                          final index = entry.key;
                          final priority = entry.value;
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(_priorityLabels[index]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _priority = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          prefixIcon: Icon(Icons.category),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      TextFormField(
                        controller: _tagsController,
                        decoration: const InputDecoration(
                          labelText: 'Tags (pisahkan dengan koma)',
                          prefixIcon: Icon(Icons.tag),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Due Date
                      InkWell(
                        onTap: _selectDueDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Jatuh Tempo',
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          child: Text(
                            _dueDate != null && _dueTime != null
                                ? DateFormat('dd/MM/yyyy HH:mm').format(
                                    DateTime(
                                      _dueDate!.year,
                                      _dueDate!.month,
                                      _dueDate!.day,
                                      _dueTime!.hour,
                                      _dueTime!.minute,
                                    ),
                                  )
                                : 'Pilih tanggal dan waktu',
                            style: _dueDate != null && _dueTime != null
                                ? null
                                : TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Include Location
                      CheckboxListTile(
                        title: const Text('Sertakan Lokasi Saat Ini'),
                        subtitle: const Text(
                          'Lokasi akan disimpan bersama todo',
                        ),
                        value: _includeLocation,
                        onChanged: (value) {
                          setState(() {
                            _includeLocation = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTodo,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? 'Perbarui' : 'Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: _dueTime ?? TimeOfDay.now(),
      );

      if (time != null) {
        setState(() {
          _dueDate = date;
          _dueTime = time;
        });
      }
    }
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final category = _categoryController.text.trim();
      // final tagsText = _tagsController.text.trim(); // Removed for simplicity

      // Tags removed for simplicity

      DateTime? dueDateTime;
      if (_dueDate != null && _dueTime != null) {
        dueDateTime = DateTime(
          _dueDate!.year,
          _dueDate!.month,
          _dueDate!.day,
          _dueTime!.hour,
          _dueTime!.minute,
        );
      }

      TodoModel result;

      if (widget.todo != null) {
        // Update existing todo
        result = await _todoService.updateTodo(
          todoId: widget.todo!.id,
          title: title,
          description: description.isEmpty ? null : description,
          dueDate: dueDateTime,
          priority: _priority,
          category: category.isEmpty ? null : category,
          // tags: tags, // Removed for simplicity
        );
      } else {
        // Create new todo
        result = await _todoService.createTodo(
          userId: authProvider.userId,
          title: title,
          description: description.isEmpty ? 'No description' : description,
          dueDate: dueDateTime,
          priority: _priority,
          category: category.isEmpty ? 'general' : category,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan todo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
