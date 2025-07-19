import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/services/profile_service.dart';
import '../../core/models/profile_model.dart';
import '../../core/widgets/loading_widget.dart';

/// Screen untuk mengelola profil user
/// Author: Tamas dari TamsHub
///
/// Screen ini menyediakan interface untuk mengedit profil user,
/// mengupload foto profil, dan mengatur preferensi personal.

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  
  final ProfileService _profileService = ProfileService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  bool _isEditing = false;
  ProfileModel? _profile;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profile = await _profileService.getProfile(authProvider.userId);
      
      if (profile != null) {
        setState(() {
          _profile = profile;
          _nameController.text = profile.name ?? '';
          _emailController.text = profile.email ?? '';
          _bioController.text = profile.bio ?? '';
          _phoneController.text = profile.phone ?? '';
        });
      } else {
        // Create default profile
        _profile = ProfileModel(
          id: authProvider.userId,
          name: authProvider.displayName,
          email: '',
          bio: '',
          phone: '',
          avatarUrl: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _nameController.text = _profile!.name ?? '';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Upload image if selected
      String? avatarUrl = _profile?.avatarUrl;
      if (_selectedImage != null) {
        avatarUrl = await _profileService.uploadAvatar(
          authProvider.userId,
          _selectedImage!,
        );
      }

      final updatedProfile = ProfileModel(
        id: authProvider.userId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        bio: _bioController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: avatarUrl,
        createdAt: _profile?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _profileService.saveProfile(updatedProfile);
      
      setState(() {
        _profile = updatedProfile;
        _isEditing = false;
        _selectedImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _profile == null) {
      return const Scaffold(
        body: Center(child: SimpleLoadingWidget()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          if (_isEditing) ...[
            TextButton(
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _selectedImage = null;
                  // Reset form
                  _nameController.text = _profile?.name ?? '';
                  _emailController.text = _profile?.email ?? '';
                  _bioController.text = _profile?.bio ?? '';
                  _phoneController.text = _profile?.phone ?? '';
                });
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: const Text('Simpan'),
            ),
          ] else ...[
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Profil',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Section
              _buildAvatarSection(),
              const SizedBox(height: 32),

              // Profile Form
              _buildProfileForm(),
              
              const SizedBox(height: 32),

              // Theme Toggle
              _buildThemeSection(),
              
              const SizedBox(height: 32),

              // Logout Button
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : (_profile?.avatarUrl != null
                    ? NetworkImage(_profile!.avatarUrl!)
                    : null) as ImageProvider?,
            child: (_selectedImage == null && _profile?.avatarUrl == null)
                ? Text(
                    _profile?.name?.substring(0, 1).toUpperCase() ?? 'U',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : null,
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  iconSize: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        // Name Field
        TextFormField(
          controller: _nameController,
          enabled: _isEditing,
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Email Field
        TextFormField(
          controller: _emailController,
          enabled: _isEditing,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Format email tidak valid';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Phone Field
        TextFormField(
          controller: _phoneController,
          enabled: _isEditing,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Nomor Telepon',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        const SizedBox(height: 16),

        // Bio Field
        TextFormField(
          controller: _bioController,
          enabled: _isEditing,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Bio',
            prefixIcon: Icon(Icons.info),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSection() {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema Aplikasi',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.palette),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<ThemeMode>(
                        value: themeProvider.themeMode,
                        decoration: const InputDecoration(
                          labelText: 'Mode Tema',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('Ikuti Sistem'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Terang'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Gelap'),
                          ),
                        ],
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            themeProvider.setThemeMode(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (shouldLogout == true) {
                      await authProvider.signOut();
                    }
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        );
      },
    );
  }
}
