import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/animations/woodcarver_transitions.dart';
import '../features/home/home_screen.dart';
import '../features/shop/shop_screen.dart';
import '../features/product_details/product_details_screen.dart';
import '../features/cart/cart_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/orders/orders_list_screen.dart';
import '../features/orders/order_detail_screen.dart';
import '../features/wishlist/wishlist_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/admin/admin_shell_screen.dart';
import '../features/admin/admin_dashboard_screen.dart';
import '../features/admin/admin_products_screen.dart';
import '../features/admin/admin_product_form_screen.dart';
import '../features/admin/admin_categories_screen.dart';
import '../features/admin/admin_orders_screen.dart';
import '../features/admin/admin_customers_screen.dart';

CustomTransitionPage buildWoodTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slide = Tween<Offset>(begin: const Offset(0.015, 0), end: Offset.zero).animate(curvedAnimation);
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

      return SlideTransition(
        position: slide,
        child: FadeTransition(opacity: fade, child: child),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Customer Storefront Routes
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: const HomeScreen(),
      ),
    ),
    GoRoute(
      path: '/shop',
      pageBuilder: (context, state) {
        final category = state.uri.queryParameters['category'];
        final isFeatured = state.uri.queryParameters['isFeatured'] == 'true';
        final isBestseller = state.uri.queryParameters['isBestseller'] == 'true';

        return buildWoodTransitionPage(
          context: context,
          state: state,
          child: ShopScreen(
            initialCategory: category,
            isFeatured: isFeatured,
            isBestseller: isBestseller,
          ),
        );
      },
    ),
    GoRoute(
      path: '/product/:slugOrId',
      pageBuilder: (context, state) {
        final slugOrId = state.pathParameters['slugOrId'] ?? '';
        return buildWoodTransitionPage(
          context: context,
          state: state,
          child: ProductDetailsScreen(slugOrId: slugOrId),
        );
      },
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: const CartScreen(),
      ),
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: const CheckoutScreen(),
      ),
    ),
    GoRoute(
      path: '/orders',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: const OrdersListScreen(),
      ),
    ),
    GoRoute(
      path: '/orders/:id',
      pageBuilder: (context, state) {
        final orderId = state.pathParameters['id'] ?? '';
        return buildWoodTransitionPage(
          context: context,
          state: state,
          child: OrderDetailScreen(orderId: orderId),
        );
      },
    ),
    GoRoute(
      path: '/wishlist',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: const WishlistScreen(),
      ),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: const ProfileScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/register',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: const RegisterScreen(),
      ),
    ),

    // Admin Operations Routes
    GoRoute(
      path: '/admin',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: AdminShellScreen(
          currentRoute: '/admin',
          child: const AdminDashboardScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/products',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: AdminShellScreen(
          currentRoute: '/admin/products',
          child: const AdminProductsScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/products/new',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: AdminShellScreen(
          currentRoute: '/admin/products/new',
          child: const AdminProductFormScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/products/edit/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id'];
        return buildWoodTransitionPage(
          context: context,
          state: state,
          child: AdminShellScreen(
            currentRoute: '/admin/products/edit',
            child: AdminProductFormScreen(productId: id),
          ),
        );
      },
    ),
    GoRoute(
      path: '/admin/categories',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: AdminShellScreen(
          currentRoute: '/admin/categories',
          child: const AdminCategoriesScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/orders',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: AdminShellScreen(
          currentRoute: '/admin/orders',
          child: const AdminOrdersScreen(),
        ),
      ),
    ),
    GoRoute(
      path: '/admin/customers',
      pageBuilder: (context, state) => buildWoodTransitionPage(
        context: context,
        state: state,
        child: AdminShellScreen(
          currentRoute: '/admin/customers',
          child: const AdminCustomersScreen(),
        ),
      ),
    ),
  ],
);
