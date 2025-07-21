import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';
import '../widgets/guest_banner.dart';
import '../widgets/guest_mode_indicator.dart';
import '../widgets/universal_back_handler.dart';
import '../services/logout_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  
  // Cache widgets to avoid rebuilding expensive components
  Widget? _cachedQuickActions;
  Widget? _cachedRecentActivity;
  String? _lastGreeting;
  DateTime? _lastGreetingUpdate;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Defer tracking to next frame to avoid blocking UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackPageVisit();
    });
  }

  Future<void> _trackPageVisit() async {
    try {
      final authState = ref.read(authStateProvider);
      if (authState.isGuest) {
        await ref.read(authStateProvider.notifier).trackGuestPageVisit('dashboard');
      }
    } catch (e) {
      // Silently handle tracking errors to avoid affecting UI
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    // Use selectors to minimize rebuilds
    final shouldShowGuestBanner = ref.watch(
      authStateProvider.select((state) => state.shouldShowGuestBanner)
    );
    final isGuest = ref.watch(
      authStateProvider.select((state) => state.isGuest)
    );
    final user = ref.watch(
      authStateProvider.select((state) => state.user)
    );
    final guestSession = ref.watch(
      authStateProvider.select((state) => state.guestSession)
    );

    return MainScreenBackHandler(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Guest banner if in guest mode
              if (shouldShowGuestBanner) const GuestBanner(),
              
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOptimizedHeader(context, isGuest, user),
                        const SizedBox(height: 24),
                        _getQuickActions(context),
                        const SizedBox(height: 24),
                        _getRecentActivity(context),
                        const SizedBox(height: 24),
                        if (isGuest) _buildAnalytics(context, guestSession),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildOptimizedBottomNavigation(context, isGuest),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Clear cached widgets on refresh
    setState(() {
      _cachedQuickActions = null;
      _cachedRecentActivity = null;
      _lastGreeting = null;
    });
    
    // Refresh data
    await _trackPageVisit();
  }
  
  Widget _getQuickActions(BuildContext context) {
    return _cachedQuickActions ??= _buildQuickActions(context);
  }
  
  Widget _getRecentActivity(BuildContext context) {
    return _cachedRecentActivity ??= _buildRecentActivity(context);
  }
  
  String _getOptimizedGreeting() {
    final now = DateTime.now();
    
    // Cache greeting for 1 hour to avoid frequent DateTime calls
    if (_lastGreeting != null && 
        _lastGreetingUpdate != null &&
        now.difference(_lastGreetingUpdate!).inHours < 1) {
      return _lastGreeting!;
    }
    
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'صباح الخير';
    } else if (hour < 17) {
      greeting = 'مساء الخير';
    } else {
      greeting = 'مساء الخير';
    }
    
    _lastGreeting = greeting;
    _lastGreetingUpdate = now;
    return greeting;
  }

  Widget _buildOptimizedHeader(BuildContext context, bool isGuest, dynamic user) {
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
                    _getOptimizedGreeting(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isGuest 
                        ? 'ضيف' 
                        : user?.name ?? 'مستخدم',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              RepaintBoundary(
                child: Row(
                  children: [
                    if (isGuest) const GuestModeIndicator(),
                    IconButton(
                      onPressed: () => context.go('/profile'),
                      icon: const Icon(Icons.person, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => context.go('/app-settings'),
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout, color: Colors.white),
                      tooltip: 'تسجيل الخروج',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return RepaintBoundary(
      child: Column(
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
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return RepaintBoundary(
      child: Card(
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
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return RepaintBoundary(
      child: Column(
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
      ),
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

  Widget _buildAnalytics(BuildContext context, dynamic guestSession) {
    return RepaintBoundary(
      child: Column(
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
                  value: '${guestSession?.featuresUsed.length ?? 0}',
                  icon: Icons.star,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  context,
                  title: 'الصفحات المزارة',
                  value: '${guestSession?.pageVisitCount.length ?? 0}',
                  icon: Icons.pageview,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  context,
                  title: 'مدة الجلسة',
                  value: _getSessionDuration(guestSession?.createdAt),
                  icon: Icons.timer,
                ),
              ],
            ),
          ),
        ),
      ],
      ),
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

  Widget _buildOptimizedBottomNavigation(BuildContext context, bool isGuest) {
    return RepaintBoundary(
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // Dashboard is selected
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'لوحة التحكم',
          ),
          BottomNavigationBarItem(
            icon: Icon(isGuest ? Icons.person_outline : Icons.person),
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
        onTap: _handleBottomNavTap,
      ),
    );
  }
  
  void _handleBottomNavTap(int index) {
    if (!mounted) return;
    
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

  void _handleLogout(BuildContext context) async {
    if (!mounted) return;
    await LogoutService.showLogoutConfirmationAndPerform(context, ref);
  }
}