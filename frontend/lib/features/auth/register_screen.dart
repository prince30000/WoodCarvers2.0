import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/wood_text_field.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      phone: _phoneCtrl.text.trim(),
    );

    if (success && mounted) {
      context.go('/');
    } else if (mounted) {
      final err = ref.read(authProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Registration failed'), backgroundColor: AppColors.errorRed),
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
                    InkWell(
                      onTap: () => context.go('/'),
                      child: Column(
                        children: [
                          Text('WOOD CARVERS', style: AppTypography.brandLogo(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text('Join the Artisanal Community', style: AppTypography.bodySmall(color: AppColors.naturalWood)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Create Your Account', style: AppTypography.headingMedium(color: AppColors.espresso), textAlign: TextAlign.center),
                    const SizedBox(height: 20),

                    WoodTextField(
                      label: 'Full Name',
                      hint: 'Your name',
                      controller: _nameCtrl,
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.naturalWood, size: 20),
                      validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    WoodTextField(
                      label: 'Email Address',
                      hint: 'name@domain.com',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, color: AppColors.naturalWood, size: 20),
                      validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                    ),
                    const SizedBox(height: 14),

                    WoodTextField(
                      label: 'Phone Number (Optional)',
                      hint: '+91 9876543210',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.naturalWood, size: 20),
                    ),
                    const SizedBox(height: 14),

                    WoodTextField(
                      label: 'Password',
                      hint: 'At least 6 characters',
                      controller: _passwordCtrl,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.naturalWood, size: 20),
                      validator: (v) => (v == null || v.length < 6) ? 'Password must be 6+ chars' : null,
                    ),
                    const SizedBox(height: 24),

                    WoodButton(
                      text: 'Create Account',
                      variant: WoodButtonVariant.primary,
                      height: 48,
                      isLoading: authState.isLoading,
                      onPressed: _handleRegister,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ', style: TextStyle(fontSize: 13)),
                        InkWell(
                          onTap: () => context.push('/login'),
                          child: const Text(
                            'Sign In',
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
