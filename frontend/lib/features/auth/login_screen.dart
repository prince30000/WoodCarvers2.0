import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/wood_text_field.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController(text: 'customer@woodcarvers.com');
  final _passwordCtrl = TextEditingController(text: 'Customer@123456');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (success && mounted) {
      final user = ref.read(authProvider).user;
      if (user?.isAdmin == true) {
        context.go('/admin');
      } else {
        context.go('/');
      }
    } else if (mounted) {
      final err = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Authentication failed'), backgroundColor: AppColors.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Container(
              padding: const EdgeInsets.all(36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warmBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.espresso.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Heading
                    InkWell(
                      onTap: () => context.go('/'),
                      child: Column(
                        children: [
                          Text('WOOD CARVERS', style: AppTypography.brandLogo(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text('Artisanal Handcrafted Decor', style: AppTypography.bodySmall(color: AppColors.naturalWood)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text('Welcome Back', style: AppTypography.headingMedium(color: AppColors.espresso), textAlign: TextAlign.center),
                    const SizedBox(height: 6),
                    Text('Sign in to access your bag, saved pieces & orders', style: AppTypography.bodySmall(), textAlign: TextAlign.center),
                    const SizedBox(height: 24),

                    // Email Field
                    WoodTextField(
                      label: 'Email Address',
                      hint: 'name@domain.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.naturalWood, size: 20),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    WoodTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.naturalWood, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 18),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Password must be 6+ chars' : null,
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    WoodButton(
                      text: 'Sign In',
                      variant: WoodButtonVariant.primary,
                      height: 48,
                      isLoading: authState.isLoading,
                      onPressed: _handleLogin,
                    ),

                    const SizedBox(height: 16),

                    // Quick Demo Credentials hint
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.softBeige.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Demo Credentials:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () {
                              _emailCtrl.text = 'admin@woodcarvers.com';
                              _passwordCtrl.text = 'Admin@123456';
                            },
                            child: const Text('Admin: admin@woodcarvers.com / Admin@123456', style: TextStyle(fontSize: 11, color: AppColors.espresso)),
                          ),
                          const SizedBox(height: 2),
                          InkWell(
                            onTap: () {
                              _emailCtrl.text = 'customer@woodcarvers.com';
                              _passwordCtrl.text = 'Customer@123456';
                            },
                            child: const Text('Customer: customer@woodcarvers.com / Customer@123456', style: TextStyle(fontSize: 11, color: AppColors.espresso)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Register Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Don\'t have an account? ', style: TextStyle(fontSize: 13)),
                        InkWell(
                          onTap: () => context.push('/register'),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.naturalWood),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
