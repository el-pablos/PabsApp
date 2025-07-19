import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/services/screenshot_service.dart';
import '../../core/widgets/loading_widget.dart';

/// Screenshot Feature Screen
/// Provides website screenshot functionality using Statically API
/// Author: Tamas dari TamsHub
class ScreenshotScreen extends StatefulWidget {
  const ScreenshotScreen({super.key});

  @override
  State<ScreenshotScreen> createState() => _ScreenshotScreenState();
}

class _ScreenshotScreenState extends State<ScreenshotScreen> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String _selectedDevice = 'desktop';
  String _selectedFormat = 'png';
  bool _fullPage = false;
  bool _darkMode = false;
  int? _customWidth;
  int? _customHeight;
  int _quality = 90;
  
  Uint8List? _screenshotBytes;
  String? _originalUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill with example URL for testing
    _urlController.text = 'https://flutter.dev';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _takeScreenshot() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _screenshotBytes = null;
    });

    try {
      final url = _urlController.text.trim();
      
      // Validate parameters
      final validation = ScreenshotService.validateParameters(
        url: url,
        device: _selectedDevice,
        format: _selectedFormat,
        width: _customWidth,
        height: _customHeight,
        quality: _quality,
      );

      if (!validation['isValid']) {
        setState(() {
          _errorMessage = validation['errors'].join('\n');
          _isLoading = false;
        });
        return;
      }

      final result = await ScreenshotService.takeScreenshot(
        url: url,
        device: _selectedDevice,
        fullPage: _fullPage,
        format: _selectedFormat,
        width: _customWidth,
        height: _customHeight,
        quality: _quality,
        darkMode: _darkMode,
      );

      if (result['success']) {
        setState(() {
          _screenshotBytes = result['imageBytes'];
          _originalUrl = url;
          _isLoading = false;
        });
        
        _showSuccessSnackBar('Screenshot berhasil diambil!');
      } else {
        setState(() {
          _errorMessage = result['error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveScreenshot() async {
    if (_screenshotBytes == null || _originalUrl == null) return;

    try {
      final result = await ScreenshotService.saveScreenshot(
        imageBytes: _screenshotBytes!,
        originalUrl: _originalUrl!,
        format: _selectedFormat,
      );

      if (result['success']) {
        _showSuccessSnackBar('Screenshot disimpan ke: ${result['filename']}');
      } else {
        _showErrorSnackBar('Gagal menyimpan screenshot: ${result['error']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error menyimpan screenshot: $e');
    }
  }

  Future<void> _shareScreenshot() async {
    if (_screenshotBytes == null || _originalUrl == null) return;

    try {
      final result = await ScreenshotService.shareScreenshot(
        imageBytes: _screenshotBytes!,
        originalUrl: _originalUrl!,
        format: _selectedFormat,
        subject: 'Screenshot dari PabsApp',
        text: 'Screenshot website: $_originalUrl',
      );

      if (result['success']) {
        _showSuccessSnackBar('Screenshot berhasil dibagikan!');
      } else {
        _showErrorSnackBar('Gagal membagikan screenshot: ${result['error']}');
      }
    } catch (e) {
      _showErrorSnackBar('Error membagikan screenshot: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Screenshot Tool',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // URL Input Section
              _buildUrlInputSection(),
              const SizedBox(height: 24),
              
              // Options Section
              _buildOptionsSection(),
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 24),
              
              // Error Message
              if (_errorMessage != null) _buildErrorMessage(),
              
              // Screenshot Result
              if (_screenshotBytes != null) _buildScreenshotResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrlInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Website URL',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'https://example.com',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'URL tidak boleh kosong';
                }
                if (!ScreenshotService.validateParameters(url: value.trim())['isValid']) {
                  return 'Format URL tidak valid';
                }
                return null;
              },
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Screenshot Options',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Device Selection
            _buildDeviceSelection(),
            const SizedBox(height: 16),
            
            // Format Selection
            _buildFormatSelection(),
            const SizedBox(height: 16),
            
            // Toggle Options
            _buildToggleOptions(),
            const SizedBox(height: 16),
            
            // Quality Slider
            _buildQualitySlider(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Type',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ScreenshotService.getDeviceOptions().entries.map((entry) {
            return ChoiceChip(
              label: Text(
                entry.key.toUpperCase(),
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              selected: _selectedDevice == entry.value,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedDevice = entry.value;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFormatSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Format',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ScreenshotService.getFormatOptions().entries.map((entry) {
            return ChoiceChip(
              label: Text(
                entry.key.toUpperCase(),
                style: GoogleFonts.poppins(fontSize: 12),
              ),
              selected: _selectedFormat == entry.value,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFormat = entry.value;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildToggleOptions() {
    return Column(
      children: [
        SwitchListTile(
          title: Text(
            'Full Page Screenshot',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          subtitle: Text(
            'Capture entire page content',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _fullPage,
          onChanged: (value) {
            setState(() {
              _fullPage = value;
            });
          },
        ),
        SwitchListTile(
          title: Text(
            'Dark Mode',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          subtitle: Text(
            'Force dark mode if supported',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
          value: _darkMode,
          onChanged: (value) {
            setState(() {
              _darkMode = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQualitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quality: ${_quality}%',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Slider(
          value: _quality.toDouble(),
          min: 10,
          max: 100,
          divisions: 9,
          label: '${_quality}%',
          onChanged: (value) {
            setState(() {
              _quality = value.round();
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _takeScreenshot,
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.camera_alt),
            label: Text(
              _isLoading ? 'Taking Screenshot...' : 'Take Screenshot',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        if (_screenshotBytes != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveScreenshot,
                  icon: const Icon(Icons.save),
                  label: Text(
                    'Save',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareScreenshot,
                  icon: const Icon(Icons.share),
                  label: Text(
                    'Share',
                    style: GoogleFonts.poppins(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: GoogleFonts.poppins(
                  color: Colors.red[700],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotResult() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Screenshot Result',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _screenshotBytes!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[100],
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.grey[400], size: 48),
                            const SizedBox(height: 8),
                            Text(
                              'Failed to display image',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'URL: $_originalUrl',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Size: ${(_screenshotBytes!.length / 1024).toStringAsFixed(1)} KB',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
