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
import '../widgets/logout_confirmation_dialog.dart';
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
  late Animation<double> _rotation;
  late Animation<double> _glow;

  UserProfile? _userProfile;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
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
    
    _rotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.linear),
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

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
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
                                
                                // Profile Completion Progress
                                if (_userProfile != null && !isGuest)
                                  _buildProfileCompletionCard(isDarkMode, isArabic),
                                
                                if (_userProfile != null && !isGuest)
                                  const SizedBox(height: 24),
                                
                                // Guest Stats or Regular Stats
                                isGuest 
                                    ? _buildGuestStatsGrid(isDarkMode, isArabic)
                                    : _buildStatsGrid(isDarkMode, isArabic),
                                
                                const SizedBox(height: 24),
                                
                                // Achievement Showcase
                                if (!isGuest)
                                  _buildAchievementShowcase(isDarkMode, isArabic),
                                
                                if (!isGuest)
                                  const SizedBox(height: 24),
                                
                                // Menu Options
                                _buildMenuOptions(isDarkMode, isArabic, context, isGuest),
                                
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
          
          // Floating Action Button
          _buildFloatingActionButton(isDarkMode, isArabic, context),
        ],
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Menu Button
                _buildIconButton(
                  icon: Icons.menu_rounded,
                  onTap: () => Scaffold.of(context).openDrawer(),
                  isDarkMode: isDarkMode,
                ),
                
                // Title
                Text(
                  isArabic ? 'الملف الشخصي' : 'Profile',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                    letterSpacing: 0.5,
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
          // Profile Image with Glow Effect
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
                          .withValues(alpha: _glow.value * 0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Gradient Border
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00E5FF),
                            Color(0xFF2196F3),
                            Color(0xFF9C27B0),
                          ],
                        ),
                      ),
                    ),
                    // Inner Circle
                    Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 56,
                          color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                    // Edit Button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _handleEditProfile();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00E5FF), Color(0xFF2196F3)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2196F3).withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // User Info
          Text(
            _userProfile?.fullName ?? user?.name ?? (isArabic ? 'اسم المستخدم' : 'Username'),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Email
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(
                  _userProfile?.email ?? user?.email ?? 'email@example.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isGuest
                    ? [
                        isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
                        isDarkMode ? const Color(0xFF2196F3) : const Color(0xFF00BCD4),
                      ]
                    : [
                        const Color(0xFFFFD700),
                        const Color(0xFFFFA000),
                      ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: (isGuest
                      ? (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
                      : const Color(0xFFFFD700)).withValues(alpha: 0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGuest ? Icons.person_outline : Icons.star_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isGuest 
                      ? (isArabic ? 'مستخدم ضيف' : 'Guest User')
                      : (isArabic ? 'عضو مميز' : 'PRO Member'),
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

  Widget _buildProfileCompletionCard(bool isDarkMode, bool isArabic) {
    final completion = _userProfile!.profileCompletion;
    final percentage = completion.percentage;
    
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: percentage >= 80 
              ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
              : percentage >= 50 
                  ? const Color(0xFFFF9800).withValues(alpha: 0.3)
                  : const Color(0xFFFF5722).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (percentage >= 80 
                ? const Color(0xFF4CAF50)
                : percentage >= 50 
                    ? const Color(0xFFFF9800)
                    : const Color(0xFFFF5722)).withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: percentage >= 80 
                        ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                        : percentage >= 50 
                            ? [const Color(0xFFFF9800), const Color(0xFFFFB74D)]
                            : [const Color(0xFFFF5722), const Color(0xFFFF7043)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  percentage >= 80 
                      ? Icons.verified_user_rounded
                      : percentage >= 50 
                          ? Icons.person_outline_rounded
                          : Icons.account_circle_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'إكمال الملف الشخصي' : 'Profile Completion',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isArabic 
                          ? '${percentage.toInt()}% مكتمل'
                          : '${percentage.toInt()}% Complete',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (percentage < 100)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _handleEditProfile();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF2196F3)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isArabic ? 'أكمل' : 'Complete',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (context, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (percentage / 100) * _fadeIn.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: percentage >= 80 
                            ? [const Color(0xFF4CAF50), const Color(0xFF66BB6A)]
                            : percentage >= 50 
                                ? [const Color(0xFFFF9800), const Color(0xFFFFB74D)]
                                : [const Color(0xFFFF5722), const Color(0xFFFF7043)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: (percentage >= 80 
                              ? const Color(0xFF4CAF50)
                              : percentage >= 50 
                                  ? const Color(0xFFFF9800)
                                  : const Color(0xFFFF5722)).withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Completion Steps
          if (completion.missingFields.isNotEmpty) ...[
            Text(
              isArabic ? 'خطوات متبقية:' : 'Remaining steps:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: completion.missingFields.take(3).map((field) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDarkMode 
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    _getFieldDisplayName(field, isArabic),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _getFieldDisplayName(String field, bool isArabic) {
    final Map<String, Map<String, String>> fieldNames = {
      'address': {
        'ar': 'العنوان',
        'en': 'Address',
      },
      'employment': {
        'ar': 'معلومات العمل',
        'en': 'Employment Info',
      },
      'phoneNumber': {
        'ar': 'رقم الهاتف',
        'en': 'Phone Number',
      },
      'profileImage': {
        'ar': 'صورة الملف الشخصي',
        'en': 'Profile Picture',
      },
    };
    
    return fieldNames[field]?[isArabic ? 'ar' : 'en'] ?? field;
  }

  Widget _buildStatsGrid(bool isDarkMode, bool isArabic) {
    final stats = [
      {
        'icon': Icons.trending_up_rounded,
        'value': '89%',
        'label': isArabic ? 'النمو' : 'Growth',
        'color': const Color(0xFF00E676),
      },
      {
        'icon': Icons.bolt_rounded,
        'value': '2.4k',
        'label': isArabic ? 'النقاط' : 'Points',
        'color': const Color(0xFFFFD600),
      },
      {
        'icon': Icons.emoji_events_rounded,
        'value': '15',
        'label': isArabic ? 'الإنجازات' : 'Achievements',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': Icons.local_fire_department_rounded,
        'value': '7',
        'label': isArabic ? 'متتالي' : 'Streak',
        'color': const Color(0xFFFF5722),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _buildStatCard(
          icon: stat['icon'] as IconData,
          value: stat['value'] as String,
          label: stat['label'] as String,
          color: stat['color'] as Color,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementShowcase(bool isDarkMode, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [
                  const Color(0xFF9C27B0).withValues(alpha: 0.2),
                  const Color(0xFF2196F3).withValues(alpha: 0.2),
                ]
              : [
                  const Color(0xFF9C27B0).withValues(alpha: 0.1),
                  const Color(0xFF2196F3).withValues(alpha: 0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isArabic ? 'أحدث الإنجازات' : 'Latest Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAchievementBadge(
                icon: Icons.speed_rounded,
                label: isArabic ? 'سريع' : 'Speedster',
                color: const Color(0xFFFF5722),
                isDarkMode: isDarkMode,
              ),
              _buildAchievementBadge(
                icon: Icons.star_rounded,
                label: isArabic ? 'نجم' : 'Star',
                color: const Color(0xFFFFD600),
                isDarkMode: isDarkMode,
              ),
              _buildAchievementBadge(
                icon: Icons.diamond_rounded,
                label: isArabic ? 'ماسي' : 'Diamond',
                color: const Color(0xFF00E5FF),
                isDarkMode: isDarkMode,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _floatingController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, math.sin(_floatingController.value * 2 * math.pi) * 5),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.8),
                      color,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildGuestStatsGrid(bool isDarkMode, bool isArabic) {
    final guestSession = ref.watch(guestSessionProvider);
    
    if (guestSession == null) {
      return const SizedBox.shrink();
    }
    
    final stats = [
      {
        'icon': Icons.access_time,
        'value': '${guestSession.sessionCount}',
        'label': isArabic ? 'الجلسات' : 'Sessions',
        'color': const Color(0xFF00E676),
      },
      {
        'icon': Icons.star_outline,
        'value': '${guestSession.featuresUsed.length}',
        'label': isArabic ? 'الميزات' : 'Features',
        'color': const Color(0xFFFFD600),
      },
      {
        'icon': Icons.schedule,
        'value': '${guestSession.totalDuration.inMinutes}',
        'label': isArabic ? 'دقائق' : 'Minutes',
        'color': const Color(0xFF2196F3),
      },
      {
        'icon': Icons.touch_app,
        'value': '${guestSession.totalActions}',
        'label': isArabic ? 'إجراءات' : 'Actions',
        'color': const Color(0xFFFF5722),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'إحصائيات الضيف' : 'Guest Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              icon: stat['icon'] as IconData,
              value: stat['value'] as String,
              label: stat['label'] as String,
              color: stat['color'] as Color,
              isDarkMode: isDarkMode,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMenuOptions(bool isDarkMode, bool isArabic, BuildContext context, bool isGuest) {
    final options = <Map<String, dynamic>>[
      if (!isGuest) {
        'icon': Icons.person_outline_rounded,
        'title': isArabic ? 'المعلومات الشخصية' : 'Personal Info',
        'gradient': [const Color(0xFF2196F3), const Color(0xFF00BCD4)],
        'onTap': () {
          HapticFeedback.lightImpact();
          _handleEditProfile();
        },
      },
      if (isGuest) {
        'icon': Icons.account_circle_outlined,
        'title': isArabic ? 'إنشاء حساب' : 'Create Account',
        'gradient': [const Color(0xFF00E5FF), const Color(0xFF2196F3)],
        'onTap': () {
          HapticFeedback.lightImpact();
          _showGuestConversionModal(context);
        },
      },
      {
        'icon': Icons.security_rounded,
        'title': isArabic ? 'الأمان والخصوصية' : 'Security & Privacy',
        'gradient': [const Color(0xFF9C27B0), const Color(0xFF673AB7)],
        'onTap': () => HapticFeedback.lightImpact(),
      },
      {
        'icon': Icons.notifications_outlined,
        'title': isArabic ? 'الإشعارات' : 'Notifications',
        'gradient': [const Color(0xFFFF5722), const Color(0xFFFF9800)],
        'onTap': () => HapticFeedback.lightImpact(),
      },
      {
        'icon': Icons.palette_outlined,
        'title': isArabic ? 'المظهر' : 'Appearance',
        'gradient': [const Color(0xFF4CAF50), const Color(0xFF8BC34A)],
        'onTap': () => HapticFeedback.lightImpact(),
      },
      {
        'icon': Icons.help_outline_rounded,
        'title': isArabic ? 'المساعدة' : 'Help & Support',
        'gradient': [const Color(0xFF00BCD4), const Color(0xFF00E5FF)],
        'onTap': () => HapticFeedback.lightImpact(),
      },
      {
        'icon': Icons.logout_rounded,
        'title': isArabic ? 'تسجيل الخروج' : 'Logout',
        'gradient': [const Color(0xFFFF5722), const Color(0xFFE91E63)],
        'onTap': () {
          HapticFeedback.lightImpact();
          _handleLogout();
        },
      },
    ];

    return Column(
      children: [
        // Guest conversion prompt if applicable
        if (isGuest) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF00E5FF).withValues(alpha: 0.2), const Color(0xFF2196F3).withValues(alpha: 0.2)]
                    : [const Color(0xFF00E5FF).withValues(alpha: 0.1), const Color(0xFF2196F3).withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDarkMode ? const Color(0xFF00E5FF).withValues(alpha: 0.3) : const Color(0xFF2196F3).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.star_border,
                  size: 40,
                  color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
                ),
                const SizedBox(height: 12),
                Text(
                  isArabic ? 'فتح جميع الميزات' : 'Unlock All Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isArabic 
                      ? 'إنشاء حساب للوصول إلى جميع الميزات وحفظ بياناتك'
                      : 'Create an account to access all features and save your data',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showGuestConversionModal(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isArabic ? 'إنشاء حساب' : 'Create Account',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
        ...options.map((option) {
          final gradientColors = option['gradient'] as List<Color>;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: option['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: gradientColors.first.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradientColors),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          option['icon'] as IconData,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          option['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: isDarkMode ? Colors.white38 : Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFloatingActionButton(bool isDarkMode, bool isArabic, BuildContext context) {
    return Positioned(
      bottom: 24,
      right: isArabic ? null : 24,
      left: isArabic ? 24 : null,
      child: AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotation.value * 0.5,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF5722),
                    Color(0xFFE91E63),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE91E63).withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    _showLogoutDialog(context, isArabic, isDarkMode);
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  void _showLogoutDialog(BuildContext context, bool isArabic, bool isDarkMode) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF5722), Color(0xFFE91E63)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isArabic ? 'تسجيل الخروج' : 'Logout',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isArabic
                    ? 'هل أنت متأكد من رغبتك في تسجيل الخروج؟'
                    : 'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
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
                        isArabic ? 'إلغاء' : 'Cancel',
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
                          colors: [Color(0xFFFF5722), Color(0xFFE91E63)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE91E63).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          HapticFeedback.heavyImpact();
                          final authNotifier = ref.read(authStateProvider.notifier);
                          await authNotifier.signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          isArabic ? 'تأكيد' : 'Confirm',
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

  void _handleLogout() async {
    await LogoutConfirmationDialog.showWithCallbacks(
      context,
      onConfirm: () async {
        final authNotifier = ref.read(authStateProvider.notifier);
        await authNotifier.signOut();
        if (mounted) {
          // Use GoRouter for navigation
          context.go('/login');
        }
      },
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
                    colors: [Color(0xFF00E5FF), Color(0xFF2196F3)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withValues(alpha: 0.3),
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
                          colors: [Color(0xFF00E5FF), Color(0xFF2196F3)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2196F3).withValues(alpha: 0.4),
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
              const Color(0xFF00E5FF).withValues(alpha: 0.1),
              const Color(0xFF2196F3).withValues(alpha: 0.05),
            ]
          : [
              const Color(0xFF2196F3).withValues(alpha: 0.08),
              const Color(0xFF00BCD4).withValues(alpha: 0.04),
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
          (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
              .withValues(alpha: 0.3),
          (isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3))
              .withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: Offset(x, y), radius: 20));
      
      canvas.drawCircle(Offset(x, y), 3 + (i % 3) * 2, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}