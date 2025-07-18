import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/camera_service.dart';
import '../../providers/auth_provider.dart';
import 'widgets/media_preview_widget.dart';
import 'widgets/media_gallery_widget.dart';

/// Screen untuk fitur kamera dan media
/// Author: Tamas dari TamsHub
/// 
/// Screen ini menyediakan interface untuk mengambil foto, merekam video,
/// dan mengelola media files dengan preview dan galeri.

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with TickerProviderStateMixin {
  final CameraService _cameraService = CameraService.instance;
  late TabController _tabController;
  
  bool _isLoading = false;
  File? _selectedMedia;
  List<Map<String, dynamic>> _userMedia = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserMedia();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserMedia() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final media = await _cameraService.getUserMedia(authProvider.currentUser!.id);
      setState(() {
        _userMedia = media;
      });
    } catch (e) {
      _showErrorSnackBar('Gagal memuat media: $e');
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
        title: const Text('Foto & Rekam'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt), text: 'Kamera'),
            Tab(icon: Icon(Icons.photo_library), text: 'Galeri'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCameraTab(),
          _buildGalleryTab(),
        ],
      ),
    );
  }

  Widget _buildCameraTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Media Preview
          if (_selectedMedia != null) ...[
            MediaPreviewWidget(
              file: _selectedMedia!,
              onDelete: () {
                setState(() {
                  _selectedMedia = null;
                });
              },
            ),
            const SizedBox(height: 24),
          ],

          // Camera Actions
          _buildCameraActions(),
          
          const SizedBox(height: 24),
          
          // Gallery Actions
          _buildGalleryActions(),
          
          const SizedBox(height: 24),
          
          // Upload Button
          if (_selectedMedia != null) _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildGalleryTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_userMedia.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada media',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ambil foto atau rekam video untuk memulai',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return MediaGalleryWidget(
      mediaList: _userMedia,
      onRefresh: _loadUserMedia,
      onDelete: _deleteMedia,
    );
  }

  Widget _buildCameraActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kamera',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Ambil Foto'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _recordVideo,
                    icon: const Icon(Icons.videocam),
                    label: const Text('Rekam Video'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Galeri',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _pickImageFromGallery,
                    icon: const Icon(Icons.photo),
                    label: const Text('Pilih Foto'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _pickVideoFromGallery,
                    icon: const Icon(Icons.video_library),
                    label: const Text('Pilih Video'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Upload Media',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _uploadMedia,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_isLoading ? 'Mengupload...' : 'Upload ke Cloud'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final photo = await _cameraService.takePhoto();
      if (photo != null) {
        setState(() {
          _selectedMedia = photo;
        });
        _showSuccessSnackBar('Foto berhasil diambil');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal mengambil foto: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _recordVideo() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final video = await _cameraService.recordVideo();
      if (video != null) {
        setState(() {
          _selectedMedia = video;
        });
        _showSuccessSnackBar('Video berhasil direkam');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal merekam video: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final image = await _cameraService.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _selectedMedia = image;
        });
        _showSuccessSnackBar('Foto berhasil dipilih');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih foto: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickVideoFromGallery() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final video = await _cameraService.pickVideoFromGallery();
      if (video != null) {
        setState(() {
          _selectedMedia = video;
        });
        _showSuccessSnackBar('Video berhasil dipilih');
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih video: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadMedia() async {
    if (_selectedMedia == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.currentUser == null) {
      _showErrorSnackBar('User tidak ditemukan');
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final fileName = _cameraService.generateUniqueFileName(_selectedMedia!.path.split('/').last);
      final isImage = _cameraService.isImageFile(fileName);

      // Validate file
      if (!_cameraService.validateFileSize(_selectedMedia!, isImage: isImage)) {
        throw Exception('Ukuran file terlalu besar');
      }

      if (!_cameraService.validateFileFormat(fileName, isImage: isImage)) {
        throw Exception('Format file tidak didukung');
      }

      // Upload to Supabase
      final publicUrl = await _cameraService.uploadToSupabase(
        _selectedMedia!,
        fileName,
        userId: authProvider.currentUser!.id,
      );

      // Save metadata
      await _cameraService.saveMediaMetadata(
        fileName: fileName,
        filePath: publicUrl,
        fileType: isImage ? 'image' : 'video',
        fileSize: _selectedMedia!.lengthSync(),
        userId: authProvider.currentUser!.id,
      );

      setState(() {
        _selectedMedia = null;
      });

      _showSuccessSnackBar('Media berhasil diupload');
      await _loadUserMedia();
    } catch (e) {
      _showErrorSnackBar('Gagal mengupload media: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMedia(String mediaId, String filePath) async {
    try {
      await _cameraService.deleteMedia(mediaId, filePath);
      _showSuccessSnackBar('Media berhasil dihapus');
      await _loadUserMedia();
    } catch (e) {
      _showErrorSnackBar('Gagal menghapus media: $e');
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
