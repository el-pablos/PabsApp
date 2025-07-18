import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/services/expense_service.dart';
import '../../../models/expense_model.dart';
import '../../../providers/auth_provider.dart';

/// Dialog untuk menambah atau edit expense
/// Author: Tamas dari TamsHub
/// 
/// Dialog ini menyediakan form untuk membuat expense baru atau mengedit
/// expense yang sudah ada dengan opsi lokasi dan kategori.

class AddExpenseDialog extends StatefulWidget {
  final ExpenseModel? expense;

  const AddExpenseDialog({super.key, this.expense});

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final ExpenseService _expenseService = ExpenseService.instance;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;

  String _category = 'food';
  String _paymentMethod = 'cash';
  DateTime _transactionDate = DateTime.now();
  bool _includeLocation = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'food',
    'transportation',
    'shopping',
    'entertainment',
    'health',
    'education',
    'others',
  ];

  final Map<String, String> _categoryLabels = {
    'food': 'Makanan & Minuman',
    'transportation': 'Transportasi',
    'shopping': 'Belanja',
    'entertainment': 'Hiburan',
    'health': 'Kesehatan',
    'education': 'Pendidikan',
    'others': 'Lainnya',
  };

  final List<String> _paymentMethods = ['cash', 'card', 'transfer', 'ewallet'];
  final Map<String, String> _paymentMethodLabels = {
    'cash': 'Tunai',
    'card': 'Kartu',
    'transfer': 'Transfer',
    'ewallet': 'E-Wallet',
  };

  @override
  void initState() {
    super.initState();
    
    _titleController = TextEditingController(text: widget.expense?.title ?? '');
    _descriptionController = TextEditingController(text: widget.expense?.description ?? '');
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );

    if (widget.expense != null) {
      _category = widget.expense!.category;
      _paymentMethod = widget.expense!.paymentMethod;
      _transactionDate = widget.expense!.transactionDate;
      _includeLocation = widget.expense!.location != null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.expense != null;
    
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
                  Icon(
                    isEdit ? Icons.edit : Icons.add,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Pengeluaran' : 'Tambah Pengeluaran',
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

                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah *',
                          prefixIcon: Icon(Icons.attach_money),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Jumlah wajib diisi';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Jumlah harus berupa angka positif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        value: _category,
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_categoryLabels[category]!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _category = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Payment Method
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Metode Pembayaran',
                          prefixIcon: Icon(Icons.payment),
                        ),
                        items: _paymentMethods.map((method) {
                          return DropdownMenuItem(
                            value: method,
                            child: Text(_paymentMethodLabels[method]!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _paymentMethod = value!;
                          });
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

                      // Transaction Date
                      InkWell(
                        onTap: _selectTransactionDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Transaksi',
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(_transactionDate),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Include Location
                      CheckboxListTile(
                        title: const Text('Sertakan Lokasi Saat Ini'),
                        subtitle: const Text('Lokasi akan disimpan bersama pengeluaran'),
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
                      onPressed: _isLoading ? null : _saveExpense,
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

  Future<void> _selectTransactionDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_transactionDate),
      );

      if (time != null) {
        setState(() {
          _transactionDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final amount = double.parse(_amountController.text);

      ExpenseModel result;
      
      if (widget.expense != null) {
        // Update existing expense
        result = await _expenseService.updateExpense(
          expenseId: widget.expense!.id,
          title: title,
          description: description.isEmpty ? null : description,
          amount: amount,
          category: _category,
          paymentMethod: _paymentMethod,
          transactionDate: _transactionDate,
        );
      } else {
        // Create new expense
        result = await _expenseService.createExpense(
          userId: authProvider.currentUser!.id,
          title: title,
          description: description.isEmpty ? null : description,
          amount: amount,
          category: _category,
          paymentMethod: _paymentMethod,
          transactionDate: _transactionDate,
          includeCurrentLocation: _includeLocation,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan pengeluaran: $e'),
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
