import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';

class HeaderNavbar extends ConsumerWidget implements PreferredSizeWidget {
  const HeaderNavbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(76);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final cartState = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final cartCount = cartState.when(
      data: (cart) => cart?.totalItemCount ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.ivory,
        border: const Border(
          bottom: BorderSide(color: AppColors.warmBorder, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.espresso.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48.0 : 16.0,
            vertical: 12.0,
          ),
          child: Row(
            children: [
              // Mobile Drawer Trigger
              if (!isDesktop)
                IconButton(
                  icon: const Icon(Icons.menu_rounded, color: AppColors.espresso),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),

              // Brand Mark / Logo
              InkWell(
                onTap: () => context.go('/'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'WOOD CARVERS',
                      style: AppTypography.brandLogo(fontSize: isDesktop ? 22 : 18),
                    ),
                    Text(
                      'HANDCRAFTED TIMBER ARTIFACTS',
                      style: AppTypography.bodySmall(color: AppColors.naturalWood).copyWith(
                        fontSize: 9,
                        letterSpacing: 1.8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 36),

              // Desktop Navigation Links
              if (isDesktop)
                Expanded(
                  child: Row(
                    children: [
                      _NavLink(title: 'Home', path: '/'),
                      _NavLink(title: 'Shop All', path: '/shop'),
                      _NavLink(title: 'Wall Hangings', path: '/shop?category=wall-hangings'),
                      _NavLink(title: 'Statues', path: '/shop?category=statues'),
                      _NavLink(title: 'Toys', path: '/shop?category=wooden-toys'),
                      _NavLink(title: 'Decor', path: '/shop?category=home-decor'),
                      _NavLink(title: 'Gifts', path: '/shop?category=gifts'),
                    ],
                  ),
                )
              else
                const Spacer(),

              // Search Trigger
              IconButton(
                icon: const Icon(Icons.search_rounded, color: AppColors.espresso, size: 22),
                tooltip: 'Search Wood Pieces',
                onPressed: () => context.push('/shop'),
              ),

              // Wishlist Icon with Counter
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border_rounded, color: AppColors.espresso, size: 22),
                    tooltip: 'Wishlist',
                    onPressed: () {
                      if (authState.isAuthenticated) {
                        context.push('/wishlist');
                      } else {
                        context.push('/login');
                      }
                    },
                  ),
                  if (wishlist.isNotEmpty)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.terracotta,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          wishlist.length.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),

              // Cart Icon with Live Counter
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.espresso, size: 22),
                    tooltip: 'Cart',
                    onPressed: () => context.push('/cart'),
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.espresso,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          cartCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 8),

              // User Account / Profile Button
              if (authState.isAuthenticated)
                PopupMenuButton<String>(
                  tooltip: 'Account',
                  offset: const Offset(0, 48),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.softBeige.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.warmBorder, width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.espresso),
                        const SizedBox(width: 6),
                        Text(
                          authState.user?.name.split(' ').first ?? 'Account',
                          style: AppTypography.headingSmall(color: AppColors.espresso).copyWith(fontSize: 13),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.espresso),
                      ],
                    ),
                  ),
                  onSelected: (val) {
                    if (val == 'profile') context.push('/profile');
                    if (val == 'orders') context.push('/orders');
                    if (val == 'admin') context.push('/admin');
                    if (val == 'logout') ref.read(authProvider.notifier).logout();
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: const [
                          Icon(Icons.person_outline, size: 18, color: AppColors.espresso),
                          SizedBox(width: 10),
                          Text('My Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'orders',
                      child: Row(
                        children: const [
                          Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.espresso),
                          SizedBox(width: 10),
                          Text('My Orders'),
                        ],
                      ),
                    ),
                    if (authState.isAdmin)
                      PopupMenuItem(
                        value: 'admin',
                        child: Row(
                          children: const [
                            Icon(Icons.admin_panel_settings_outlined, size: 18, color: AppColors.antiqueGold),
                            SizedBox(width: 10),
                            Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.antiqueGold)),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: const [
                          Icon(Icons.logout, size: 18, color: AppColors.errorRed),
                          SizedBox(width: 10),
                          Text('Sign Out', style: TextStyle(color: AppColors.errorRed)),
                        ],
                      ),
                    ),
                  ],
                )
              else
                TextButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login_rounded, size: 18, color: AppColors.espresso),
                  label: Text('Sign In', style: AppTypography.buttonText(color: AppColors.espresso)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String title;
  final String path;

  const _NavLink({required this.title, required this.path});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: InkWell(
        onTap: () => context.go(path),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(
            title,
            style: AppTypography.headingSmall(color: AppColors.espresso).copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class MobileDrawer extends ConsumerWidget {
  const MobileDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Drawer(
      backgroundColor: AppColors.ivory,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WOOD CARVERS', style: AppTypography.brandLogo(fontSize: 20)),
                  const SizedBox(height: 4),
                  Text('Artisanal Handcrafted Decor', style: AppTypography.bodySmall(color: AppColors.naturalWood)),
                ],
              ),
            ),
            const Divider(color: AppColors.warmBorder),
            ListTile(
              leading: const Icon(Icons.home_outlined, color: AppColors.espresso),
              title: const Text('Home'),
              onTap: () { Navigator.pop(context); context.go('/'); },
            ),
            ListTile(
              leading: const Icon(Icons.storefront_outlined, color: AppColors.espresso),
              title: const Text('Shop All Products'),
              onTap: () { Navigator.pop(context); context.go('/shop'); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_frame_outlined, color: AppColors.espresso),
              title: const Text('Wall Hangings & Frames'),
              onTap: () { Navigator.pop(context); context.go('/shop?category=wall-hangings'); },
            ),
            ListTile(
              leading: const Icon(Icons.toys_outlined, color: AppColors.espresso),
              title: const Text('Wooden Toys'),
              onTap: () { Navigator.pop(context); context.go('/shop?category=wooden-toys'); },
            ),
            ListTile(
              leading: const Icon(Icons.card_giftcard_outlined, color: AppColors.espresso),
              title: const Text('Artisanal Gifts'),
              onTap: () { Navigator.pop(context); context.go('/shop?category=gifts'); },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined, color: AppColors.espresso),
              title: const Text('My Orders'),
              onTap: () { Navigator.pop(context); context.push('/orders'); },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline, color: AppColors.espresso),
              title: const Text('Wishlist'),
              onTap: () { Navigator.pop(context); context.push('/wishlist'); },
            ),
            if (authState.isAdmin) ...[
              const Divider(color: AppColors.warmBorder),
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: AppColors.antiqueGold),
                title: const Text('Admin Dashboard', style: TextStyle(color: AppColors.antiqueGold, fontWeight: FontWeight.bold)),
                onTap: () { Navigator.pop(context); context.push('/admin'); },
              ),
            ],
            const Spacer(),
            const Divider(color: AppColors.warmBorder),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: authState.isAuthenticated
                  ? OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authProvider.notifier).logout();
                      },
                      icon: const Icon(Icons.logout, color: AppColors.errorRed),
                      label: const Text('Sign Out', style: TextStyle(color: AppColors.errorRed)),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/login');
                      },
                      child: const Center(child: Text('Sign In')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
