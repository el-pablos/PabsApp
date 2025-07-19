import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../core/services/environment_service.dart';
import '../../core/services/botcahx_service.dart';
import '../../core/services/pddikti_service.dart';
import '../../core/widgets/loading_widget.dart';

/// Screen untuk debugging dan testing API
/// Author: Tamas dari TamsHub
///
/// Screen ini menyediakan tools untuk testing API endpoints,
/// debugging responses, dan monitoring API performance

class ApiDebugScreen extends StatefulWidget {
  const ApiDebugScreen({super.key});

  @override
  State<ApiDebugScreen> createState() => _ApiDebugScreenState();
}

class _ApiDebugScreenState extends State<ApiDebugScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _headersController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  
  String _selectedMethod = 'GET';
  bool _isLoading = false;
  String? _response;
  int? _statusCode;
  Map<String, String>? _responseHeaders;
  Duration? _responseTime;
  
  final List<String> _methods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];
  final List<Map<String, String>> _presetEndpoints = [
    {
      'name': 'BotcahX API Info',
      'url': 'https://api.botcahx.eu.org',
      'method': 'GET',
    },
    {
      'name': 'PDDIKTI Search',
      'url': 'https://api-frontend.kemdikbud.go.id/hit_mhs',
      'method': 'GET',
    },
    {
      'name': 'JSONPlaceholder Test',
      'url': 'https://jsonplaceholder.typicode.com/posts/1',
      'method': 'GET',
    },
    {
      'name': 'HTTPBin Test',
      'url': 'https://httpbin.org/get',
      'method': 'GET',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _loadPresetEndpoint(0); // Load first preset
  }
  
  void _loadPresetEndpoint(int index) {
    if (index < _presetEndpoints.length) {
      final preset = _presetEndpoints[index];
      setState(() {
        _urlController.text = preset['url']!;
        _selectedMethod = preset['method']!;
        _headersController.text = '{"User-Agent": "PabsApp/1.0", "Content-Type": "application/json"}';
        _bodyController.clear();
        _response = null;
        _statusCode = null;
        _responseHeaders = null;
        _responseTime = null;
      });
    }
  }
  
  Future<void> _sendRequest() async {
    if (_urlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a URL')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _response = null;
      _statusCode = null;
      _responseHeaders = null;
      _responseTime = null;
    });
    
    try {
      final stopwatch = Stopwatch()..start();
      
      // Parse headers
      Map<String, String> headers = {};
      if (_headersController.text.isNotEmpty) {
        try {
          final headersJson = jsonDecode(_headersController.text) as Map<String, dynamic>;
          headers = headersJson.map((key, value) => MapEntry(key, value.toString()));
        } catch (e) {
          headers = {'User-Agent': 'PabsApp/1.0'};
        }
      }
      
      // Send request
      http.Response response;
      final uri = Uri.parse(_urlController.text);
      
      switch (_selectedMethod) {
        case 'GET':
          response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
          ).timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
          ).timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers).timeout(const Duration(seconds: 30));
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: _bodyController.text.isNotEmpty ? _bodyController.text : null,
          ).timeout(const Duration(seconds: 30));
          break;
        default:
          throw Exception('Unsupported method: $_selectedMethod');
      }
      
      stopwatch.stop();
      
      setState(() {
        _statusCode = response.statusCode;
        _responseHeaders = response.headers;
        _responseTime = stopwatch.elapsed;
        
        // Try to format JSON response
        try {
          final jsonResponse = jsonDecode(response.body);
          _response = const JsonEncoder.withIndent('  ').convert(jsonResponse);
        } catch (e) {
          _response = response.body;
        }
      });
      
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _statusCode = null;
        _responseHeaders = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _copyResponse() {
    if (_response != null) {
      Clipboard.setData(ClipboardData(text: _response!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response copied to clipboard')),
      );
    }
  }
  
  void _clearAll() {
    setState(() {
      _urlController.clear();
      _headersController.clear();
      _bodyController.clear();
      _response = null;
      _statusCode = null;
      _responseHeaders = null;
      _responseTime = null;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Debug Tool'),
        actions: [
          IconButton(
            onPressed: _clearAll,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
          ),
          IconButton(
            onPressed: _showEnvironmentInfo,
            icon: const Icon(Icons.info),
            tooltip: 'Environment Info',
          ),
        ],
      ),
      body: Column(
        children: [
          // Preset Endpoints
          _buildPresetEndpoints(),
          
          // Request Configuration
          Expanded(
            flex: 2,
            child: _buildRequestConfiguration(),
          ),
          
          // Send Button
          _buildSendButton(),
          
          // Response Section
          Expanded(
            flex: 3,
            child: _buildResponseSection(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPresetEndpoints() {
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _presetEndpoints.length,
        itemBuilder: (context, index) {
          final preset = _presetEndpoints[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(preset['name']!),
              onPressed: () => _loadPresetEndpoint(index),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildRequestConfiguration() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Method and URL
          Row(
            children: [
              DropdownButton<String>(
                value: _selectedMethod,
                onChanged: (value) => setState(() => _selectedMethod = value!),
                items: _methods.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://api.example.com/endpoint',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Headers
          TextField(
            controller: _headersController,
            decoration: const InputDecoration(
              labelText: 'Headers (JSON)',
              hintText: '{"Authorization": "Bearer token"}',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          
          // Body (for POST, PUT, PATCH)
          if (_selectedMethod != 'GET' && _selectedMethod != 'DELETE')
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Request Body',
                hintText: '{"key": "value"}',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
        ],
      ),
    );
  }
  
  Widget _buildSendButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _sendRequest,
          icon: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send),
          label: Text(_isLoading ? 'Sending...' : 'Send Request'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }
  
  Widget _buildResponseSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Response Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Response',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_statusCode != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_statusCode!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$_statusCode',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (_responseTime != null)
                  Text(
                    '${_responseTime!.inMilliseconds}ms',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                if (_response != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _copyResponse,
                    icon: const Icon(Icons.copy, size: 16),
                    tooltip: 'Copy Response',
                  ),
                ],
              ],
            ),
          ),
          
          // Response Body
          Expanded(
            child: _response != null
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      _response!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'No response yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.orange;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.red;
    } else if (statusCode >= 500) {
      return Colors.purple;
    } else {
      return Colors.grey;
    }
  }
  
  void _showEnvironmentInfo() {
    final config = EnvironmentService.getConfigurationSummary();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Environment Configuration'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('App: ${config['app_name']} v${config['app_version']}'),
              Text('Author: ${config['app_author']}'),
              Text('Debug Mode: ${config['debug_mode']}'),
              Text('Log Level: ${config['log_level']}'),
              const SizedBox(height: 16),
              const Text('API Keys Status:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(config['api_keys_configured'] as Map<String, bool>).entries.map(
                (entry) => Text('${entry.key}: ${entry.value ? '✓ Configured' : '✗ Not configured'}'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _urlController.dispose();
    _headersController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
