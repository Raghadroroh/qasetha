import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';
import '../widgets/guest_banner.dart';
import '../widgets/guest_mode_indicator.dart';
// No need for smart_back_handler import as we have global back handling

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _trackPageVisit();
  }

  void _trackPageVisit() async {
    final authState = ref.read(authStateProvider);
    if (authState.isGuest) {
      await ref.read(authStateProvider.notifier).trackGuestPageVisit('dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Guest banner if in guest mode
            if (authState.shouldShowGuestBanner) const GuestBanner(),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, authState),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, authState),
                    const SizedBox(height: 24),
                    _buildRecentActivity(context),
                    const SizedBox(height: 24),
                    _buildAnalytics(context, authState),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context, authState),
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authState.isGuest 
                        ? 'ضيف' 
                        : authState.user?.name ?? 'مستخدم',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (authState.isGuest) const GuestModeIndicator(),
                  IconButton(
                    onPressed: () => context.go('/profile'),
                    icon: const Icon(Icons.person, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () => context.go('/app-settings'),
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإجراءات السريعة',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildActionCard(
              context,
              icon: Icons.security,
              title: 'الأمان',
              subtitle: 'إعدادات الأمان',
              onTap: () => context.go('/security-settings'),
            ),
            _buildActionCard(
              context,
              icon: Icons.language,
              title: 'اللغة',
              subtitle: 'إعدادات اللغة',
              onTap: () => context.go('/language-settings'),
            ),
            _buildActionCard(
              context,
              icon: Icons.notifications,
              title: 'الإشعارات',
              subtitle: 'إدارة الإشعارات',
              onTap: () => context.go('/notifications'),
            ),
            _buildActionCard(
              context,
              icon: Icons.help,
              title: 'المساعدة',
              subtitle: 'المساعدة والدعم',
              onTap: () {
                _showHelpDialog(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النشاط الحديث',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildActivityItem(
                  context,
                  icon: Icons.login,
                  title: 'آخر تسجيل دخول',
                  subtitle: _getFormattedDate(DateTime.now()),
                ),
                const Divider(),
                _buildActivityItem(
                  context,
                  icon: Icons.security,
                  title: 'فحص الأمان',
                  subtitle: 'كل شيء آمن',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildAnalytics(BuildContext context, AuthState authState) {
    if (!authState.isGuest) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الاستخدام',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildStatItem(
                  context,
                  title: 'الميزات المستخدمة',
                  value: '${authState.guestSession?.featuresUsed.length ?? 0}',
                  icon: Icons.star,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  context,
                  title: 'الصفحات المزارة',
                  value: '${authState.guestSession?.pageVisitCount.length ?? 0}',
                  icon: Icons.pageview,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  context,
                  title: 'مدة الجلسة',
                  value: _getSessionDuration(authState.guestSession?.createdAt),
                  icon: Icons.timer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(BuildContext context, AuthState authState) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0, // Dashboard is selected
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'لوحة التحكم',
        ),
        BottomNavigationBarItem(
          icon: Icon(authState.isGuest ? Icons.person_outline : Icons.person),
          label: 'الملف الشخصي',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications),
          label: 'الإشعارات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'الإعدادات',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Already on dashboard
            break;
          case 1:
            context.go('/profile');
            break;
          case 2:
            context.go('/notifications');
            break;
          case 3:
            context.go('/app-settings');
            break;
        }
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 17) {
      return 'مساء الخير';
    } else {
      return 'مساء الخير';
    }
  }

  String _getFormattedDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getSessionDuration(DateTime? startTime) {
    if (startTime == null) return '0د';
    
    final duration = DateTime.now().difference(startTime);
    if (duration.inHours > 0) {
      return '${duration.inHours}س ${duration.inMinutes % 60}د';
    }
    return '${duration.inMinutes}د';
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('المساعدة'),
        content: const Text('تواصل مع الدعم للحصول على المساعدة أو الإبلاغ عن مشاكل أو تقديم ملاحظات.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}