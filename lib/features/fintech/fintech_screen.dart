import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../core/services/expense_service.dart';
import '../../models/expense_model.dart';
import '../../providers/auth_provider.dart';
import 'widgets/expense_item_widget.dart';
import 'widgets/add_expense_dialog.dart';
import 'widgets/expense_statistics_widget.dart';
import 'expense_map_screen.dart';

/// Screen untuk fitur FinTech
/// Author: Tamas dari TamsHub
/// 
/// Screen ini menyediakan interface untuk mengelola pengeluaran
/// dengan integrasi lokasi dan statistik keuangan.

class FinTechScreen extends StatefulWidget {
  const FinTechScreen({super.key});

  @override
  State<FinTechScreen> createState() => _FinTechScreenState();
}

class _FinTechScreenState extends State<FinTechScreen> with TickerProviderStateMixin {
  final ExpenseService _expenseService = ExpenseService.instance;
  late TabController _tabController;
  
  bool _isLoading = false;
  List<ExpenseModel> _allExpenses = [];
  List<ExpenseModel> _todayExpenses = [];
  List<ExpenseModel> _thisMonthExpenses = [];
  ExpenseStatistics? _statistics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadExpenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final expenses = await _expenseService.getUserExpenses(authProvider.currentUser!.id);
      final todayExpenses = await _expenseService.getTodayExpenses(authProvider.currentUser!.id);
      final thisMonthExpenses = await _expenseService.getThisMonthExpenses(authProvider.currentUser!.id);
      final statistics = await _expenseService.getExpenseStatistics(userId: authProvider.currentUser!.id);
      
      setState(() {
        _allExpenses = expenses;
        _todayExpenses = todayExpenses;
        _thisMonthExpenses = thisMonthExpenses;
        _statistics = statistics;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal memuat data pengeluaran: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTech'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExpenseMapScreen(expenses: _allExpenses),
                ),
              );
            },
            icon: const Icon(Icons.map),
            tooltip: 'Lihat di Peta',
          ),
          IconButton(
            onPressed: _loadExpenses,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              icon: const Icon(Icons.today),
              text: 'Hari Ini (${_todayExpenses.length})',
            ),
            Tab(
              icon: const Icon(Icons.calendar_month),
              text: 'Bulan Ini (${_thisMonthExpenses.length})',
            ),
            Tab(
              icon: const Icon(Icons.list),
              text: 'Semua (${_allExpenses.length})',
            ),
            Tab(
              icon: const Icon(Icons.analytics),
              text: 'Statistik',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildExpenseList(_todayExpenses, 'Belum ada pengeluaran hari ini'),
                _buildExpenseList(_thisMonthExpenses, 'Belum ada pengeluaran bulan ini'),
                _buildExpenseList(_allExpenses, 'Belum ada pengeluaran'),
                _buildStatisticsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Pengeluaran',
      ),
    );
  }

  Widget _buildExpenseList(List<ExpenseModel> expenses, String emptyMessage) {
    if (expenses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambah pengeluaran untuk memulai tracking keuangan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Group expenses by date
    final groupedExpenses = <String, List<ExpenseModel>>{};
    for (final expense in expenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(expense.transactionDate);
      groupedExpenses[dateKey] = (groupedExpenses[dateKey] ?? [])..add(expense);
    }

    return RefreshIndicator(
      onRefresh: _loadExpenses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedExpenses.length,
        itemBuilder: (context, index) {
          final dateKey = groupedExpenses.keys.elementAt(index);
          final dayExpenses = groupedExpenses[dateKey]!;
          final totalAmount = dayExpenses.fold<double>(0, (sum, expense) => sum + expense.amount);
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.parse(dateKey)),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalAmount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Expenses for this date
              ...dayExpenses.map((expense) => ExpenseItemWidget(
                expense: expense,
                onEdit: () => _showEditExpenseDialog(expense),
                onDelete: () => _deleteExpense(expense.id),
              )).toList(),
              
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ExpenseStatisticsWidget(
        statistics: _statistics!,
        expenses: _allExpenses,
      ),
    );
  }

  Future<void> _showAddExpenseDialog() async {
    final result = await showDialog<ExpenseModel>(
      context: context,
      builder: (context) => const AddExpenseDialog(),
    );

    if (result != null) {
      await _loadExpenses();
      _showSuccessSnackBar('Pengeluaran berhasil ditambahkan');
    }
  }

  Future<void> _showEditExpenseDialog(ExpenseModel expense) async {
    final result = await showDialog<ExpenseModel>(
      context: context,
      builder: (context) => AddExpenseDialog(expense: expense),
    );

    if (result != null) {
      await _loadExpenses();
      _showSuccessSnackBar('Pengeluaran berhasil diperbarui');
    }
  }

  Future<void> _deleteExpense(String expenseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus pengeluaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _expenseService.deleteExpense(expenseId);
        await _loadExpenses();
        _showSuccessSnackBar('Pengeluaran berhasil dihapus');
      } catch (e) {
        _showErrorSnackBar('Gagal menghapus pengeluaran: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
