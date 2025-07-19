import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/theme_service.dart';
import '../utils/glassmorphism.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'تمت الموافقة على طلبك',
      'subtitle': 'تم قبول طلب التمويل الخاص بك بقيمة 5000 د.أ',
      'time': '2 ساعات',
      'icon': Icons.check_circle,
      'color': Colors.green,
      'isRead': false,
    },
    {
      'title': 'دفعة مستحقة',
      'subtitle': 'لديك دفعة شهرية مستحقة بقيمة 250 د.أ',
      'time': '1 يوم',
      'icon': Icons.payment,
      'color': Colors.orange,
      'isRead': false,
    },
    {
      'title': 'عرض خاص',
      'subtitle': 'خصم 20% على جميع المنتجات الإلكترونية',
      'time': '3 أيام',
      'icon': Icons.local_offer,
      'color': const Color(0xFF00E5FF),
      'isRead': true,
    },
    {
      'title': 'تحديث الأمان',
      'subtitle': 'تم تحديث إعدادات الأمان في حسابك',
      'time': '1 أسبوع',
      'icon': Icons.security,
      'color': Colors.blue,
      'isRead': true,
    },
    {
      'title': 'رسالة ترحيبية',
      'subtitle': 'مرحباً بك في قسطها! نحن سعداء لانضمامك إلينا',
      'time': '2 أسبوع',
      'icon': Icons.celebration,
      'color': Colors.purple,
      'isRead': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeService = ref.watch(themeServiceProvider);
    final isDarkMode = themeService.isDarkMode;
    final isRTL = themeService.languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [
                      const Color(0xFF0A0E21),
                      const Color(0xFF1A1B3A),
                      const Color(0xFF2D1B69),
                      const Color(0xFF0A192F),
                    ]
                  : [
                      const Color(0xFFF5F7FA),
                      const Color(0xFFE8F4F8),
                      const Color(0xFFD6E9F0),
                      const Color(0xFFBCDBEA),
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(isDarkMode, isRTL),
                Expanded(
                  child: _buildNotificationsList(isDarkMode, isRTL),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode, bool isRTL) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: GlassmorphicContainer(
        borderRadius: 20,
        blur: 20,
        opacity: 0.1,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.pop();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : const Color(0xFF1A4B52))
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: (isDarkMode ? Colors.white : const Color(0xFF1A4B52))
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    isRTL ? Icons.arrow_forward : Icons.arrow_back,
                    color: isDarkMode ? Colors.white70 : const Color(0xFF1A4B52),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  isRTL ? 'الإشعارات' : 'Notifications',
                  style: GoogleFonts.tajawal(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E5FF), Color(0xFF0099CC)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_notifications.where((n) => !n['isRead']).length}',
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList(bool isDarkMode, bool isRTL) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          child: _buildNotificationCard(notification, isDarkMode, isRTL, index),
        );
      },
    );
  }

  Widget _buildNotificationCard(
    Map<String, dynamic> notification,
    bool isDarkMode,
    bool isRTL,
    int index,
  ) {
    final isRead = notification['isRead'] as bool;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (!isRead) {
          setState(() {
            _notifications[index]['isRead'] = true;
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification['title']),
            backgroundColor: notification['color'] as Color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
      child: GlassmorphicContainer(
        borderRadius: 16,
        blur: 15,
        opacity: isRead ? 0.05 : 0.1,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead 
                  ? Colors.transparent 
                  : (notification['color'] as Color).withValues(alpha: 0.3),
              width: isRead ? 0 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      notification['color'] as Color,
                      (notification['color'] as Color).withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isRead ? [] : [
                    BoxShadow(
                      color: (notification['color'] as Color).withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] as String,
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF1A4B52),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notification['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['subtitle'] as String,
                      style: GoogleFonts.tajawal(
                        fontSize: 14,
                        color: isDarkMode
                            ? (isRead ? Colors.white54 : Colors.white70)
                            : (isRead 
                                ? const Color(0xFF1A4B52).withValues(alpha: 0.6)
                                : const Color(0xFF1A4B52).withValues(alpha: 0.8)),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['time'] as String,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.white54
                            : const Color(0xFF1A4B52).withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDarkMode
                    ? Colors.white38
                    : const Color(0xFF1A4B52).withValues(alpha: 0.3),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}