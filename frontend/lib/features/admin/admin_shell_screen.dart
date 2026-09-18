import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';

class AdminShellScreen extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const AdminShellScreen({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    // Route Guard for Admin
    if (!authState.isAuthenticated || !authState.isAdmin) {
      return Scaffold(
        backgroundColor: AppColors.ivory,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            constraints: const BoxConstraints(maxWidth: 440),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warmBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.security, size: 48, color: AppColors.errorRed),
                const SizedBox(height: 16),
                Text('Admin Access Restricted', style: AppTypography.headingLarge(color: AppColors.espresso)),
                const SizedBox(height: 8),
                const Text(
                  'You must be signed in with an administrator account to access the Wood Carvers management console.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Go to Admin Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: AppColors.espresso,
              title: Text('WOOD CARVERS ADMIN', style: AppTypography.brandLogo(color: Colors.white, fontSize: 16)),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
      drawer: isDesktop ? null : Drawer(child: _buildSidebar(context, ref)),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 260,
              child: _buildSidebar(context, ref),
            ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.espresso,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Brand
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WOOD CARVERS', style: AppTypography.brandLogo(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.antiqueGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'OPERATIONS DASHBOARD',
                    style: TextStyle(color: AppColors.espresso, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.darkBorder),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _AdminMenuItem(
                  icon: Icons.dashboard_outlined,
                  title: 'Dashboard Overview',
                  isActive: currentRoute == '/admin' || currentRoute == '/admin/dashboard',
                  onTap: () => context.go('/admin'),
                ),
                _AdminMenuItem(
                  icon: Icons.park_outlined,
                  title: 'Product Catalog',
                  isActive: currentRoute.startsWith('/admin/products'),
                  onTap: () => context.go('/admin/products'),
                ),
                _AdminMenuItem(
                  icon: Icons.category_outlined,
                  title: 'Categories',
                  isActive: currentRoute.startsWith('/admin/categories'),
                  onTap: () => context.go('/admin/categories'),
                ),
                _AdminMenuItem(
                  icon: Icons.receipt_long_outlined,
                  title: 'Customer Orders',
                  isActive: currentRoute.startsWith('/admin/orders'),
                  onTap: () => context.go('/admin/orders'),
                ),
                _AdminMenuItem(
                  icon: Icons.people_outline,
                  title: 'Customers',
                  isActive: currentRoute.startsWith('/admin/customers'),
                  onTap: () => context.go('/admin/customers'),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.darkBorder),

          // Return to Customer Storefront
          _AdminMenuItem(
            icon: Icons.storefront_outlined,
            title: 'Live Storefront',
            isActive: false,
            onTap: () => context.go('/'),
          ),

          // Admin Sign Out
          _AdminMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            isActive: false,
            color: AppColors.errorRed,
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AdminMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;

  const _AdminMenuItem({
    required this.icon,
    required this.title,
    required this.isActive,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.darkWalnut : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: isActive ? Border.all(color: AppColors.antiqueGold.withOpacity(0.5)) : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color ?? (isActive ? AppColors.antiqueGold : Colors.white70),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: color ?? (isActive ? Colors.white : Colors.white70),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
