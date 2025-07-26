import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/category.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/guest_banner.dart';
import '../../widgets/universal_back_handler.dart';
import '../../services/logout_service.dart';
import '../../utils/firestore_index_helper.dart';
import '../../services/logger_service.dart';
import '../../services/analytics_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackPageVisit();
    });
  }

  Future<void> _trackPageVisit() async {
    try {
      // Track page visit
    } catch (e) {
      // Silently handle tracking errors
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final authState = ref.watch(authStateProvider);
    final shouldShowGuestBanner = authState.shouldShowGuestBanner;
    final isGuest = authState.isGuest;
    final user = authState.user;
    final locale = Localizations.localeOf(context).languageCode;

    return MainScreenBackHandler(
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0A0E21)
            : const Color(0xFFF8FAFC),
        body: Container(
          decoration: _buildBackgroundGradient(context),
          child: SafeArea(
            child: Column(
              children: [
                if (shouldShowGuestBanner) const GuestBanner(),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    backgroundColor: Theme.of(context).primaryColor,
                    color: Colors.white,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        _buildModernAppBar(context, isGuest, user),
                        _buildQuickActionsSection(context, locale),
                        _buildMainCategoriesSection(context, locale),
                        _buildCategoriesGrid(context, locale),
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 100),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildModernBottomNavigation(
          context,
          isGuest,
          locale,
        ),
        floatingActionButton: _buildFloatingActionButton(context, locale),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildModernAppBar(BuildContext context, bool isGuest, dynamic user) {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [
                      const Color.fromARGB(255, 26, 39, 50),
                      const Color(0xFF2D3748),
                      const Color.fromARGB(255, 74, 91, 104),
                    ]
                  : [
                      const Color(0xFF006A71),
                      const Color(0xFF4ECDC4),
                      const Color(0xFF7DD3FC),
                    ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildUserWelcomeSection(context, isGuest, user),
                    _buildAppBarActions(context, isGuest),
                  ],
                ),
                const Spacer(),
                _buildAppBarTitle(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserWelcomeSection(
    BuildContext context,
    bool isGuest,
    dynamic user,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  isGuest ? 'ضيف' : (user?.name ?? 'مستخدم'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isGuest) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Text(
                    'ضيف',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarActions(BuildContext context, bool isGuest) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.notifications_outlined,
          onPressed: () => context.go('/notifications'),
          badgeCount: 3, // Mock notification count
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.settings_outlined,
          onPressed: () => context.go('/app-settings'),
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.logout_rounded,
          onPressed: () => _handleLogout(context),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    int? badgeCount,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return Text(
      'قسطها',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, String locale) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              locale == 'ar' ? 'الإجراءات السريعة' : 'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1A2332),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: locale == 'ar' ? 'المنتجات' : 'Products',
                    subtitle: locale == 'ar'
                        ? 'تصفح جميع المنتجات'
                        : 'Browse All Products',
                    color: Theme.of(context).primaryColor,
                    onTap: () =>
                        _showCategoriesModal(context, 'products', locale),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    icon: Icons.design_services_outlined,
                    title: locale == 'ar' ? 'الخدمات' : 'Services',
                    subtitle: locale == 'ar'
                        ? 'استكشف الخدمات المتاحة'
                        : 'Explore Available Services',
                    color: const Color.fromARGB(255, 58, 198, 237),
                    onTap: () =>
                        _showCategoriesModal(context, 'services', locale),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color.fromARGB(255, 29, 52, 58),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : const Color(0xFF64748B),
                    height: 1.3,
                  ),
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

  Widget _buildMainCategoriesSection(BuildContext context, String locale) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              locale == 'ar' ? 'التصنيفات الرئيسية' : 'Main Categories',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1A2332),
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAllCategoriesModal(context, locale),
              icon: Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: Theme.of(context).primaryColor,
              ),
              label: Text(
                locale == 'ar' ? 'عرض الكل' : 'View All',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, String locale) {
    // Try to use the stream provider first, but fall back to the future provider if there's an index error
    final categoriesAsync = ref.watch(mainCategoriesStreamProvider);

    return categoriesAsync.when(
      loading: () => SliverToBoxAdapter(child: _buildLoadingGrid(context)),
      error: (error, stack) {
        // Check if it's a Firestore index error
        if (FirestoreIndexHelper.isIndexError(error)) {
          LoggerService.warning('Firestore index error detected: $error');

          // Show the index creation dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FirestoreIndexHelper.showIndexCreationDialog(
              context,
              error.toString(),
            );
          });

          // Fall back to the non-stream version as a temporary solution
          return _buildFallbackCategoriesGrid(context, locale);
        }
        return SliverToBoxAdapter(
          child: _buildErrorWidget(context, error.toString()),
        );
      },
      data: (categories) {
        if (categories.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState(context));
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category, locale);
            }, childCount: categories.length),
          ),
        );
      },
    );
  }

  // Fallback method that uses the Future-based provider instead of Stream
  Widget _buildFallbackCategoriesGrid(BuildContext context, String locale) {
    final categoriesAsync = ref.watch(mainCategoriesProvider);

    return categoriesAsync.when(
      loading: () => SliverToBoxAdapter(child: _buildLoadingGrid(context)),
      error: (error, stack) => SliverToBoxAdapter(
        child: _buildErrorWidget(
          context,
          "Could not load categories. Please check your connection and try again.",
        ),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return SliverToBoxAdapter(child: _buildEmptyState(context));
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = categories[index];
              return _buildCategoryCard(context, category, locale);
            }, childCount: categories.length),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Category category,
    String locale,
  ) {
    final isProduct = category.type.toLowerCase() == 'products';
    final cardColor = isProduct
        ? Theme.of(context).primaryColor
        : const Color(0xFF7C3AED);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardColor.withOpacity(0.1), cardColor.withOpacity(0.05)],
        ),
        border: Border.all(color: cardColor.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onCategoryTap(category),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardColor.withOpacity(0.2),
                        cardColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: _buildCategoryIcon(context, category, cardColor),
                ),
                const SizedBox(height: 16),
                Text(
                  category.getLocalizedName(locale),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : const Color(0xFF1A2332),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    locale == 'ar'
                        ? (isProduct ? 'المنتجات' : 'الخدمات')
                        : (isProduct ? 'Products' : 'Services'),
                    style: TextStyle(
                      color: cardColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(
    BuildContext context,
    Category category,
    Color color,
  ) {
    IconData iconData;

    // Enhanced icon mapping for better visual representation
    switch (category.name.toLowerCase()) {
      case 'المنزل والأثاث':
      case 'home & furniture':
        iconData = Icons.home_outlined;
        break;
      case 'الإلكترونيات والتكنولوجيا':
      case 'electronics & technology':
        iconData = Icons.devices_outlined;
        break;
      case 'الأزياء والجمال':
      case 'fashion & beauty':
        iconData = Icons.style_outlined;
        break;
      case 'السيارات والمركبات':
      case 'automotive & vehicles':
        iconData = Icons.directions_car_outlined;
        break;
      case 'الطعام والمشروبات':
      case 'food & beverages':
        iconData = Icons.restaurant_outlined;
        break;
      case 'الرياضة واللياقة':
      case 'sports & fitness':
        iconData = Icons.fitness_center_outlined;
        break;
      case 'التعليم والثقافة':
      case 'education & culture':
        iconData = Icons.school_outlined;
        break;
      case 'الصحة والعافية':
      case 'health & wellness':
        iconData = Icons.health_and_safety_outlined;
        break;
      case 'السفر والسياحة':
      case 'travel & tourism':
        iconData = Icons.luggage_outlined;
        break;
      // Services
      case 'خدمات المنزل والصيانة':
      case 'home & maintenance services':
        iconData = Icons.home_repair_service_outlined;
        break;
      case 'الخدمات التقنية':
      case 'technical services':
        iconData = Icons.computer_outlined;
        break;
      case 'خدمات التجميل والعناية':
      case 'beauty & care services':
        iconData = Icons.face_retouching_natural_outlined;
        break;
      case 'خدمات السيارات':
      case 'automotive services':
        iconData = Icons.car_repair_outlined;
        break;
      case 'خدمات الطعام والضيافة':
      case 'food & hospitality services':
        iconData = Icons.room_service_outlined;
        break;
      default:
        iconData = category.type.toLowerCase() == 'products'
            ? Icons.shopping_bag_outlined
            : Icons.design_services_outlined;
    }

    if (category.iconUrl != null && category.iconUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: category.iconUrl!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, size: 20, color: color),
          ),
          errorWidget: (context, url, error) =>
              Icon(iconData, size: 36, color: color),
        ),
      );
    }

    return Icon(iconData, size: 36, color: color);
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'خطأ في تحميل التصنيفات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _refreshData(),
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد تصنيفات',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'لم يتم العثور على تصنيفات متاحة حالياً',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomNavigation(
    BuildContext context,
    bool isGuest,
    String locale,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A2332)
            : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                context,
                icon: Icons.home_rounded,
                label: locale == 'ar' ? 'الرئيسية' : 'Home',
                isSelected: true,
                onTap: () {},
              ),
              _buildBottomNavItem(
                context,
                icon: isGuest
                    ? Icons.person_outline_rounded
                    : Icons.person_rounded,
                label: locale == 'ar' ? 'الملف الشخصي' : 'Profile',
                isSelected: false,
                onTap: () => context.go('/profile'),
              ),
              const SizedBox(width: 64), // Space for FAB
              _buildBottomNavItem(
                context,
                icon: Icons.notifications_rounded,
                label: locale == 'ar' ? 'الإشعارات' : 'Notifications',
                isSelected: false,
                onTap: () => context.go('/notifications'),
                badgeCount: 3,
              ),
              _buildBottomNavItem(
                context,
                icon: Icons.settings_rounded,
                label: locale == 'ar' ? 'الإعدادات' : 'Settings',
                isSelected: false,
                onTap: () => context.go('/app-settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    final color = isSelected
        ? Theme.of(context).primaryColor
        : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white60
              : const Color(0xFF64748B));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 24),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, String locale) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showProductsServicesModal(context, locale),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.apps_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Future<void> _onCategoryTap(Category category) async {
    try {
      // Track analytics
      await AnalyticsService.logEvent(
        name: 'category_tapped',
        parameters: {
          'category_id': category.id,
          'category_name': category.name,
          'category_type': category.type,
        },
      );

      final hasSubcategories = await ref.read(
        hasSubcategoriesProvider(category.id).future,
      );

      if (hasSubcategories) {
        if (mounted) {
          context.go('/subcategories/${category.id}', extra: category);
        }
      } else {
        if (mounted) {
          context.go('/products/category/${category.id}', extra: category);
        }
      }
    } catch (e) {
      if (mounted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? 'خطأ في فتح التصنيف: ${e.toString()}'
                    : 'Error opening category: ${e.toString()}',
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  BoxDecoration _buildBackgroundGradient(BuildContext context) {
    return BoxDecoration(
      gradient: Theme.of(context).brightness == Brightness.dark
          ? const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A0E21), Color(0xFF1A1B3A), Color(0xFF2D1B69)],
            )
          : const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
            ),
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

  Future<void> _refreshData() async {
    ref.invalidate(mainCategoriesStreamProvider);
    await _trackPageVisit();
  }

  void _handleLogout(BuildContext context) async {
    if (!mounted) return;
    await LogoutService.showLogoutConfirmationAndPerform(context, ref);
  }

  // Modal functions for enhanced navigation
  void _showCategoriesModal(BuildContext context, String type, String locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A2332)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        type == 'products'
                            ? Icons.shopping_bag_outlined
                            : Icons.design_services_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        locale == 'ar'
                            ? (type == 'products' ? 'المنتجات' : 'الخدمات')
                            : (type == 'products' ? 'Products' : 'Services'),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildFilteredCategoriesList(
                    context,
                    type,
                    locale,
                    scrollController,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAllCategoriesModal(BuildContext context, String locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A2332)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        locale == 'ar' ? 'جميع التصنيفات' : 'All Categories',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildAllCategoriesList(
                    context,
                    locale,
                    scrollController,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showProductsServicesModal(BuildContext context, String locale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A2332)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.apps_rounded,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        locale == 'ar'
                            ? 'المنتجات والخدمات'
                            : 'Products & Services',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildProductsServicesGrid(
                    context,
                    locale,
                    scrollController,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilteredCategoriesList(
    BuildContext context,
    String type,
    String locale,
    ScrollController scrollController,
  ) {
    final categoriesAsync = ref.watch(mainCategoriesStreamProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          locale == 'ar' ? 'خطأ في تحميل البيانات' : 'Error loading data',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (categories) {
        final filteredCategories = categories
            .where((cat) => cat.type.toLowerCase() == type)
            .toList();

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filteredCategories.length,
          itemBuilder: (context, index) {
            final category = filteredCategories[index];
            return _buildModalCategoryItem(context, category, locale);
          },
        );
      },
    );
  }

  Widget _buildAllCategoriesList(
    BuildContext context,
    String locale,
    ScrollController scrollController,
  ) {
    final categoriesAsync = ref.watch(mainCategoriesStreamProvider);

    return categoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text(
          locale == 'ar' ? 'خطأ في تحميل البيانات' : 'Error loading data',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      ),
      data: (categories) {
        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildModalCategoryItem(context, category, locale);
          },
        );
      },
    );
  }

  Widget _buildProductsServicesGrid(
    BuildContext context,
    String locale,
    ScrollController scrollController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        controller: scrollController,
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildQuickActionCard(
            context,
            icon: Icons.shopping_bag_outlined,
            title: locale == 'ar' ? 'المنتجات' : 'Products',
            subtitle: locale == 'ar'
                ? 'تصفح جميع المنتجات'
                : 'Browse All Products',
            color: Theme.of(context).primaryColor,
            onTap: () {
              Navigator.pop(context);
              _showCategoriesModal(context, 'products', locale);
            },
          ),
          _buildQuickActionCard(
            context,
            icon: Icons.design_services_outlined,
            title: locale == 'ar' ? 'الخدمات' : 'Services',
            subtitle: locale == 'ar'
                ? 'استكشف الخدمات المتاحة'
                : 'Explore Available Services',
            color: const Color(0xFF7C3AED),
            onTap: () {
              Navigator.pop(context);
              _showCategoriesModal(context, 'services', locale);
            },
          ),
          _buildQuickActionCard(
            context,
            icon: Icons.category_outlined,
            title: locale == 'ar' ? 'جميع التصنيفات' : 'All Categories',
            subtitle: locale == 'ar'
                ? 'عرض كامل للتصنيفات'
                : 'Complete Category View',
            color: const Color(0xFFEF4444),
            onTap: () {
              Navigator.pop(context);
              _showAllCategoriesModal(context, locale);
            },
          ),
          _buildQuickActionCard(
            context,
            icon: Icons.search_rounded,
            title: locale == 'ar' ? 'بحث متقدم' : 'Advanced Search',
            subtitle: locale == 'ar' ? 'بحث بالفلاتر' : 'Search with Filters',
            color: const Color(0xFF10B981),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to search screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModalCategoryItem(
    BuildContext context,
    Category category,
    String locale,
  ) {
    final isProduct = category.type.toLowerCase() == 'products';
    final cardColor = isProduct
        ? Theme.of(context).primaryColor
        : const Color.fromARGB(255, 58, 162, 237);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D3748)
            : const Color(0xFFF8FAFC),
        border: Border.all(color: cardColor.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            _onCategoryTap(category);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        cardColor.withOpacity(0.2),
                        cardColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Icon(
                    isProduct
                        ? Icons.shopping_bag_outlined
                        : Icons.design_services_outlined,
                    color: cardColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.getLocalizedName(locale),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.getLocalizedDescription(locale) ??
                            (locale == 'ar'
                                ? 'وصف للتصنيف'
                                : 'Category description'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white60
                              : const Color(0xFF64748B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    locale == 'ar'
                        ? (isProduct ? 'منتج' : 'خدمة')
                        : (isProduct ? 'Product' : 'Service'),
                    style: TextStyle(
                      color: cardColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white60
                      : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
