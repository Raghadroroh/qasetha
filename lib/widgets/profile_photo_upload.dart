import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_state_provider.dart';
import '../services/profile_image_service.dart';
import '../services/photo_permission_service.dart';
import '../services/logger_service.dart';
import 'guest_profile_restriction.dart';

class ProfilePhotoUpload extends ConsumerStatefulWidget {
  final String? currentImageUrl;
  final Function(String? imageUrl)? onImageUpdated;
  final double size;
  final bool showEditButton;

  const ProfilePhotoUpload({
    super.key,
    this.currentImageUrl,
    this.onImageUpdated,
    this.size = 120,
    this.showEditButton = true,
  });

  @override
  ConsumerState<ProfilePhotoUpload> createState() => _ProfilePhotoUploadState();
}

class _ProfilePhotoUploadState extends ConsumerState<ProfilePhotoUpload>
    with TickerProviderStateMixin {
  
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _currentImageUrl;
  
  late AnimationController _glowController;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _currentImageUrl = widget.currentImageUrl;
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _glow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _glowController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(ProfilePhotoUpload oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentImageUrl != widget.currentImageUrl) {
      setState(() {
        _currentImageUrl = widget.currentImageUrl;
      });
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isGuest = authState.isGuest;

    return GestureDetector(
      onTap: widget.showEditButton ? (isGuest ? _showGuestRestriction : _showImagePickerOptions) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated glow effect
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                width: widget.size + 8,
                height: widget.size + 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
                          .withValues(alpha: _glow.value * 0.3),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Profile image container
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.2) 
                    : Colors.black.withValues(alpha: 0.1),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: _buildImageWidget(isDarkMode),
            ),
          ),

          // Upload progress indicator
          if (_isUploading)
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.6),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 3,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_uploadProgress * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Edit button (for all users, but with different actions)
          if (widget.showEditButton && !_isUploading)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: isGuest ? _showGuestRestriction : _showImagePickerOptions,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Guest restriction overlay
          if (isGuest)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(bool isDarkMode) {
    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _currentImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100],
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultAvatar(isDarkMode),
      );
    } else {
      return _buildDefaultAvatar(isDarkMode);
    }
  }

  Widget _buildDefaultAvatar(bool isDarkMode) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    
    return Container(
      color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100],
      child: Center(
        child: Text(
          _getInitials(user?.name ?? 'User'),
          style: TextStyle(
            fontSize: widget.size * 0.3,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF667eea),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (nameParts.length == 1 && nameParts[0].isNotEmpty) {
      return nameParts[0][0];
    }
    
    return 'U';
  }

  void _showGuestRestriction() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    GuestProfileRestriction.showProfilePhotoRestriction(context, isDarkMode: isDarkMode);
  }

  void _showImagePickerOptions() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Change Profile Picture',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Options
            _buildOption(
              icon: Icons.camera_alt_rounded,
              title: 'Take Photo',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              isDarkMode: isDarkMode,
            ),
            
            _buildOption(
              icon: Icons.photo_library_rounded,
              title: 'Choose from Gallery',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              isDarkMode: isDarkMode,
            ),
            
            if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
              _buildOption(
                icon: Icons.delete_rounded,
                title: 'Remove Photo',
                onTap: () {
                  Navigator.pop(context);
                  _removePhoto();
                },
                isDarkMode: isDarkMode,
                isDestructive: true,
              ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withValues(alpha: 0.1)
                    : (isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive
                    ? Colors.red
                    : (isDarkMode ? Colors.white : Colors.black87),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDestructive
                    ? Colors.red
                    : (isDarkMode ? Colors.white : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      File? imageFile;
      
      if (source == ImageSource.camera) {
        imageFile = await PhotoPermissionService.pickFromCamera(context);
      } else {
        imageFile = await PhotoPermissionService.pickFromGallery(context);
      }

      if (imageFile != null) {
        await _uploadImage(imageFile);
      }
    } catch (e) {
      LoggerService.error('خطأ في اختيار الصورة: $e');
      _showErrorSnackBar('فشل في اختيار الصورة. حاول مرة أخرى.');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    final authState = ref.read(authStateProvider);
    final user = authState.user;
    
    if (user == null) {
      _showErrorSnackBar('User not found. Please log in again.');
      return;
    }

    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      HapticFeedback.lightImpact();

      final imageUrl = await ProfileImageService.uploadProfileImage(
        imageFile,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      setState(() {
        _currentImageUrl = imageUrl;
        _isUploading = false;
      });

      // Notify parent widget
      if (widget.onImageUpdated != null) {
        widget.onImageUpdated!(imageUrl);
      }

      HapticFeedback.selectionClick();
      _showSuccessSnackBar('Profile picture updated successfully!');

    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      LoggerService.error('Error uploading image: $e');
      
      String errorMessage = 'Failed to upload image. Please try again.';
      if (e.toString().contains('Image size must be less than 5MB')) {
        errorMessage = 'Image size must be less than 5MB. Please choose a smaller image.';
      } else if (e.toString().contains('Only JPG, JPEG, and PNG files are allowed')) {
        errorMessage = 'Only JPG, JPEG, and PNG files are allowed.';
      } else if (e.toString().contains('Invalid or corrupted image file')) {
        errorMessage = 'Invalid or corrupted image file. Please choose another image.';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please check your account status and try again.';
      } else if (e.toString().contains('Profile photos are not available for guest users')) {
        errorMessage = 'Profile photos are available only for registered users.';
      }
      
      _showErrorSnackBar(errorMessage);
    }
  }

  Future<void> _removePhoto() async {
    final authState = ref.read(authStateProvider);
    final user = authState.user;
    
    if (user == null || _currentImageUrl == null) return;

    try {
      await ProfileImageService.deleteProfileImage(user.id);
      
      setState(() {
        _currentImageUrl = null;
      });

      // Notify parent widget
      if (widget.onImageUpdated != null) {
        widget.onImageUpdated!(null);
      }

      _showSuccessSnackBar('Profile picture removed successfully!');

    } catch (e) {
      LoggerService.error('Error removing profile image: $e');
      String errorMessage = 'Failed to remove profile picture. Please try again.';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please check your account status and try again.';
      }
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}