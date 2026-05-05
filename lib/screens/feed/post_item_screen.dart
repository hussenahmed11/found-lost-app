import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../constants/theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/post_service.dart';
import '../../services/network_helper.dart';
import '../../widgets/app_input.dart';
import '../../widgets/app_button.dart';

class PostItemScreen extends StatefulWidget {
  final VoidCallback? onPostSuccess;

  const PostItemScreen({super.key, this.onPostSuccess});

  @override
  State<PostItemScreen> createState() => _PostItemScreenState();
}

class _PostItemScreenState extends State<PostItemScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _locationController = TextEditingController();
  final PostService _postService = PostService();
  String _type = 'lost';
  File? _image;
  bool _loading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (result != null) {
      setState(() => _image = File(result.path));
    }
  }

  Future<void> _handleSubmit() async {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      _showError('Please enter a title');
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showError('Please enter a description');
      return;
    }
    if (_categoryController.text.trim().isEmpty) {
      _showError('Please enter a category');
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      _showError('Please enter a location');
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      _showError('You must be logged in to post');
      return;
    }

    setState(() => _loading = true);

    // Check connectivity first
    final hasInternet = await NetworkHelper.hasInternetConnection();
    if (!hasInternet && mounted) {
      setState(() => _loading = false);
      final shouldRetry = await NetworkHelper.showNoInternetDialog(context);
      if (shouldRetry) return _handleSubmit();
      return;
    }

    try {
      final postData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _type,
        'category': _categoryController.text.trim(),
        'location': _locationController.text.trim(),
      };

      await _postService.createPost(user.uid, postData, _image?.path);

      if (mounted) {
        // Clear form
        _titleController.clear();
        _descriptionController.clear();
        _categoryController.clear();
        _locationController.clear();
        setState(() {
          _image = null;
          _type = 'lost';
          _loading = false;
        });

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Item posted successfully!'),
              ],
            ),
            backgroundColor: AppColors.secondary,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );

        // Switch to Feed tab
        widget.onPostSuccess?.call();
      }
    } catch (error) {
      if (mounted) {
        setState(() => _loading = false);
        NetworkHelper.showErrorSnackbar(context, error);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            // Lost / Found toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.m),
              ),
              child: Row(
                children: [
                  _buildTypeButton('lost', 'LOST', AppColors.danger),
                  _buildTypeButton('found', 'FOUND', AppColors.secondary),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.m),

            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.l),
                  border: Border.all(
                    color: AppColors.border,
                    style: BorderStyle.solid,
                  ),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.l),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_image!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _image = null),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt,
                              size: 40,
                              color: AppColors.textSecondary.withOpacity(0.6)),
                          const SizedBox(height: 8),
                          const Text(
                            'Add Photo (optional)',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to select from gallery',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.s),

            AppInput(
              label: 'Title *',
              placeholder: 'e.g. Lost Wallet, Found Keys',
              controller: _titleController,
            ),
            AppInput(
              label: 'Description *',
              placeholder: 'Provide more details about the item...',
              controller: _descriptionController,
              maxLines: 4,
              height: 100,
            ),
            AppInput(
              label: 'Category *',
              placeholder: 'Electronics, Bags, IDs, etc.',
              controller: _categoryController,
            ),
            AppInput(
              label: 'Location *',
              placeholder: 'Where was it lost or found?',
              controller: _locationController,
            ),

            const SizedBox(height: AppSpacing.m),
            AppButton(
              title: _loading ? 'Posting...' : 'Post Item',
              onPress: _handleSubmit,
              loading: _loading,
              type: _type == 'lost'
                  ? AppButtonType.danger
                  : AppButtonType.secondary,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, String label, Color activeColor) {
    final isActive = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.s),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.surface : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
