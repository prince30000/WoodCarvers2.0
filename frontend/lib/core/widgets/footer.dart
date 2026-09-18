import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/responsive.dart';
import 'wood_button.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      color: AppColors.espresso,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: 48,
      ),
      child: Column(
        children: [
          // Trust Badges Row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.darkWalnut,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorder, width: 0.8),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 24,
              runSpacing: 20,
              children: const [
                _TrustBadge(
                  icon: Icons.park_outlined,
                  title: '100% Seasoned Hardwood',
                  subtitle: 'Sheesham, Teak, Walnut & Rosewood',
                ),
                _TrustBadge(
                  icon: Icons.front_hand_outlined,
                  title: 'Artisan Hand-Carved',
                  subtitle: 'Heritage generational wood sculptors',
                ),
                _TrustBadge(
                  icon: Icons.inventory_2_outlined,
                  title: 'Eco-Armor Packaging',
                  subtitle: 'Shockproof zero-damage delivery',
                ),
                _TrustBadge(
                  icon: Icons.lock_outline_rounded,
                  title: 'Secure Payment',
                  subtitle: 'Verified by Razorpay Gateway',
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Main Footer Grid
          Wrap(
            spacing: 48,
            runSpacing: 32,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Column 1: Brand & Tagline
              SizedBox(
                width: isDesktop ? 320 : double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WOOD CARVERS', style: AppTypography.brandLogo(color: Colors.white, fontSize: 20)),
                    const SizedBox(height: 12),
                    Text(
                      'Handcrafted wooden pieces made to bring character to your space. Small to medium decorative artifacts created with patience, precision, and passion.',
                      style: AppTypography.bodyMedium(color: AppColors.softBeige.withOpacity(0.85)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        Icon(Icons.workspace_premium_outlined, color: AppColors.antiqueGold, size: 20),
                        SizedBox(width: 8),
                        Text('Crafted with Pride in India', style: TextStyle(color: AppColors.antiqueGold, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),

              // Column 2: Categories
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CATEGORIES', style: AppTypography.headingSmall(color: Colors.white).copyWith(fontSize: 13, letterSpacing: 1.2)),
                    const SizedBox(height: 14),
                    _FooterLink('Wall Hangings', () => context.go('/shop?category=wall-hangings')),
                    _FooterLink('Wooden Toys', () => context.go('/shop?category=wooden-toys')),
                    _FooterLink('Photo Frames', () => context.go('/shop?category=frames')),
                    _FooterLink('Statues & Sculptures', () => context.go('/shop?category=statues')),
                    _FooterLink('Decorative Stands', () => context.go('/shop?category=decorative-stands')),
                    _FooterLink('Artisanal Gifts', () => context.go('/shop?category=gifts')),
                  ],
                ),
              ),

              // Column 3: Customer Care
              SizedBox(
                width: 160,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CUSTOMER CARE', style: AppTypography.headingSmall(color: Colors.white).copyWith(fontSize: 13, letterSpacing: 1.2)),
                    const SizedBox(height: 14),
                    _FooterLink('Track Order', () => context.push('/orders')),
                    _FooterLink('Wood Care Guide', () => context.go('/shop')),
                    _FooterLink('Shipping & Dispatch', () => context.go('/shop')),
                    _FooterLink('7-Day Easy Returns', () => context.go('/shop')),
                    _FooterLink('FAQ & Inquiries', () => context.go('/shop')),
                  ],
                ),
              ),

              // Column 4: Newsletter
              SizedBox(
                width: isDesktop ? 280 : double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('JOIN THE COLLECTORS CLUB', style: AppTypography.headingSmall(color: Colors.white).copyWith(fontSize: 13, letterSpacing: 1.2)),
                    const SizedBox(height: 10),
                    Text(
                      'Receive exclusive invitations to small-batch artisanal releases and woodworking stories.',
                      style: AppTypography.bodySmall(color: AppColors.softBeige.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.darkWalnut,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: const TextField(
                              style: TextStyle(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        WoodButton(
                          text: 'Join',
                          variant: WoodButtonVariant.gold,
                          height: 42,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Thank you for subscribing to Wood Carvers! 🪵')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),
          const Divider(color: AppColors.darkBorder),
          const SizedBox(height: 20),

          // Copyright & Admin portal shortcut
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '© 2026 WOOD CARVERS. All rights reserved. Handcrafted Decorative Timber.',
                style: AppTypography.bodySmall(color: AppColors.textMuted).copyWith(fontSize: 11),
              ),
              InkWell(
                onTap: () => context.push('/admin'),
                child: Text(
                  'Admin Portal 🔒',
                  style: AppTypography.bodySmall(color: AppColors.textMuted).copyWith(
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustBadge({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: AppColors.antiqueGold),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
          ],
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink(this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: AppTypography.bodySmall(color: AppColors.softBeige.withOpacity(0.85)).copyWith(fontSize: 13),
        ),
      ),
    );
  }
}
