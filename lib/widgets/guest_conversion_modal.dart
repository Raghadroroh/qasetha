import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../providers/auth_state_provider.dart';
import '../services/theme_service.dart';
import '../utils/validators.dart';

class GuestConversionModal extends ConsumerStatefulWidget {
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const GuestConversionModal({
    super.key,
    this.onSuccess,
    this.onCancel,
  });

  @override
  ConsumerState<GuestConversionModal> createState() => _GuestConversionModalState();
}

class _GuestConversionModalState extends ConsumerState<GuestConversionModal>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleConversion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.convertGuestToRegistered(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        context: context,
      );

      if (!mounted) return;

      if (success) {
        widget.onSuccess?.call();
        Navigator.of(context).pop();
        _showSuccessSnackBar();
      } else {
        final error = ref.read(authStateProvider).error;
        _showErrorSnackBar(error ?? 'حدث خطأ في تحويل الحساب');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('حدث خطأ غير متوقع');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحويل الحساب بنجاح! يرجى تأكيد البريد الإلكتروني'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final guestSession = ref.watch(guestSessionProvider);
    
    return provider.Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final isDarkMode = themeService.isDarkMode;
        final isArabic = themeService.languageCode == 'ar';

        return AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return Container(
              color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
              child: Center(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                const Color(0xFF1A1B3A),
                                const Color(0xFF2D1B69),
                              ]
                            : [
                                Colors.white,
                                const Color(0xFFE8F4F8),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
                            : const Color(0xFF2E7D8A).withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                              : const Color(0xFF2E7D8A).withValues(alpha: 0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDarkMode
                                            ? [
                                                const Color(0xFF00E5FF),
                                                const Color(0xFF2D1B69),
                                              ]
                                            : [
                                                const Color(0xFF2E7D8A),
                                                const Color(0xFF7FB3B3),
                                              ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.account_circle,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isArabic ? 'تحويل إلى حساب مسجل' : 'Convert to Registered Account',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                                          ),
                                        ),
                                        Text(
                                          isArabic 
                                              ? 'احتفظ بجميع بياناتك واحصل على ميزات إضافية'
                                              : 'Keep all your data and get additional features',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode 
                                                ? Colors.white.withValues(alpha: 0.7)
                                                : const Color(0xFF1A4B52).withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      widget.onCancel?.call();
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Guest Stats
                              if (guestSession != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : const Color(0xFF2E7D8A).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode
                                          ? const Color(0xFF00E5FF).withValues(alpha: 0.2)
                                          : const Color(0xFF2E7D8A).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isArabic ? 'إحصائيات الضيف' : 'Guest Statistics',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          _buildStatItem(
                                            icon: Icons.access_time,
                                            label: isArabic ? 'الجلسات' : 'Sessions',
                                            value: '${guestSession.sessionCount}',
                                            isDarkMode: isDarkMode,
                                          ),
                                          const SizedBox(width: 16),
                                          _buildStatItem(
                                            icon: Icons.star_outline,
                                            label: isArabic ? 'الميزات المستخدمة' : 'Features Used',
                                            value: '${guestSession.featuresUsed.length}',
                                            isDarkMode: isDarkMode,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

                              // Form Fields
                              _buildTextField(
                                controller: _nameController,
                                label: isArabic ? 'الاسم الكامل' : 'Full Name',
                                icon: Icons.person,
                                validator: (value) => Validators.validateName(value, context),
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: isArabic ? 'البريد الإلكتروني' : 'Email',
                                icon: Icons.email,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) => Validators.validateEmail(value, context),
                                isDarkMode: isDarkMode,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _passwordController,
                                label: isArabic ? 'كلمة المرور' : 'Password',
                                icon: Icons.lock,
                                obscureText: _obscurePassword,
                                validator: (value) => Validators.validatePassword(value, context),
                                isDarkMode: isDarkMode,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: isDarkMode
                                        ? const Color(0xFF00E5FF)
                                        : const Color(0xFF2E7D8A),
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Benefits Section
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDarkMode
                                        ? [
                                            const Color(0xFF00E5FF).withValues(alpha: 0.1),
                                            const Color(0xFF2D1B69).withValues(alpha: 0.1),
                                          ]
                                        : [
                                            const Color(0xFF2E7D8A).withValues(alpha: 0.1),
                                            const Color(0xFF7FB3B3).withValues(alpha: 0.1),
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isArabic ? 'ستحصل على:' : 'You\'ll get:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...[
                                      isArabic ? 'حفظ البيانات والمفضلات' : 'Save data and favorites',
                                      isArabic ? 'الوصول لجميع الميزات' : 'Access to all features',
                                      isArabic ? 'إشعارات مخصصة' : 'Personalized notifications',
                                      isArabic ? 'نسخ احتياطي للبيانات' : 'Data backup',
                                    ].map((benefit) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: isDarkMode
                                                ? const Color(0xFF00E5FF)
                                                : const Color(0xFF2E7D8A),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            benefit,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode 
                                                  ? Colors.white.withValues(alpha: 0.8)
                                                  : const Color(0xFF1A4B52).withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Action Buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: _isLoading ? null : () {
                                        widget.onCancel?.call();
                                        Navigator.of(context).pop();
                                      },
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: BorderSide(
                                          color: isDarkMode
                                              ? Colors.white.withValues(alpha: 0.3)
                                              : const Color(0xFF2E7D8A).withValues(alpha: 0.3),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        isArabic ? 'إلغاء' : 'Cancel',
                                        style: TextStyle(
                                          color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _handleConversion,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isDarkMode
                                            ? const Color(0xFF00E5FF)
                                            : const Color(0xFF2E7D8A),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              isArabic ? 'تحويل الحساب' : 'Convert Account',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
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
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode 
                    ? Colors.white.withValues(alpha: 0.7)
                    : const Color(0xFF1A4B52).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode
              ? [
                  Colors.white.withValues(alpha: 0.1),
                  Colors.white.withValues(alpha: 0.05),
                ]
              : [
                  Colors.white.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode
              ? const Color(0xFF00E5FF).withValues(alpha: 0.3)
              : const Color(0xFF2E7D8A).withValues(alpha: 0.3),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(
          color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDarkMode 
                ? Colors.white.withValues(alpha: 0.7)
                : const Color(0xFF1A4B52).withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2E7D8A),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}