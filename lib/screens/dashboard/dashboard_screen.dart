import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/category.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/category_provider.dart';
import '../../widgets/guest_banner.dart';
import '../../widgets/guest_mode_indicator.dart';
import '../../widgets/universal_back_handler.dart';
import '../../services/logout_service.dart';
import '../../utils/firestore_index_helper.dart';
import '../../services/logger_service.dart';

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
    final locale = 'ar'; // Default to Arabic

    return MainScreenBackHandler(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              if (shouldShowGuestBanner) const GuestBanner(),
              
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildAppBar(context, isGuest, user),
                      _buildWelcomeSection(context, locale),
                      _buildCategoriesGrid(context, locale),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavigation(context, isGuest),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isGuest, dynamic user) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isGuest ? 'ضيف' : user?.name ?? 'مستخدم',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isGuest) 
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: GuestModeIndicator(),
                  ),
                IconButton(
                  onPressed: () => context.go('/profile'),
                  icon: const Icon(Icons.person_outline, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: () => context.go('/app-settings'),
                  icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, String locale) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  Theme.of(context).colorScheme.secondary.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'التصنيفات الرئيسية',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'اختر التصنيف المناسب لاستكشاف المنتجات',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, String locale) {
    // Try to use the stream provider first, but fall back to the future provider if there's an index error
    final categoriesAsync = ref.watch(mainCategoriesStreamProvider);

    return categoriesAsync.when(
      loading: () => SliverToBoxAdapter(
        child: _buildLoadingGrid(context),
      ),
      error: (error, stack) {
        // Check if it's a Firestore index error
        if (FirestoreIndexHelper.isIndexError(error)) {
          LoggerService.warning('Firestore index error detected: $error');
          
          // Show the index creation dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            FirestoreIndexHelper.showIndexCreationDialog(context, error.toString());
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
          return SliverToBoxAdapter(
            child: _buildEmptyState(context),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return _buildCategoryCard(context, category, locale);
              },
              childCount: categories.length,
            ),
          ),
        );
      },
    );
  }

  // Fallback method that uses the Future-based provider instead of Stream
  Widget _buildFallbackCategoriesGrid(BuildContext context, String locale) {
    final categoriesAsync = ref.watch(mainCategoriesProvider);

    return categoriesAsync.when(
      loading: () => SliverToBoxAdapter(
        child: _buildLoadingGrid(context),
      ),
      error: (error, stack) => SliverToBoxAdapter(
        child: _buildErrorWidget(context, 
          "Could not load categories. Please check your connection and try again."),
      ),
      data: (categories) {
        if (categories.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(context),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return _buildCategoryCard(context, category, locale);
              },
              childCount: categories.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category, String locale) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _onCategoryTap(category),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                ),
                child: _buildCategoryIcon(context, category),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  category.getLocalizedName(locale),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.type,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(BuildContext context, Category category) {
    IconData iconData;
    
    switch (category.type.toLowerCase()) {
      case 'furniture':
        iconData = Icons.chair;
        break;
      case 'electronics':
        iconData = Icons.devices;
        break;
      case 'clothing':
        iconData = Icons.checkroom;
        break;
      case 'books':
        iconData = Icons.menu_book;
        break;
      case 'sports':
        iconData = Icons.sports;
        break;
      case 'home':
        iconData = Icons.home;
        break;
      case 'beauty':
        iconData = Icons.face_retouching_natural;
        break;
      case 'automotive':
        iconData = Icons.directions_car;
        break;
      case 'health':
        iconData = Icons.health_and_safety;
        break;
      case 'food':
        iconData = Icons.restaurant;
        break;
      default:
        iconData = Icons.category;
    }

    if (category.iconUrl != null && category.iconUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          category.iconUrl!,
          width: 32,
          height: 32,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            iconData,
            size: 32,
            color: Theme.of(context).primaryColor,
          ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      );
    }

    return Icon(
      iconData,
      size: 32,
      color: Theme.of(context).primaryColor,
    );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
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

  Widget _buildBottomNavigation(BuildContext context, bool isGuest) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(context).colorScheme.outline,
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(isGuest ? Icons.person_outline : Icons.person),
          label: 'الملف الشخصي',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.notifications_outlined),
          label: 'الإشعارات',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'الإعدادات',
        ),
      ],
      onTap: _handleBottomNavTap,
    );
  }

  Future<void> _onCategoryTap(Category category) async {
    try {
      final hasSubcategories = await ref.read(hasSubcategoriesProvider(category.id).future);
      
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
              content: Text('خطأ في فتح التصنيف: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _handleBottomNavTap(int index) {
    if (!mounted) return;
    
    switch (index) {
      case 0:
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
}