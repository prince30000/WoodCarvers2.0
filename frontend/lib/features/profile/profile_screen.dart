import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/wood_text_field.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _addressFormKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _streetCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController(text: 'Karnataka');
  final _postalCtrl = TextEditingController();

  bool _isAddingAddress = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSaveAddress() async {
    if (!_addressFormKey.currentState!.validate()) return;

    try {
      await ref.read(authProvider.notifier).addAddress({
        'fullName': _fullNameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'street': _streetCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'postalCode': _postalCtrl.text.trim(),
        'country': 'India',
        'isDefault': true,
      });

      setState(() => _isAddingAddress = false);
      _streetCtrl.clear();
      _cityCtrl.clear();
      _postalCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save address: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: const HeaderNavbar(),
      drawer: const MobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 28,
              ),
              color: AppColors.espresso,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MY ACCOUNT', style: AppTypography.bodySmall(color: AppColors.antiqueGold).copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(user?.name ?? 'Collector Profile', style: AppTypography.displayMedium(color: Colors.white)),
                  ],
                ),
              ),
            ),

            // Profile info & address manager
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 36,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Overview Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warmBorder),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.espresso,
                            child: Text(
                              (user?.name.isNotEmpty == true ? user!.name[0] : 'W').toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user?.name ?? '', style: AppTypography.headingMedium()),
                                const SizedBox(height: 4),
                                Text(user?.email ?? '', style: AppTypography.bodyMedium(color: AppColors.textMuted)),
                                if (user?.phone.isNotEmpty == true) ...[
                                  const SizedBox(height: 2),
                                  Text(user!.phone, style: AppTypography.bodySmall()),
                                ],
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {
                              ref.read(authProvider.notifier).logout();
                              context.go('/');
                            },
                            icon: const Icon(Icons.logout, color: AppColors.errorRed, size: 18),
                            label: const Text('Sign Out', style: TextStyle(color: AppColors.errorRed)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Quick Links (Orders, Wishlist, Admin)
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _QuickLinkCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'My Orders',
                          subtitle: 'View and track your packages',
                          onTap: () => context.push('/orders'),
                        ),
                        _QuickLinkCard(
                          icon: Icons.favorite_outline,
                          title: 'My Wishlist',
                          subtitle: 'Saved handcrafted items',
                          onTap: () => context.push('/wishlist'),
                        ),
                        if (user?.isAdmin == true)
                          _QuickLinkCard(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Admin Operations',
                            subtitle: 'Manage catalog & orders',
                            onTap: () => context.push('/admin'),
                          ),
                      ],
                    ),

                    const SizedBox(height: 36),

                    // Saved Addresses Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Saved Addresses', style: AppTypography.headingMedium(color: AppColors.espresso)),
                        if (!_isAddingAddress)
                          WoodButton(
                            text: 'Add New Address',
                            icon: Icons.add,
                            variant: WoodButtonVariant.outline,
                            height: 40,
                            onPressed: () {
                              _fullNameCtrl.text = user?.name ?? '';
                              _phoneCtrl.text = user?.phone ?? '';
                              setState(() => _isAddingAddress = true);
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Add Address Inline Form
                    if (_isAddingAddress)
                      Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.naturalWood),
                        ),
                        child: Form(
                          key: _addressFormKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Add Delivery Address', style: AppTypography.headingSmall()),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'Full Name *',
                                      controller: _fullNameCtrl,
                                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'Phone *',
                                      controller: _phoneCtrl,
                                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              WoodTextField(
                                label: 'Street Address *',
                                controller: _streetCtrl,
                                validator: (v) => v?.isEmpty == true ? 'Required' : null,
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'City *',
                                      controller: _cityCtrl,
                                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: WoodTextField(
                                      label: 'PIN Code *',
                                      controller: _postalCtrl,
                                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  WoodButton(
                                    text: 'Save Address',
                                    onPressed: _handleSaveAddress,
                                    variant: WoodButtonVariant.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  TextButton(
                                    onPressed: () => setState(() => _isAddingAddress = false),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Saved Addresses List
                    if (user?.addresses.isEmpty == true)
                      const Text('No saved addresses yet.')
                    else
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: (user?.addresses ?? []).map((addr) {
                          return Container(
                            width: 320,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.warmBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(addr.fullName, style: AppTypography.headingSmall()),
                                    if (addr.isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.softBeige,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('DEFAULT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(addr.street, style: AppTypography.bodySmall()),
                                Text('${addr.city}, ${addr.state} - ${addr.postalCode}', style: AppTypography.bodySmall()),
                                const SizedBox(height: 4),
                                Text('Phone: ${addr.phone}', style: AppTypography.bodySmall()),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 48),
            const FooterWidget(),
          ],
        ),
      ),
    );
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.warmBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.naturalWood, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.headingSmall()),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.bodySmall(color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
