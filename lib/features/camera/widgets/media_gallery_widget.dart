import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../../core/services/camera_service.dart';

/// Widget untuk menampilkan galeri media user
/// Author: Tamas dari TamsHub
/// 
/// Widget ini menampilkan grid dari media yang telah diupload user
/// dengan opsi untuk melihat detail dan menghapus media.

class MediaGalleryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> mediaList;
  final VoidCallback? onRefresh;
  final Function(String mediaId, String filePath)? onDelete;

  const MediaGalleryWidget({
    super.key,
    required this.mediaList,
    this.onRefresh,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh?.call();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: mediaList.length,
        itemBuilder: (context, index) {
          final media = mediaList[index];
          return _buildMediaCard(context, media);
        },
      ),
    );
  }

  Widget _buildMediaCard(BuildContext context, Map<String, dynamic> media) {
    final CameraService cameraService = CameraService.instance;
    final isImage = media['file_type'] == 'image';
    final fileName = media['file_name'] ?? 'Unknown';
    final fileSize = cameraService.getFileSize(media['file_size'] ?? 0);
    final createdAt = DateTime.tryParse(media['created_at'] ?? '');
    final formattedDate = createdAt != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt)
        : 'Unknown';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showMediaDetail(context, media),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Thumbnail
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (isImage)
                      CachedNetworkImage(
                        imageUrl: media['file_path'] ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                        ),
                      )
                    else
                      Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey[600],
                          size: 48,
                        ),
                      ),
                    
                    // File Type Indicator
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          isImage ? Icons.image : Icons.videocam,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Media Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileSize,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaDetail(BuildContext context, Map<String, dynamic> media) {
    showDialog(
      context: context,
      builder: (context) => MediaDetailDialog(
        media: media,
        onDelete: onDelete,
      ),
    );
  }
}

/// Dialog untuk menampilkan detail media
class MediaDetailDialog extends StatelessWidget {
  final Map<String, dynamic> media;
  final Function(String mediaId, String filePath)? onDelete;

  const MediaDetailDialog({
    super.key,
    required this.media,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final CameraService cameraService = CameraService.instance;
    final isImage = media['file_type'] == 'image';
    final fileName = media['file_name'] ?? 'Unknown';
    final fileSize = cameraService.getFileSize(media['file_size'] ?? 0);
    final createdAt = DateTime.tryParse(media['created_at'] ?? '');
    final formattedDate = createdAt != null 
        ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt)
        : 'Unknown';

    return Dialog(
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
                  isImage ? Icons.image : Icons.videocam,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Detail Media',
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

          // Media Preview
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[100],
            child: isImage
                ? CachedNetworkImage(
                    imageUrl: media['file_path'] ?? '',
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.error_outline,
                      color: Colors.grey[400],
                      size: 48,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey[600],
                          size: 64,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Video Preview',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Media Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nama File', fileName),
                const SizedBox(height: 8),
                _buildInfoRow('Ukuran', fileSize),
                const SizedBox(height: 8),
                _buildInfoRow('Tipe', isImage ? 'Gambar' : 'Video'),
                const SizedBox(height: 8),
                _buildInfoRow('Dibuat', formattedDate),
                if (media['description'] != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow('Deskripsi', media['description']),
                ],
              ],
            ),
          ),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement download functionality
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur download - Segera Hadir'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _confirmDelete(context);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Hapus'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus media ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDelete?.call(
                media['id']?.toString() ?? '',
                media['file_path'] ?? '',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
