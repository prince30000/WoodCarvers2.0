import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/navbar.dart';
import '../../core/widgets/footer.dart';
import '../../core/widgets/wood_button.dart';
import '../../core/widgets/wood_text_field.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController(text: 'Karnataka');
  final _postalCodeController = TextEditingController();

  String _paymentMethod = 'RAZORPAY';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final authUser = ref.read(authProvider).user;
    if (authUser != null) {
      _nameController.text = authUser.name;
      _phoneController.text = authUser.phone;
      if (authUser.addresses.isNotEmpty) {
        final defAddr = authUser.addresses.firstWhere((a) => a.isDefault, orElse: () => authUser.addresses.first);
        _streetController.text = defAddr.street;
        _landmarkController.text = defAddr.landmark;
        _cityController.text = defAddr.city;
        _stateController.text = defAddr.state;
        _postalCodeController.text = defAddr.postalCode;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _handlePlaceOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final shippingAddress = {
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'street': _streetController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postalCode': _postalCodeController.text.trim(),
        'country': 'India',
      };

      // 1. Create order on backend (which verifies stock & live prices)
      final orderActions = ref.read(orderActionsProvider);
      final createdOrder = await orderActions.createOrder(
        shippingAddress: shippingAddress,
        paymentMethod: _paymentMethod,
      );

      if (_paymentMethod == 'COD') {
        // Direct order confirmation
        if (mounted) {
          _showConfirmationDialog(createdOrder.orderNumber, isCod: true);
        }
      } else {
        // 2. Initiate Razorpay payment through backend
        final paymentDetails = await orderActions.initiateRazorpayPayment(createdOrder.id);

        // In production mobile/web: launch Razorpay checkout modal.
        // Here we simulate successful gateway verification handshake with the backend
        final mockPaymentId = 'pay_rzp_${DateTime.now().millisecondsSinceEpoch}';
        final mockSignature = 'mock_sig_${DateTime.now().millisecondsSinceEpoch}';

        // 3. Cryptographic payment signature verification on the backend
        final verifiedOrder = await orderActions.verifyPayment(
          orderId: createdOrder.id,
          razorpayOrderId: paymentDetails['razorpayOrderId'],
          razorpayPaymentId: mockPaymentId,
          razorpaySignature: mockSignature,
        );

        if (mounted) {
          _showConfirmationDialog(verifiedOrder.orderNumber, isCod: false);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: ${e.toString()}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showConfirmationDialog(String orderNumber, {required bool isCod}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.ivory,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 56),
              ),
              const SizedBox(height: 20),
              Text('Order Confirmed! 🪵', style: AppTypography.headingLarge()),
              const SizedBox(height: 8),
              Text(
                'Order ID: $orderNumber',
                style: AppTypography.bodyMedium(color: AppColors.naturalWood).copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                isCod
                  ? 'Your handcrafted wooden order has been queued. Please pay upon delivery.'
                  : 'Payment verified via Razorpay. Our master craftsmen will begin preparing and dispatching your heirloom pieces.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(),
              ),
              const SizedBox(height: 24),
              WoodButton(
                text: 'View My Orders & Track',
                icon: Icons.local_shipping_outlined,
                variant: WoodButtonVariant.gold,
                width: double.infinity,
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/orders');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: const HeaderNavbar(),
      drawer: const MobileDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner
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
                    Text('CHECKOUT', style: AppTypography.bodySmall(color: AppColors.antiqueGold).copyWith(letterSpacing: 2, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Delivery & Payment Details', style: AppTypography.displayMedium(color: Colors.white)),
                  ],
                ),
              ),
            ),

            // Form Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64 : 20,
                vertical: 36,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Form(
                  key: _formKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Shipping & Payment form
                      Expanded(
                        flex: isDesktop ? 7 : 12,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('1. Shipping Address', style: AppTypography.headingMedium(color: AppColors.espresso)),
                            const SizedBox(height: 16),
                            WoodTextField(
                              label: 'Full Name *',
                              hint: 'Recipient name',
                              controller: _nameController,
                              validator: (v) => (v == null || v.isEmpty) ? 'Full name is required' : null,
                            ),
                            const SizedBox(height: 14),
                            WoodTextField(
                              label: 'Contact Phone Number *',
                              hint: '10-digit mobile number for courier tracking',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              validator: (v) => (v == null || v.length < 10) ? 'Valid phone number is required' : null,
                            ),
                            const SizedBox(height: 14),
                            WoodTextField(
                              label: 'Street Address & Flat / House No. *',
                              hint: 'e.g. 42 Artisanal Villa, 3rd Cross',
                              controller: _streetController,
                              validator: (v) => (v == null || v.isEmpty) ? 'Street address is required' : null,
                            ),
                            const SizedBox(height: 14),
                            WoodTextField(
                              label: 'Landmark (Optional)',
                              hint: 'e.g. Near Banyan Tree Square',
                              controller: _landmarkController,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: WoodTextField(
                                    label: 'City *',
                                    hint: 'e.g. Bengaluru',
                                    controller: _cityController,
                                    validator: (v) => (v == null || v.isEmpty) ? 'City is required' : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: WoodTextField(
                                    label: 'State *',
                                    hint: 'e.g. Karnataka',
                                    controller: _stateController,
                                    validator: (v) => (v == null || v.isEmpty) ? 'State is required' : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            WoodTextField(
                              label: 'Postal PIN Code *',
                              hint: 'e.g. 560038',
                              controller: _postalCodeController,
                              keyboardType: TextInputType.number,
                              validator: (v) => (v == null || v.length < 5) ? 'Valid PIN code is required' : null,
                            ),

                            const SizedBox(height: 36),
                            Text('2. Payment Method', style: AppTypography.headingMedium(color: AppColors.espresso)),
                            const SizedBox(height: 16),

                            // Payment method selector
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.warmBorder),
                              ),
                              child: Column(
                                children: [
                                  RadioListTile<String>(
                                    value: 'RAZORPAY',
                                    groupValue: _paymentMethod,
                                    activeColor: AppColors.espresso,
                                    title: const Text('Razorpay (UPI, Credit/Debit Cards, NetBanking)'),
                                    subtitle: const Text('Encrypted 256-bit instant online payment', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                    secondary: const Icon(Icons.payment_rounded, color: AppColors.naturalWood),
                                    onChanged: (val) => setState(() => _paymentMethod = val!),
                                  ),
                                  const Divider(height: 1, color: AppColors.warmBorder),
                                  RadioListTile<String>(
                                    value: 'COD',
                                    groupValue: _paymentMethod,
                                    activeColor: AppColors.espresso,
                                    title: const Text('Cash on Delivery (COD)'),
                                    subtitle: const Text('Pay securely in cash or UPI upon courier arrival', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                    secondary: const Icon(Icons.local_shipping_outlined, color: AppColors.naturalWood),
                                    onChanged: (val) => setState(() => _paymentMethod = val!),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isDesktop) const SizedBox(width: 48),

                      // Right: Order confirmation card
                      if (isDesktop)
                        Expanded(
                          flex: 5,
                          child: cartAsync.when(
                            data: (cart) => _buildOrderSummarySideCard(cart?.subtotal ?? 0, cart?.shipping ?? 0, cart?.total ?? 0),
                            loading: () => const CircularProgressIndicator(),
                            error: (_, __) => const SizedBox(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Mobile confirmation button fallback
            if (!isDesktop)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: cartAsync.when(
                  data: (cart) => _buildOrderSummarySideCard(cart?.subtotal ?? 0, cart?.shipping ?? 0, cart?.total ?? 0),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ),

            const SizedBox(height: 48),
            const FooterWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummarySideCard(num subtotal, num shipping, num total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warmBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Confirm', style: AppTypography.headingMedium(color: AppColors.espresso)),
          const SizedBox(height: 16),
          const Divider(color: AppColors.warmBorder),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Items Subtotal', style: AppTypography.bodyMedium()),
              Text(Formatters.formatCurrency(subtotal), style: AppTypography.bodyMedium(color: AppColors.espresso)),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Artisanal Packaging & Shipping', style: AppTypography.bodyMedium()),
              Text(shipping == 0 ? 'FREE' : Formatters.formatCurrency(shipping), style: TextStyle(color: shipping == 0 ? AppColors.successGreen : AppColors.espresso, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.warmBorder),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Final Amount to Pay', style: AppTypography.headingSmall(color: AppColors.espresso)),
              Text(Formatters.formatCurrency(total), style: AppTypography.priceLarge(color: AppColors.espresso)),
            ],
          ),
          const SizedBox(height: 24),

          WoodButton(
            text: _paymentMethod == 'COD' ? 'Confirm & Place COD Order' : 'Pay via Razorpay',
            icon: Icons.lock,
            variant: WoodButtonVariant.gold,
            height: 52,
            width: double.infinity,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _handlePlaceOrder,
          ),
        ],
      ),
    );
  }
}
