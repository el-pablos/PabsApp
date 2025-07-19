import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/todo_service.dart';
import '../../core/models/todo_model.dart';
import '../../providers/auth_provider.dart';
import 'widgets/todo_item_widget.dart';
import 'widgets/add_todo_dialog.dart';
// import 'widgets/todo_statistics_widget.dart'; // Removed for simplicity
// Google Maps removed - using device GPS only

/// Screen untuk fitur TodoList
/// Author: Tamas dari TamsHub
///
/// Screen ini menyediakan interface untuk mengelola todo items
/// dengan integrasi lokasi dan statistik.

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen>
    with TickerProviderStateMixin {
  final TodoService _todoService = TodoService.instance;
  late TabController _tabController;

  bool _isLoading = false;
  List<TodoModel> _allTodos = [];
  List<TodoModel> _pendingTodos = [];
  List<TodoModel> _completedTodos = [];
  Map<String, dynamic> _statistics = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTodos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTodos() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final todos = await _todoService.getUserTodos(authProvider.userId);
      final statistics = await _todoService.getTodoStats(authProvider.userId);

      setState(() {
        _allTodos = todos;
        _pendingTodos = todos.where((todo) => !todo.isCompleted).toList();
        _completedTodos = todos.where((todo) => todo.isCompleted).toList();
        _statistics = statistics;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal memuat todos: $e');
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
        title: const Text('TodoList'),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur peta menggunakan GPS device'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.location_on),
            tooltip: 'Lokasi GPS',
          ),
          IconButton(
            onPressed: _loadTodos,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.pending_actions),
              text: 'Pending (${_pendingTodos.length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'Selesai (${_completedTodos.length})',
            ),
            Tab(icon: const Icon(Icons.analytics), text: 'Statistik'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPendingTab(),
                _buildCompletedTab(),
                _buildStatisticsTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoDialog,
        tooltip: 'Tambah Todo',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPendingTab() {
    if (_pendingTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Tidak ada tugas pending',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambah tugas baru untuk memulai',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _pendingTodos.length,
        itemBuilder: (context, index) {
          final todo = _pendingTodos[index];
          return TodoItemWidget(
            todo: todo,
            onToggle: (isCompleted) => _toggleTodoStatus(todo.id, isCompleted),
            onEdit: () => _showEditTodoDialog(todo),
            onDelete: () => _deleteTodo(todo.id),
          );
        },
      ),
    );
  }

  Widget _buildCompletedTab() {
    if (_completedTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada tugas selesai',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Selesaikan tugas untuk melihatnya di sini',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodos,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _completedTodos.length,
        itemBuilder: (context, index) {
          final todo = _completedTodos[index];
          return TodoItemWidget(
            todo: todo,
            onToggle: (isCompleted) => _toggleTodoStatus(todo.id, isCompleted),
            onEdit: () => _showEditTodoDialog(todo),
            onDelete: () => _deleteTodo(todo.id),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: const Center(child: Text('Statistik akan ditampilkan di sini')),
    );
  }

  Future<void> _showAddTodoDialog() async {
    final result = await showDialog<TodoModel>(
      context: context,
      builder: (context) => const AddTodoDialog(),
    );

    if (result != null) {
      await _loadTodos();
      _showSuccessSnackBar('Todo berhasil ditambahkan');
    }
  }

  Future<void> _showEditTodoDialog(TodoModel todo) async {
    final result = await showDialog<TodoModel>(
      context: context,
      builder: (context) => AddTodoDialog(todo: todo),
    );

    if (result != null) {
      await _loadTodos();
      _showSuccessSnackBar('Todo berhasil diperbarui');
    }
  }

  Future<void> _toggleTodoStatus(String todoId, bool isCompleted) async {
    try {
      await _todoService.toggleTodoStatus(todoId);
      await _loadTodos();

      _showSuccessSnackBar(
        isCompleted ? 'Todo ditandai selesai' : 'Todo ditandai belum selesai',
      );
    } catch (e) {
      _showErrorSnackBar('Gagal mengubah status todo: $e');
    }
  }

  Future<void> _deleteTodo(String todoId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus todo ini?'),
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
        await _todoService.deleteTodo(todoId);
        await _loadTodos();
        _showSuccessSnackBar('Todo berhasil dihapus');
      } catch (e) {
        _showErrorSnackBar('Gagal menghapus todo: $e');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
