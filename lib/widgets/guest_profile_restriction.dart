import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GuestProfileRestriction {
  static void showProfilePhotoRestriction(BuildContext context, {bool isDarkMode = false}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFf5576c).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Profile Photos for Registered Users Only',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                'Create an account to upload and manage your profile picture. This feature helps other users recognize you and builds trust in the community.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Benefits list
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.white.withOpacity(0.05) 
                      : Colors.black.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'With a registered account you can:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBenefit('📸', 'Upload custom profile pictures', isDarkMode),
                    _buildBenefit('🔄', 'Change your photo anytime', isDarkMode),
                    _buildBenefit('🛡️', 'Secure cloud storage', isDarkMode),
                    _buildBenefit('👥', 'Build trust with other users', isDarkMode),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isDarkMode ? Colors.white24 : Colors.black12,
                          ),
                        ),
                      ),
                      child: Text(
                        'Maybe Later',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF667eea).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/signup');
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildBenefit(String emoji, String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showFeatureRestrictionSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$feature is available only for registered users. Create an account to access this feature.',
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFf5576c),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Sign Up',
          textColor: Colors.white,
          onPressed: () => context.go('/signup'),
        ),
      ),
    );
  }
}