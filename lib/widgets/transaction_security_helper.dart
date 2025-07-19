import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../screens/auth/transaction_security_screen.dart';
import '../services/logger_service.dart';

/// مساعد لتشغيل شاشة الأمان للعمليات المالية
class TransactionSecurityHelper {
  /// عرض شاشة الأمان للعمليات المالية
  static Future<bool> showSecurityScreen({
    required BuildContext context,
    required String transactionType,
    required String transactionDetails,
  }) async {
    bool isAuthenticated = false;

    final navigator = Navigator.of(context);
    await navigator.push(
      MaterialPageRoute(
        builder: (context) => TransactionSecurityScreen(
          transactionType: transactionType,
          transactionDetails: transactionDetails,
          onSuccess: () {
            isAuthenticated = true;
            Navigator.of(context).pop();
          },
          onCancel: () {
            Navigator.of(context).pop();
          },
        ),
      ),
    );

    return isAuthenticated;
  }

  /// إرسال أموال
  static Future<bool> authenticateForSendMoney({
    required BuildContext context,
    required String amount,
    required String recipient,
  }) {
    return showSecurityScreen(
      context: context,
      transactionType: AppStrings.sendMoney,
      transactionDetails: 'إرسال $amount إلى $recipient',
    );
  }

  /// سحب أموال
  static Future<bool> authenticateForWithdraw({
    required BuildContext context,
    required String amount,
  }) {
    return showSecurityScreen(
      context: context,
      transactionType: AppStrings.withdrawFunds,
      transactionDetails: 'سحب $amount من الحساب',
    );
  }

  /// تغيير كلمة المرور
  static Future<bool> authenticateForPasswordChange({
    required BuildContext context,
  }) {
    return showSecurityScreen(
      context: context,
      transactionType: AppStrings.changePassword,
      transactionDetails: 'تحديث كلمة المرور الخاصة بك',
    );
  }
}

/// مثال على كيفية الاستخدام
class TransactionExample extends StatelessWidget {
  const TransactionExample({super.key});

  Future<void> _handleSendMoney(BuildContext context) async {
    final isAuthenticated =
        await TransactionSecurityHelper.authenticateForSendMoney(
          context: context,
          amount: '100 دينار',
          recipient: 'أحمد محمد',
        );

    if (isAuthenticated) {
      _processSendMoney();
    } else {
      _showCancelledMessage(context);
    }
  }

  void _processSendMoney() {
    LoggerService.info('تم إرسال الأموال بنجاح');
  }

  void _showCancelledMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.transactionCancelled)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مثال العمليات المالية')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => _handleSendMoney(context),
          child: const Text('إرسال أموال'),
        ),
      ),
    );
  }
}
