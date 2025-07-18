import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/botcahx_service.dart';
import '../../models/botcahx_model.dart';

/// Screen untuk fitur BotcahX API
/// Author: Tamas dari TamsHub
/// 
/// Screen ini menyediakan interface untuk mengakses berbagai
/// API dari BotcahX seperti AI, tools, dan utilities.

class BotcahXScreen extends StatefulWidget {
  const BotcahXScreen({super.key});

  @override
  State<BotcahXScreen> createState() => _BotcahXScreenState();
}

class _BotcahXScreenState extends State<BotcahXScreen> with TickerProviderStateMixin {
  final BotcahXService _botcahxService = BotcahXService.instance;
  late TabController _tabController;
  
  bool _isLoading = false;
  BotcahXApiInfo? _apiInfo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadApiInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApiInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiInfo = await _botcahxService.getApiInfo();
      setState(() {
        _apiInfo = apiInfo;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal memuat info API: $e');
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
        title: const Text('BotcahX API'),
        actions: [
          IconButton(
            onPressed: _loadApiInfo,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.smart_toy), text: 'AI Chat'),
            Tab(icon: Icon(Icons.download), text: 'Downloader'),
            Tab(icon: Icon(Icons.info), text: 'Info'),
            Tab(icon: Icon(Icons.build), text: 'Tools'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildAITab(),
                _buildDownloaderTab(),
                _buildInfoTab(),
                _buildToolsTab(),
              ],
            ),
    );
  }

  Widget _buildAITab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Features',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Chat GPT
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.chat),
              ),
              title: const Text('Chat dengan GPT'),
              subtitle: const Text('Berbicara dengan AI ChatGPT'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showChatDialog(),
            ),
          ),
          const SizedBox(height: 8),
          
          // Generate Image
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.image),
              ),
              title: const Text('Generate Gambar'),
              subtitle: const Text('Buat gambar dengan AI'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showImageGeneratorDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloaderTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Downloader',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // YouTube Downloader
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.play_arrow, color: Colors.white),
              ),
              title: const Text('YouTube Downloader'),
              subtitle: const Text('Download video dari YouTube'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showYouTubeDownloaderDialog(),
            ),
          ),
          const SizedBox(height: 8),
          
          // TikTok Downloader
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.black,
                child: Icon(Icons.music_note, color: Colors.white),
              ),
              title: const Text('TikTok Downloader'),
              subtitle: const Text('Download video dari TikTok'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showTikTokDownloaderDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Info Gempa
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.warning, color: Colors.white),
              ),
              title: const Text('Info Gempa'),
              subtitle: const Text('Informasi gempa terbaru'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showGempaInfo(),
            ),
          ),
          const SizedBox(height: 8),
          
          // Info Cuaca
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.cloud, color: Colors.white),
              ),
              title: const Text('Info Cuaca'),
              subtitle: const Text('Cek cuaca berdasarkan kota'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showCuacaDialog(),
            ),
          ),
          const SizedBox(height: 8),
          
          // Instagram Stalk
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.purple,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text('Instagram Stalk'),
              subtitle: const Text('Lihat profil Instagram'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showInstagramStalkDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tools',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // QR Generator
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.qr_code),
              ),
              title: const Text('QR Code Generator'),
              subtitle: const Text('Buat QR code dari teks'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showQRGeneratorDialog(),
            ),
          ),
          const SizedBox(height: 8),
          
          // Shortlink
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.link),
              ),
              title: const Text('Shortlink'),
              subtitle: const Text('Perpendek URL panjang'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showShortlinkDialog(),
            ),
          ),
          
          // API Info
          if (_apiInfo != null) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${_apiInfo!.name}'),
                    Text('Version: ${_apiInfo!.version}'),
                    Text('Author: ${_apiInfo!.author}'),
                    if (_apiInfo!.description.isNotEmpty)
                      Text('Description: ${_apiInfo!.description}'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showChatDialog() {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat dengan GPT'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            hintText: 'Masukkan pesan Anda...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = messageController.text.trim();
              if (message.isNotEmpty) {
                Navigator.of(context).pop();
                await _chatWithGPT(message);
              }
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  Future<void> _chatWithGPT(String message) async {
    _showLoadingDialog('Mengirim pesan...');
    
    try {
      final response = await _botcahxService.chatWithGPT(message: message);
      Navigator.of(context).pop(); // Close loading dialog
      
      if (response.success && response.response != null) {
        _showResultDialog('Respon GPT', response.response!);
      } else {
        _showErrorSnackBar(response.message);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading dialog
      _showErrorSnackBar('Gagal mengirim pesan: $e');
    }
  }

  void _showImageGeneratorDialog() {
    _showInfoSnackBar('Fitur Generate Gambar - Coming Soon');
  }

  void _showYouTubeDownloaderDialog() {
    _showInfoSnackBar('Fitur YouTube Downloader - Coming Soon');
  }

  void _showTikTokDownloaderDialog() {
    _showInfoSnackBar('Fitur TikTok Downloader - Coming Soon');
  }

  void _showGempaInfo() {
    _showInfoSnackBar('Fitur Info Gempa - Coming Soon');
  }

  void _showCuacaDialog() {
    _showInfoSnackBar('Fitur Info Cuaca - Coming Soon');
  }

  void _showInstagramStalkDialog() {
    _showInfoSnackBar('Fitur Instagram Stalk - Coming Soon');
  }

  void _showQRGeneratorDialog() {
    _showInfoSnackBar('Fitur QR Generator - Coming Soon');
  }

  void _showShortlinkDialog() {
    _showInfoSnackBar('Fitur Shortlink - Coming Soon');
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: SelectableText(content),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: content));
              _showSuccessSnackBar('Disalin ke clipboard');
            },
            child: const Text('Salin'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
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

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
