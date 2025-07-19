import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';

class QuickActionsSection extends StatelessWidget {
  final UserProfile userProfile;

  const QuickActionsSection({super.key, required this.userProfile});

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
                Icon(Icons.flash_on, color: colors.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Actions Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildActionCard(
                  context,
                  'Request Credit\nIncrease',
                  Icons.trending_up,
                  colors.statusSuccess,
                  () => _requestCreditIncrease(context),
                ),
                _buildActionCard(
                  context,
                  'View\nTransactions',
                  Icons.receipt_long,
                  colors.primary,
                  () => _viewTransactions(context),
                ),
                _buildActionCard(
                  context,
                  'Payment\nHistory',
                  Icons.payment,
                  colors.secondary,
                  () => _viewPaymentHistory(context),
                ),
                _buildActionCard(
                  context,
                  'Credit\nReport',
                  Icons.assessment,
                  colors.statusInfo,
                  () => _viewCreditReport(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Additional Actions
            _buildActionTile(
              context,
              'Download Statement',
              Icons.file_download,
              colors.primary,
              () => _downloadStatement(context),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              'Contact Support',
              Icons.support_agent,
              colors.statusInfo,
              () => _contactSupport(context),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              context,
              'Refer a Friend',
              Icons.person_add,
              colors.statusSuccess,
              () => _referFriend(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
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
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: context.colors.textTertiary,
        size: 16,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _requestCreditIncrease(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreditIncreaseDialog(userProfile: userProfile),
    );
  }

  void _viewTransactions(BuildContext context) {
    // Navigate to transactions screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Transactions feature coming soon!')),
    );
  }

  void _viewPaymentHistory(BuildContext context) {
    // Navigate to payment history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment history feature coming soon!')),
    );
  }

  void _viewCreditReport(BuildContext context) {
    // Navigate to credit report screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credit report feature coming soon!')),
    );
  }

  void _downloadStatement(BuildContext context) {
    // Download statement functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Statement download feature coming soon!')),
    );
  }

  void _contactSupport(BuildContext context) {
    // Contact support functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support contact feature coming soon!')),
    );
  }

  void _referFriend(BuildContext context) {
    // Refer friend functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Refer friend feature coming soon!')),
    );
  }
}

class CreditIncreaseDialog extends StatefulWidget {
  final UserProfile userProfile;

  const CreditIncreaseDialog({super.key, required this.userProfile});

  @override
  State<CreditIncreaseDialog> createState() => _CreditIncreaseDialogState();
}

class _CreditIncreaseDialogState extends State<CreditIncreaseDialog> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_amountController.text.isEmpty || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
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
          content: const Text(
            'Credit increase request submitted successfully!',
          ),
          backgroundColor: context.colors.statusSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.trending_up, color: colors.primary),
          const SizedBox(width: 8),
          const Text('Request Credit Increase'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Current Credit Limit: ${widget.userProfile.creditLimit.toStringAsFixed(0)} JOD',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Requested Amount (JOD)',
              prefixIcon: Icon(Icons.monetization_on),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason for Increase',
              prefixIcon: Icon(Icons.comment),
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
          onPressed: _isLoading ? null : _submitRequest,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
