import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../utils/app_localizations.dart';
import '../utils/theme.dart';
import '../widgets/custom_text_field.dart';

class PersonalInfoSection extends StatefulWidget {
  final UserProfile userProfile;
  final VoidCallback onProfileUpdated;

  const PersonalInfoSection({
    super.key,
    required this.userProfile,
    required this.onProfileUpdated,
  });

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  final UserService _userService = UserService();
  bool _isEditing = false;
  bool _isLoading = false;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _nationalIdController;
  late TextEditingController _employerNameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _employeeIdController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _governorateController;
  late TextEditingController _postalCodeController;

  String _selectedSector = 'none';
  bool _isEmployed = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController(
      text: widget.userProfile.fullName,
    );
    _emailController = TextEditingController(text: widget.userProfile.email);
    _phoneController = TextEditingController(
      text: widget.userProfile.phoneNumber,
    );
    _nationalIdController = TextEditingController(
      text: widget.userProfile.nationalId,
    );
    _employerNameController = TextEditingController(
      text: widget.userProfile.employment.employerName,
    );
    _jobTitleController = TextEditingController(
      text: widget.userProfile.employment.jobTitle,
    );
    _employeeIdController = TextEditingController(
      text: widget.userProfile.employment.employeeId ?? '',
    );
    _streetController = TextEditingController(
      text: widget.userProfile.address.street,
    );
    _cityController = TextEditingController(
      text: widget.userProfile.address.city,
    );
    _governorateController = TextEditingController(
      text: widget.userProfile.address.governorate,
    );
    _postalCodeController = TextEditingController(
      text: widget.userProfile.address.postalCode,
    );

    _selectedSector = widget.userProfile.employment.sector;
    _isEmployed = widget.userProfile.employment.isEmployed;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalIdController.dispose();
    _employerNameController.dispose();
    _jobTitleController.dispose();
    _employeeIdController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _governorateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = {
        'fullName': _fullNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'nationalId': _nationalIdController.text,
        'employment': {
          'isEmployed': _isEmployed,
          'sector': _selectedSector,
          'employerName': _employerNameController.text,
          'jobTitle': _jobTitleController.text,
          'employeeId': _employeeIdController.text.isNotEmpty
              ? _employeeIdController.text
              : null,
        },
        'address': {
          'street': _streetController.text,
          'city': _cityController.text,
          'governorate': _governorateController.text,
          'postalCode': _postalCodeController.text,
        },
        'updatedAt': DateTime.now(),
      };

      await _userService.updateUserProfile(
        widget.userProfile.userId,
        updatedData,
      );

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      widget.onProfileUpdated();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.success),
            backgroundColor: context.colors.statusSuccess,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.error),
            backgroundColor: context.colors.statusError,
          ),
        );
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
    });
    _initializeControllers();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.person_outline, color: colors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                if (!_isEditing)
                  IconButton(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: Icon(Icons.edit, color: colors.primary),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            if (_isEditing) _buildEditForm() else _buildDisplayMode(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayMode() {
    // final colors = context.colors;

    return Column(
      children: [
        _buildInfoRow('Full Name', widget.userProfile.fullName, Icons.person),
        _buildInfoRow('Email', widget.userProfile.email, Icons.email),
        _buildInfoRow('Phone', widget.userProfile.phoneNumber, Icons.phone),
        _buildInfoRow(
          'National ID',
          widget.userProfile.nationalId,
          Icons.badge,
        ),

        const SizedBox(height: 16),
        _buildSectionTitle('Employment'),
        _buildInfoRow(
          'Employment Status',
          _isEmployed ? 'Employed' : 'Unemployed',
          Icons.work,
        ),
        if (_isEmployed) ...[
          _buildInfoRow(
            'Sector',
            _getSectorLabel(_selectedSector),
            Icons.business,
          ),
          _buildInfoRow(
            'Employer',
            widget.userProfile.employment.employerName,
            Icons.business_center,
          ),
          _buildInfoRow(
            'Job Title',
            widget.userProfile.employment.jobTitle,
            Icons.work_outline,
          ),
          if (widget.userProfile.employment.employeeId != null)
            _buildInfoRow(
              'Employee ID',
              widget.userProfile.employment.employeeId!,
              Icons.badge,
            ),
        ],

        const SizedBox(height: 16),
        _buildSectionTitle('Address'),
        _buildInfoRow(
          'Street',
          widget.userProfile.address.street,
          Icons.location_on,
        ),
        _buildInfoRow(
          'City',
          widget.userProfile.address.city,
          Icons.location_city,
        ),
        _buildInfoRow(
          'Governorate',
          widget.userProfile.address.governorate,
          Icons.map,
        ),
        _buildInfoRow(
          'Postal Code',
          widget.userProfile.address.postalCode,
          Icons.mail,
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    final colors = context.colors;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          CustomTextField(
            controller: _fullNameController,
            label: 'Full Name',
            prefixIcon: const Icon(Icons.person),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _emailController,
            label: 'Email',
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _phoneController,
            label: 'Phone Number',
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _nationalIdController,
            label: 'National ID',
            prefixIcon: const Icon(Icons.badge),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 24),

          // Employment Section
          _buildSectionTitle('Employment'),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Currently Employed'),
            value: _isEmployed,
            onChanged: (value) => setState(() => _isEmployed = value),
            activeColor: colors.primary,
          ),
          const SizedBox(height: 16),

          if (_isEmployed) ...[
            DropdownButtonFormField<String>(
              value: _selectedSector,
              decoration: const InputDecoration(
                labelText: 'Sector',
                prefixIcon: Icon(Icons.business),
              ),
              items: const [
                DropdownMenuItem(value: 'public', child: Text('Public')),
                DropdownMenuItem(
                  value: 'private',
                  child: Text('Private'),
                ),
                DropdownMenuItem(value: 'none', child: Text('None')),
              ],
              onChanged: (value) => setState(() => _selectedSector = value!),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _employerNameController,
              label: 'Employer Name',
              prefixIcon: const Icon(Icons.business_center),
              validator: (value) =>
                  _isEmployed && value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _jobTitleController,
              label: 'Job Title',
              prefixIcon: const Icon(Icons.work_outline),
              validator: (value) =>
                  _isEmployed && value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _employeeIdController,
              label: 'Employee ID (Optional)',
              prefixIcon: const Icon(Icons.badge),
            ),
            const SizedBox(height: 24),
          ],

          // Address Section
          _buildSectionTitle('Address'),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _streetController,
            label: 'Street',
            prefixIcon: const Icon(Icons.location_on),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _cityController,
            label: 'City',
            prefixIcon: const Icon(Icons.location_city),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _governorateController,
            label: 'Governorate',
            prefixIcon: const Icon(Icons.map),
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 16),

          CustomTextField(
            controller: _postalCodeController,
            label: 'Postal Code',
            prefixIcon: const Icon(Icons.mail),
            keyboardType: TextInputType.number,
            validator: (value) => value?.isEmpty == true ? 'Required' : null,
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _cancelEdit,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: context.colors.textPrimary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: colors.textTertiary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSectorLabel(String sector) {
    switch (sector) {
      case 'public':
        return 'Public';
      case 'private':
        return 'Private';
      default:
        return 'None';
    }
  }
}
