import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart' as provider;
import '../services/theme_service.dart';
import '../services/user_service.dart';
import '../providers/auth_state_provider.dart';
import '../models/user_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Controllers for user info
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Controllers for address
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _governorateController = TextEditingController();
  
  // Controllers for employment
  final _employerNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  
  // State variables
  bool _isLoading = false;
  bool _isEmployed = false;
  String _employmentSector = 'none';
  UserProfile? _userProfile;
  
  final UserService _userService = UserService();
  
  final List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'البحر الأحمر',
    'البحيرة',
    'الفيوم',
    'الغربية',
    'الإسماعيلية',
    'المنوفية',
    'المنيا',
    'القليوبية',
    'الوادي الجديد',
    'السويس',
    'أسوان',
    'أسيوط',
    'بني سويف',
    'بورسعيد',
    'دمياط',
    'الشرقية',
    'جنوب سيناء',
    'كفر الشيخ',
    'مطروح',
    'الأقصر',
    'قنا',
    'شمال سيناء',
    'سوهاج',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _governorateController.dispose();
    _employerNameController.dispose();
    _jobTitleController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final profile = await _userService.getUserProfile(user.uid);
        
        if (profile != null && mounted) {
          setState(() {
            _userProfile = profile;
            
            // Populate controllers with UserProfile data
            _fullNameController.text = profile.fullName;
            _phoneNumberController.text = profile.phoneNumber;
            _emailController.text = profile.email;
            
            // Address data
            _streetController.text = profile.address.street;
            _cityController.text = profile.address.city;
            _governorateController.text = profile.address.governorate;
            
            // Employment data
            _isEmployed = profile.employment.isEmployed;
            _employmentSector = profile.employment.sector;
            _employerNameController.text = profile.employment.employerName;
            _jobTitleController.text = profile.employment.jobTitle;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('حدث خطأ في تحميل البيانات');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Prepare update data with proper structure
        final updateData = {
          'fullName': _fullNameController.text.trim(),
          'phoneNumber': _phoneNumberController.text.trim(),
          'address': {
            'street': _streetController.text.trim(),
            'city': _cityController.text.trim(),
            'governorate': _governorateController.text.trim(),
            'postalCode': _userProfile?.address.postalCode ?? '',
          },
          'employment': {
            'isEmployed': _isEmployed,
            'sector': _employmentSector,
            'employerName': _employerNameController.text.trim(),
            'jobTitle': _jobTitleController.text.trim(),
            'employeeId': _userProfile?.employment.employeeId,
          },
          'updatedAt': DateTime.now(),
        };

        // Calculate and update profile completion
        await _updateProfileCompletion(updateData);

        // Update using UserService
        await _userService.updateUserProfile(user.uid, updateData);

        if (mounted) {
          _showSuccessSnackBar('تم تحديث الملف الشخصي بنجاح');
          
          // Update auth state
          final authNotifier = ref.read(authStateProvider.notifier);
          await authNotifier.checkEmailVerification();
          
          // Navigate back
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('حدث خطأ في تحديث البيانات');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfileCompletion(Map<String, dynamic> updateData) async {
    if (_userProfile == null) return;

    // Calculate completion based on filled fields
    List<String> missingFields = [];
    
    // Check basic info
    bool isBasicComplete = updateData['fullName'].toString().isNotEmpty && 
                          updateData['phoneNumber'].toString().isNotEmpty;
    if (!isBasicComplete) {
      if (updateData['fullName'].toString().isEmpty) missingFields.add('fullName');
      if (updateData['phoneNumber'].toString().isEmpty) missingFields.add('phoneNumber');
    }

    // Check address info
    final address = updateData['address'] as Map<String, dynamic>;
    bool isAddressComplete = address['street'].toString().isNotEmpty && 
                            address['city'].toString().isNotEmpty && 
                            address['governorate'].toString().isNotEmpty;
    if (!isAddressComplete) missingFields.add('address');

    // Check employment info (if employed)
    final employment = updateData['employment'] as Map<String, dynamic>;
    bool isEmploymentComplete = true;
    if (employment['isEmployed'] == true) {
      isEmploymentComplete = employment['employerName'].toString().isNotEmpty && 
                            employment['jobTitle'].toString().isNotEmpty;
      if (!isEmploymentComplete) missingFields.add('employment');
    }

    // Calculate percentage
    int totalSteps = 3; // basic, address, employment
    int completedSteps = 0;
    if (isBasicComplete) completedSteps++;
    if (isAddressComplete) completedSteps++;
    if (isEmploymentComplete) completedSteps++;

    double percentage = (completedSteps / totalSteps) * 100;

    // Update profile completion data
    updateData['profileCompletion'] = {
      'percentage': percentage,
      'missingFields': missingFields,
      'hasSeenWelcomeModal': _userProfile!.profileCompletion.hasSeenWelcomeModal,
      'lastPromptDate': DateTime.now(),
      'isBasicInfoComplete': isBasicComplete,
      'isEmploymentInfoComplete': isEmploymentComplete,
      'isAddressInfoComplete': isAddressComplete,
      'hasProfileImage': _userProfile!.profileCompletion.hasProfileImage,
    };
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = provider.Provider.of<ThemeService>(context);
    final isDarkMode = themeService.isDarkMode;
    final isArabic = themeService.languageCode == 'ar';

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0A0A0A) : const Color(0xFFFAFAFA),
      appBar: _buildAppBar(isDarkMode, isArabic),
      body: _isLoading 
          ? _buildLoadingState(isDarkMode, isArabic)
          : _buildEditForm(isDarkMode, isArabic),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode, bool isArabic) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_rounded,
          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      title: Text(
        isArabic ? 'تعديل الملف الشخصي' : 'Edit Profile',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      actions: [
        if (!_isLoading)
          TextButton(
            onPressed: _updateProfile,
            child: Text(
              isArabic ? 'حفظ' : 'Save',
              style: TextStyle(
                color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState(bool isDarkMode, bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
          ),
          const SizedBox(height: 16),
          Text(
            isArabic ? 'جاري تحميل البيانات...' : 'Loading data...',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm(bool isDarkMode, bool isArabic) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            _buildProfilePictureSection(isDarkMode, isArabic),
            
            const SizedBox(height: 32),
            
            // Basic Information Section
            _buildSectionHeader('المعلومات الأساسية', 'Basic Information', isDarkMode, isArabic),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _fullNameController,
              label: isArabic ? 'الاسم الكامل' : 'Full Name',
              icon: Icons.person_outline_rounded,
              isDarkMode: isDarkMode,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isArabic ? 'يرجى إدخال الاسم الكامل' : 'Please enter your full name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _phoneNumberController,
              label: isArabic ? 'رقم الهاتف' : 'Phone Number',
              icon: Icons.phone_outlined,
              isDarkMode: isDarkMode,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return isArabic ? 'يرجى إدخال رقم الهاتف' : 'Please enter your phone number';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _emailController,
              label: isArabic ? 'البريد الإلكتروني' : 'Email',
              icon: Icons.email_outlined,
              isDarkMode: isDarkMode,
              enabled: false,
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 32),
            
            // Address Section
            _buildSectionHeader('العنوان', 'Address', isDarkMode, isArabic),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _streetController,
              label: isArabic ? 'الشارع والحي' : 'Street & District',
              icon: Icons.location_on_outlined,
              isDarkMode: isDarkMode,
            ),
            
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _cityController,
              label: isArabic ? 'المدينة' : 'City',
              icon: Icons.location_city_outlined,
              isDarkMode: isDarkMode,
            ),
            
            const SizedBox(height: 16),
            
            _buildDropdownField(
              value: _governorateController.text.isEmpty ? null : _governorateController.text,
              label: isArabic ? 'المحافظة' : 'Governorate',
              icon: Icons.map_outlined,
              isDarkMode: isDarkMode,
              items: _governorates.map((gov) => DropdownMenuItem(
                value: gov,
                child: Text(gov),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _governorateController.text = value ?? '';
                });
              },
            ),
            
            const SizedBox(height: 32),
            
            // Employment Section
            _buildSectionHeader('معلومات العمل', 'Employment Information', isDarkMode, isArabic),
            const SizedBox(height: 16),
            
            _buildEmploymentToggle(isDarkMode, isArabic),
            
            if (_isEmployed) ...[
              const SizedBox(height: 16),
              
              _buildSectorDropdown(isDarkMode, isArabic),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _employerNameController,
                label: isArabic ? 'اسم جهة العمل' : 'Employer Name',
                icon: Icons.business_outlined,
                isDarkMode: isDarkMode,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _jobTitleController,
                label: isArabic ? 'المسمى الوظيفي' : 'Job Title',
                icon: Icons.work_outline_rounded,
                isDarkMode: isDarkMode,
              ),
            ],
            
            const SizedBox(height: 40),
            
            // Save Button
            _buildSaveButton(isDarkMode, isArabic),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(bool isDarkMode, bool isArabic) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF00E5FF),
                  Color(0xFF2196F3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2196F3).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
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
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String arabicTitle, String englishTitle, bool isDarkMode, bool isArabic) {
    return Text(
      isArabic ? arabicTitle : englishTitle,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      enabled: enabled,
      style: TextStyle(
        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white54 : Colors.black54,
        ),
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
            width: 2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required IconData icon,
    required bool isDarkMode,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white54 : Colors.black54,
        ),
        prefixIcon: Icon(
          icon,
          color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
            width: 2,
          ),
        ),
      ),
      style: TextStyle(
        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
        fontSize: 16,
      ),
      dropdownColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildEmploymentToggle(bool isDarkMode, bool isArabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.work_outline_rounded,
            color: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isArabic ? 'هل تعمل حالياً؟' : 'Are you currently employed?',
              style: TextStyle(
                color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                fontSize: 16,
              ),
            ),
          ),
          Switch(
            value: _isEmployed,
            onChanged: (value) {
              setState(() {
                _isEmployed = value;
                if (!value) {
                  _employmentSector = 'none';
                  _employerNameController.clear();
                  _jobTitleController.clear();
                }
              });
            },
            activeColor: isDarkMode ? const Color(0xFF00E5FF) : const Color(0xFF2196F3),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorDropdown(bool isDarkMode, bool isArabic) {
    return _buildDropdownField(
      value: _employmentSector == 'none' ? null : _employmentSector,
      label: isArabic ? 'قطاع العمل' : 'Employment Sector',
      icon: Icons.business_center_outlined,
      isDarkMode: isDarkMode,
      items: [
        DropdownMenuItem(
          value: 'public',
          child: Text(isArabic ? 'القطاع الحكومي' : 'Public Sector'),
        ),
        DropdownMenuItem(
          value: 'private',
          child: Text(isArabic ? 'القطاع الخاص' : 'Private Sector'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _employmentSector = value ?? 'none';
        });
      },
    );
  }

  Widget _buildSaveButton(bool isDarkMode, bool isArabic) {
    return SizedBox(
      width: double.infinity,
      height: 56,
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
        child: ElevatedButton(
          onPressed: _isLoading ? null : _updateProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : Text(
                  isArabic ? 'حفظ التغييرات' : 'Save Changes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}