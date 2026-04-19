import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/image_upload_service.dart';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  File? _newImage;
  bool _loading = false;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().profile;
    _nameController.text = profile?['name'] ?? '';
    _currentImageUrl = profile?['profileImage'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (result != null) {
      setState(() => _newImage = File(result.path));
    }
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final user = authProvider.user;
      if (user == null) return;

      final Map<String, dynamic> updates = {'name': name};

      // Upload new profile image if selected via Cloudinary
      if (_newImage != null) {
        final downloadUrl = await ImageUploadService.uploadImage(_newImage!.path);
        if (downloadUrl != null) {
          updates['profileImage'] = downloadUrl;
        }
      }

      await authProvider.updateProfile(updates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $error'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.l),

            // Profile image
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius:
                          BorderRadius.circular(AppRadius.round),
                      boxShadow: AppShadows.medium,
                    ),
                    child: _newImage != null
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.round),
                            child: Image.file(_newImage!, fit: BoxFit.cover),
                          )
                        : _currentImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    AppRadius.round),
                                child: CachedNetworkImage(
                                  imageUrl: _currentImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.textSecondary),
                                  errorWidget: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: AppColors.textSecondary),
                                ),
                              )
                            : const Icon(Icons.person,
                                size: 60,
                                color: AppColors.textSecondary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius:
                            BorderRadius.circular(AppRadius.round),
                        border: Border.all(
                            color: AppColors.surface, width: 3),
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            AppInput(
              label: 'Full Name',
              placeholder: 'Enter your name',
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
            ),

            const SizedBox(height: AppSpacing.s),

            // Email (read-only)
            AppInput(
              label: 'Email',
              placeholder: '',
              controller: TextEditingController(
                text: context.read<AuthProvider>().user?.email ?? '',
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              title: 'Save Changes',
              onPress: _handleSave,
              loading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}
