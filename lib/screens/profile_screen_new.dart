import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/theme_service.dart';
import '../services/user_service.dart';
import '../providers/auth_state_provider.dart';
import '../models/user_model.dart';
import '../widgets/guest_banner.dart';
import '../widgets/guest_conversion_modal.dart';
import '../widgets/guest_account_creation_dialog.dart';
import '../widgets/universal_back_handler.dart';
import '../widgets/profile_photo_upload.dart';
import 'dart:math' as math;

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _waveController;
  late AnimationController _glowController;
  
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _scaleIn;
  late Animation<double> _glow;

  UserProfile? _userProfile;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUserProfile();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload user profile when returning to this screen
    _loadUserProfile();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );
    
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 0.7, curve: Curves.easeOutBack)),
    );
    
    _scaleIn = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.3, 0.8, curve: Curves.elasticOut)),
    );
    
    _glow = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _mainController.forward();
    _floatingController.repeat();
    _waveController.repeat();
    _glowController.repeat(reverse: true);
  }

  Future<void> _loadUserProfile() async {
    final authState = ref.read(authStateProvider);
    final user = authState.user;
    
    if (user?.id != null) {
      try {
        final profile = await _userService.getUserProfile(user!.id);
        if (mounted) {
          setState(() {
            _userProfile = profile;
          });
        }
      } catch (e) {
        // Handle error silently
      }
    } else {
      // Guest user - show dialog for profile features
      
      // Show guest user dialog after a brief delay
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGuestUserDialog();
        }
      });
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = provider.Provider.of<ThemeService>(context);
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final isDarkMode = themeService.isDarkMode;
    final isArabic = themeService.languageCode == 'ar';
    final isGuest = ref.watch(isGuestProvider);
    
    return QuickBackHandler(
      fallbackRoute: '/dashboard',
      child: Scaffold(
        backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFF5F7FA),
        body: Stack(
          children: [
            // Animated Background
            _buildAnimatedBackground(isDarkMode),
            
            // Main Content
            CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Modern App Bar
                _buildModernAppBar(isDarkMode, isArabic, themeService),
                
                // Guest Banner
                if (isGuest)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GuestBanner(
                        onConversionPressed: () => _showGuestConversionModal(context),
                      ),
                    ),
                  ),
                
                // Profile Content
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeIn,
                        child: SlideTransition(
                          position: _slideUp,
                          child: ScaleTransition(
                            scale: _scaleIn,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  
                                  // Profile Header Card
                                  _buildProfileHeaderCard(user, isDarkMode, isArabic, isGuest),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Credit Summary Card
                                  _buildCreditSummaryCard(isDarkMode, isArabic),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Personal Information Card
                                  _buildPersonalInfoCard(isDarkMode, isArabic),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Employment Information Card
                                  _buildEmploymentInfoCard(isDarkMode, isArabic),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Action Buttons
                                  _buildActionButtons(isDarkMode, isArabic),
                                  
                                  const SizedBox(height: 80),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            
            // Scroll Indicator
            _buildScrollIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return CustomPaint(
          painter: WaveBackgroundPainter(
            waveAnimation: _waveController.value,
            isDarkMode: isDarkMode,
          ),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }

  Widget _buildModernAppBar(bool isDarkMode, bool isArabic, ThemeService themeService) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      snap: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A1A).withValues(alpha: 0.9),
                    const Color(0xFF2D2D2D).withValues(alpha: 0.8),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.9),
                    const Color(0xFFF5F5F5).withValues(alpha: 0.8),
                  ],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
                  .withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Expanded(
                  child: Center(
                    child: Text(
                      isArabic ? 'الملف الشخصي' : 'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                // Theme Toggle
                _buildIconButton(
                  icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    themeService.toggleTheme();
                  },
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeaderCard(user, bool isDarkMode, bool isArabic, bool isGuest) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2A2A2A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F8F8),
                ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
                .withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Photo Upload Widget
          ProfilePhotoUpload(
            currentImageUrl: _userProfile?.profileImage,
            size: 120,
            showEditButton: true,
            onImageUpdated: (imageUrl) {
              // Refresh user profile when image is updated
              _loadUserProfile();
            },
          ),
          
          const SizedBox(height: 24),
          
          // User Info
          Text(
            _userProfile?.fullName ?? user?.name ?? (isArabic ? 'مستخدم' : 'User'),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Job Title
          if (_userProfile?.employment.jobTitle.isNotEmpty == true)
            Text(
              _userProfile!.employment.jobTitle,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Rating (only show if user has a rating)
          if (_userProfile?.rating != null && _userProfile!.rating > 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  color: Color(0xFFFFD700),
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_userProfile!.rating}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _userProfile!.rating >= 4.5 
                      ? (isArabic ? 'ممتاز' : 'Excellent')
                      : _userProfile!.rating >= 3.5
                          ? (isArabic ? 'جيد' : 'Good')
                          : (isArabic ? 'مقبول' : 'Fair'),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 20),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _userProfile?.isVerified ?? false
                    ? [
                        const Color(0xFF10b981),
                        const Color(0xFF059669),
                      ]
                    : [
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                      ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: (_userProfile?.isVerified ?? false
                      ? const Color(0xFF10b981)
                      : const Color(0xFF667eea)).withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _userProfile?.isVerified ?? false
                      ? Icons.verified_user_rounded
                      : Icons.person_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'متحقق' : 'Verified',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditSummaryCard(bool isDarkMode, bool isArabic) {
    // Only show if user has credit information
    if (_userProfile?.creditLimit == null || _userProfile!.creditLimit <= 0) {
      return const SizedBox.shrink();
    }
    
    final creditLimit = _userProfile!.creditLimit;
    final availableCredit = _userProfile!.availableCredit;
    final usedCredit = creditLimit - availableCredit;
    final usagePercentage = (usedCredit / creditLimit * 100).toStringAsFixed(1);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2A2A2A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F8F8),
                ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
                .withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'ملخص الائتمان' : 'Credit Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Credit Stats
          Row(
            children: [
              // Available Credit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isArabic ? 'الائتمان المتاح' : 'Available Credit',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${availableCredit.toStringAsFixed(0)} ${isArabic ? 'دينار' : 'JOD'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10b981),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Credit Limit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      isArabic ? 'الحد الأقصى' : 'Credit Limit',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${creditLimit.toStringAsFixed(0)} ${isArabic ? 'دينار' : 'JOD'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF667eea),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isArabic ? 'استخدام الائتمان: $usagePercentage%' : 'Credit Usage: $usagePercentage%',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: usedCredit / creditLimit,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF667eea),
                          const Color(0xFF764ba2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(bool isDarkMode, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2A2A2A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F8F8),
                ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
                .withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'المعلومات الشخصية' : 'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // National ID
          if (_userProfile?.nationalId.isNotEmpty == true)
            Column(
              children: [
                _buildInfoItem(
                  label: isArabic ? 'الرقم الوطني' : 'National ID',
                  value: _userProfile!.nationalId,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 12),
              ],
            ),
          
          // Email
          if (_userProfile?.email.isNotEmpty == true)
            Column(
              children: [
                _buildInfoItem(
                  label: isArabic ? 'البريد الإلكتروني' : 'Email',
                  value: _userProfile!.email,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 12),
              ],
            ),
          
          // Phone
          if (_userProfile?.phoneNumber.isNotEmpty == true)
            Column(
              children: [
                _buildInfoItem(
                  label: isArabic ? 'رقم الهاتف' : 'Phone Number',
                  value: _userProfile!.phoneNumber,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 12),
              ],
            ),
          
          // Address
          if (_formatAddress(_userProfile?.address)?.isNotEmpty == true)
            _buildInfoItem(
              label: isArabic ? 'العنوان' : 'Address',
              value: _formatAddress(_userProfile!.address)!,
              isDarkMode: isDarkMode,
            ),
            
          // Show message if no personal info
          if (_userProfile?.nationalId.isEmpty != false && 
              _userProfile?.email.isEmpty != false &&
              _userProfile?.phoneNumber.isEmpty != false &&
              _formatAddress(_userProfile?.address)?.isNotEmpty != true)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                isArabic ? 'لم يتم إضافة المعلومات الشخصية بعد' : 'No personal information added yet',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmploymentInfoCard(bool isDarkMode, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF1E1E1E),
                  const Color(0xFF2A2A2A),
                ]
              : [
                  Colors.white,
                  const Color(0xFFF8F8F8),
                ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
                .withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isArabic ? 'معلومات العمل' : 'Employment Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Show employment info only if user is employed and has data
          if (_userProfile?.employment.isEmployed == true) ...[
            // Employer
            if (_userProfile?.employment.employerName.isNotEmpty == true)
              Column(
                children: [
                  _buildInfoItem(
                    label: isArabic ? 'جهة العمل' : 'Employer',
                    value: _userProfile!.employment.employerName,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            
            // Job Title
            if (_userProfile?.employment.jobTitle.isNotEmpty == true)
              Column(
                children: [
                  _buildInfoItem(
                    label: isArabic ? 'المسمى الوظيفي' : 'Job Title',
                    value: _userProfile!.employment.jobTitle,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            
            // Sector
            if (_userProfile?.employment.sector.isNotEmpty == true && _userProfile!.employment.sector != 'none')
              Column(
                children: [
                  _buildInfoItem(
                    label: isArabic ? 'القطاع' : 'Sector',
                    value: _getSectorName(_userProfile!.employment.sector, isArabic)!,
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            
            // Employee ID
            if (_userProfile?.employment.employeeId?.isNotEmpty == true)
              _buildInfoItem(
                label: isArabic ? 'الرقم الوظيفي' : 'Employee ID',
                value: _userProfile!.employment.employeeId!,
                isDarkMode: isDarkMode,
              ),
          ] else ...[
            // Show message if not employed or no employment info
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                isArabic ? 'لم يتم إضافة معلومات العمل بعد' : 'No employment information added yet',
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white54 : Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDarkMode, bool isArabic) {
    return Column(
      children: [
        // Edit Profile Button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF667eea),
                const Color(0xFF764ba2),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667eea).withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextButton(
            onPressed: () => _handleEditProfile(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        
        // Change Password Button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFf093fb),
                const Color(0xFFf5576c),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFf5576c).withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextButton(
            onPressed: () => _handleChangePassword(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Text(
              isArabic ? 'تغيير كلمة المرور' : 'Change Password',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScrollIndicator() {
    return Positioned(
      left: 10,
      top: MediaQuery.of(context).size.height / 2 - 50,
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, child) {
          return Container(
            width: 4,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 4,
                  height: 30 + (math.sin(_waveController.value * math.pi) * 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667eea),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';
    
    final nameParts = name.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}';
    } else if (nameParts.length == 1 && nameParts[0].isNotEmpty) {
      return nameParts[0][0];
    }
    
    return '';
  }

  String? _formatAddress(Address? address) {
    if (address == null) return null;
    
    final parts = [
      if (address.street.isNotEmpty) address.street,
      if (address.city.isNotEmpty) address.city,
      if (address.governorate.isNotEmpty) address.governorate,
    ];
    
    return parts.join('، ');
  }

  String? _getSectorName(String? sector, bool isArabic) {
    if (sector == null) return null;
    
    switch (sector) {
      case 'public':
        return isArabic ? 'قطاع عام' : 'Public Sector';
      case 'private':
        return isArabic ? 'قطاع خاص' : 'Private Sector';
      default:
        return isArabic ? 'غير محدد' : 'Not Specified';
    }
  }

  void _handleEditProfile() {
    final authState = ref.read(authStateProvider);
    
    if (authState.isGuest) {
      // Show restriction dialog for guest users
      GuestAccountCreationDialog.showProfileRestriction(context);
    } else {
      // Navigate to edit profile for registered users
      context.go('/edit-profile');
    }
  }

  void _handleChangePassword() {
    final authState = ref.read(authStateProvider);
    
    if (authState.isGuest) {
      // Show restriction dialog for guest users
      GuestAccountCreationDialog.showProfileRestriction(context);
    } else {
      // Navigate to security settings for password change
      context.go('/security-settings');
    }
  }

  void _showGuestConversionModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GuestConversionModal(
        onSuccess: () {
          // Handle successful conversion
          setState(() {
            _loadUserProfile();
          });
        },
      ),
    );
  }

  void _showGuestUserDialog() {
    final themeService = provider.Provider.of<ThemeService>(context, listen: false);
    final isDarkMode = themeService.isDarkMode;
    final isArabic = themeService.languageCode == 'ar';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
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
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                isArabic ? 'مرحباً بك!' : 'Welcome!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Message
              Text(
                isArabic 
                    ? 'قم بإنشاء حساب للوصول إلى ميزات الملف الشخصي والاستفادة من جميع الخدمات'
                    : 'Create an account to access profile features and enjoy all our services',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/dashboard');
                      },
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
                        isArabic ? 'لاحقاً' : 'Later',
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
                            color: const Color(0xFF667eea).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          context.go('/login');
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isArabic ? 'إنشاء حساب' : 'Sign Up',
                          style: const TextStyle(
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
}

// Wave Background Painter
class WaveBackgroundPainter extends CustomPainter {
  final double waveAnimation;
  final bool isDarkMode;

  WaveBackgroundPainter({
    required this.waveAnimation,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // First Wave
    final path1 = Path();
    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDarkMode
          ? [
              const Color(0xFF667eea).withValues(alpha: 0.1),
              const Color(0xFF764ba2).withValues(alpha: 0.05),
            ]
          : [
              const Color(0xFF667eea).withValues(alpha: 0.08),
              const Color(0xFF764ba2).withValues(alpha: 0.04),
            ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    path1.moveTo(0, size.height * 0.3);
    
    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(
        i,
        size.height * 0.3 +
            math.sin((i / size.width * 2 * math.pi) + (waveAnimation * 2 * math.pi)) * 30,
      );
    }
    
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();
    
    canvas.drawPath(path1, paint);

    // Second Wave
    final path2 = Path();
    paint.shader = LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: isDarkMode
          ? [
              const Color(0xFF9C27B0).withValues(alpha: 0.08),
              const Color(0xFF673AB7).withValues(alpha: 0.04),
            ]
          : [
              const Color(0xFF9C27B0).withValues(alpha: 0.06),
              const Color(0xFF673AB7).withValues(alpha: 0.03),
            ],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    path2.moveTo(0, size.height * 0.4);
    
    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.4 +
            math.sin((i / size.width * 2 * math.pi) - (waveAnimation * 2 * math.pi)) * 25,
      );
    }
    
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();
    
    canvas.drawPath(path2, paint);

    // Floating Particles
    final particlePaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (math.sin(waveAnimation * 2 * math.pi + i) + 1) / 2 * size.width;
      final y = (math.cos(waveAnimation * 2 * math.pi + i * 2) + 1) / 2 * size.height * 0.5;
      
      particlePaint.shader = RadialGradient(
        colors: [
          (isDarkMode ? const Color(0xFF667eea) : const Color(0xFF667eea))
              .withValues(alpha: 0.3),
          (isDarkMode ? const Color(0xFF667eea) : const Color(0xFF667eea))
              .withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 20));
      
      canvas.drawCircle(Offset(x, y), 3 + (i % 3) * 2, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Profile Background Painter for the animated background behind profile picture
class ProfileBackgroundPainter extends CustomPainter {
  final double animation;

  ProfileBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.1);

    // Draw animated circles
    for (int i = 0; i < 5; i++) {
      final radius = 5 + i * 3.0;
      final x = size.width / 2 + math.cos(animation * 2 * math.pi + i) * 20;
      final y = size.height / 2 + math.sin(animation * 2 * math.pi + i * 1.5) * 20;
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw animated lines
    for (int i = 0; i < 8; i++) {
      final startAngle = i * math.pi / 4 + animation * 2 * math.pi;
      final startX = size.width / 2 + math.cos(startAngle) * 30;
      final startY = size.height / 2 + math.sin(startAngle) * 30;
      
      final endX = size.width / 2 + math.cos(startAngle) * 50;
      final endY = size.height / 2 + math.sin(startAngle) * 50;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}