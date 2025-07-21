import 'package:flutter/material.dart';
import '../models/user_model.dart';
// import '../services/biometric_auth_service.dart'; // File removed
import '../utils/theme.dart';

class SecuritySettingsSection extends StatefulWidget {
  final UserProfile userProfile;

  const SecuritySettingsSection({super.key, required this.userProfile});

  @override
  State<SecuritySettingsSection> createState() =>
      _SecuritySettingsSectionState();
}

class _SecuritySettingsSectionState extends State<SecuritySettingsSection> {
  // Biometric service removed
  bool _notificationsEnabled = true;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load current settings from preferences or API
    // This is a placeholder - implement actual loading logic
    setState(() {
      _notificationsEnabled = true;
      _twoFactorEnabled = false;
    });
  }

  // Removed _toggleBiometric - biometric functionality is no longer available

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

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
                Icon(Icons.security, color: colors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Security & Privacy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Security Settings
            _buildSecurityTile(
              'Change Password',
              'Update your account password',
              Icons.lock,
              colors.primary,
              () => _changePassword(context),
            ),
            const SizedBox(height: 16),

            _buildSecurityTile(
              'Two-Factor Authentication',
              'Add an extra layer of security',
              Icons.security,
              colors.statusInfo,
              () => _setupTwoFactor(context),
              trailing: Switch(
                value: _twoFactorEnabled,
                onChanged: (value) {
                  setState(() {
                    _twoFactorEnabled = value;
                  });
                  // Save to preferences
                },
                activeColor: colors.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Biometric login option removed

            _buildSecurityTile(
              'Login History',
              'View your recent login activity',
              Icons.history,
              colors.secondary,
              () => _viewLoginHistory(context),
            ),
            const SizedBox(height: 24),

            // Privacy Settings
            Text(
              'Privacy Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildSecurityTile(
              'Push Notifications',
              'Receive alerts and updates',
              Icons.notifications,
              colors.statusInfo,
              null,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  // Save to preferences
                },
                activeColor: colors.primary,
              ),
            ),
            const SizedBox(height: 16),

            _buildSecurityTile(
              'Privacy Policy',
              'Review our privacy policy',
              Icons.privacy_tip,
              colors.textSecondary,
              () => _viewPrivacyPolicy(context),
            ),
            const SizedBox(height: 16),

            _buildSecurityTile(
              'Data Export',
              'Download your personal data',
              Icons.download,
              colors.primary,
              () => _exportData(context),
            ),
            const SizedBox(height: 16),

            _buildSecurityTile(
              'Delete Account',
              'Permanently delete your account',
              Icons.delete_forever,
              colors.statusError,
              () => _deleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityTile(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: context.colors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
      ),
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.arrow_forward_ios,
                  color: context.colors.textTertiary,
                  size: 16,
                )
              : null),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _changePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _setupTwoFactor(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TwoFactorSetupDialog(),
    );
  }

  void _viewLoginHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const LoginHistoryModal(),
    );
  }

  void _viewPrivacyPolicy(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy feature coming soon!')),
    );
  }

  void _exportData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DataExportDialog(),
    );
  }

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const DeleteAccountDialog(),
    );
  }
}

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully!'),
          backgroundColor: context.colors.statusSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Current Password',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _newPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change'),
        ),
      ],
    );
  }
}

class TwoFactorSetupDialog extends StatelessWidget {
  const TwoFactorSetupDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Two-Factor Authentication'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Two-factor authentication adds an extra layer of security to your account.',
          ),
          SizedBox(height: 16),
          Text('This feature is coming soon!'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class LoginHistoryModal extends StatelessWidget {
  const LoginHistoryModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(24),
      child: const Column(
        children: [
          Text(
            'Login History',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          Expanded(
            child: Center(child: Text('Login history feature coming soon!')),
          ),
        ],
      ),
    );
  }
}

class DataExportDialog extends StatelessWidget {
  const DataExportDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Data'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Export your personal data and account information.'),
          SizedBox(height: 16),
          Text('This feature is coming soon!'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Account'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Are you sure you want to delete your account?'),
          SizedBox(height: 8),
          Text(
            'This action cannot be undone and all your data will be permanently removed.',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account deletion feature coming soon!'),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
