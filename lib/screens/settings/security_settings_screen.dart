import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/biometric_auth_service.dart';

/// شاشة إعدادات الأمان
class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _biometricService = BiometricAuthService();

  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _loadSecuritySettings();
  }

  Future<void> _loadSecuritySettings() async {
    setState(() => _isLoading = true);

    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final isEnabled = await _biometricService.isBiometricEnabled();
      final biometrics = await _biometricService.getAvailableBiometrics();

      setState(() {
        _biometricAvailable = isAvailable;
        _biometricEnabled = isEnabled;
        _availableBiometrics = biometrics;
      });
    } catch (e) {
      _showSnackBar(AppStrings.error, isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleBiometric(bool enable) async {
    setState(() => _isLoading = true);

    try {
      if (enable) {
        final result = await _biometricService.enableBiometric();
        if (result.isSuccess) {
          setState(() => _biometricEnabled = true);
          _showSnackBar(AppStrings.biometricEnabled);
        } else {
          _showSnackBar(result.message, isError: true);
        }
      } else {
        await _biometricService.disableBiometric();
        setState(() => _biometricEnabled = false);
        _showSnackBar('تم إلغاء تفعيل البصمة');
      }
    } catch (e) {
      _showSnackBar(AppStrings.error, isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.securitySettings,
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // قسم البيومترك
                  _buildSectionHeader(
                    title: AppStrings.manageBiometric,
                    icon: Icons.fingerprint,
                  ),

                  const SizedBox(height: 16),

                  // حالة البيومترك
                  _buildSettingCard(
                    title: AppStrings.biometricStatus,
                    subtitle: _biometricEnabled
                        ? AppStrings.enabled
                        : AppStrings.disabled,
                    trailing: Switch(
                      value: _biometricEnabled,
                      onChanged: _biometricAvailable ? _toggleBiometric : null,
                      activeColor: AppColors.primary,
                    ),
                    enabled: _biometricAvailable,
                  ),

                  const SizedBox(height: 16),

                  // أنواع البيومترك المتاحة
                  if (_biometricAvailable) ...[
                    _buildSettingCard(
                      title: 'الأنواع المتاحة',
                      subtitle: _getAvailableBiometricsText(),
                      trailing: const Icon(
                        Icons.info_outline,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],

                  // رسالة عدم التوفر
                  if (!_biometricAvailable)
                    _buildInfoCard(
                      title: AppStrings.biometricNotAvailable,
                      subtitle: AppStrings.biometricNotSetup,
                      icon: Icons.info_outline,
                      color: AppColors.warning,
                    ),

                  const SizedBox(height: 32),

                  // قسم الأمان العام
                  _buildSectionHeader(
                    title: 'الأمان العام',
                    icon: Icons.security,
                  ),

                  const SizedBox(height: 16),

                  // تغيير كلمة المرور
                  _buildSettingCard(
                    title: AppStrings.changePassword,
                    subtitle: 'تحديث كلمة المرور الخاصة بك',
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    onTap: () {
                      // التنقل لشاشة تغيير كلمة المرور
                    },
                  ),

                  const SizedBox(height: 16),

                  // إعدادات OTP
                  _buildSettingCard(
                    title: 'إعدادات رمز التحقق',
                    subtitle: 'إدارة خيارات OTP للعمليات المالية',
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    onTap: () {
                      // التنقل لشاشة إعدادات OTP
                    },
                  ),

                  const SizedBox(height: 32),

                  // معلومات إضافية
                  _buildInfoCard(
                    title: 'نصائح الأمان',
                    subtitle:
                        'استخدم البصمة أو رمز الجهاز لحماية أفضل. في حالة عدم التوفر، سيتم استخدام رمز التحقق OTP.',
                    icon: Icons.lightbulb_outline,
                    color: AppColors.info,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? AppColors.whiteTransparent20
              : AppColors.whiteTransparent20.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: enabled
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 16), trailing],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAvailableBiometricsText() {
    if (_availableBiometrics.isEmpty) return 'غير متاح';

    final names = _availableBiometrics.map((type) {
      switch (type) {
        case BiometricType.face:
          return 'الوجه';
        case BiometricType.fingerprint:
          return 'البصمة';
        case BiometricType.iris:
          return 'العين';
        default:
          return 'رمز الجهاز';
      }
    }).toList();

    return names.join('، ');
  }
}
