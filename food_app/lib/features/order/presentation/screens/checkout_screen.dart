import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../cart/data/cart_repository.dart';
import '../../../cart/data/models/cart.dart';
import '../../../profile/data/models/address_model.dart';
import '../../../profile/data/user_repository.dart';
import '../../data/order_repository.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({
    super.key,
    required this.cartRepository,
    required this.userRepository,
    required this.orderRepository,
  });

  final CartRepository cartRepository;
  final UserRepository userRepository;
  final OrderRepository orderRepository;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  CartModel? _cart;
  List<AddressModel> _addresses = const [];
  AddressModel? _selectedAddress;
  final _promoController = TextEditingController();
  final _noteController = TextEditingController();
  String _paymentMethod = 'COD';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _promoController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cart = await widget.cartRepository.fetchCart();
      final addresses = await widget.userRepository.getAddresses();
      if (!mounted) return;
      setState(() {
        _cart = cart;
        _addresses = addresses;
        _selectedAddress = addresses.firstWhere(
          (e) => e.defaultAddress,
          orElse: () => addresses.isNotEmpty
              ? addresses.first
              : AddressModel(
                  id: 0,
                  label: '',
                  streetLine1: '',
                  streetLine2: null,
                  city: '',
                  state: '',
                  postalCode: '',
                  countryCode: 'VN',
                  latitude: null,
                  longitude: null,
                  defaultAddress: false,
                ),
        );
        if ((_selectedAddress?.id ?? 0) == 0) _selectedAddress = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final order = await widget.orderRepository.placeOrder(
        deliveryAddressId: _selectedAddress!.id,
        paymentMethod: _paymentMethod,
        specialInstructions: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        promoCode: _promoController.text.trim().isEmpty
            ? null
            : _promoController.text.trim(),
      );
      if (!mounted) return;
      context.go('/orders/${order.id}/tracking');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Xác nhận đặt hàng')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 8),
              FilledButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    final cart = _cart;
    if (cart == null || cart.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Xác nhận đặt hàng')),
        body: const Center(child: Text('Giỏ hàng trống')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đặt hàng')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Giao đến', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_addresses.isEmpty)
            Card(
              child: ListTile(
                title: const Text('Chưa có địa chỉ giao hàng'),
                subtitle: const Text('Vui lòng thêm địa chỉ trong Hồ sơ'),
                trailing: TextButton(
                  onPressed: () => context.push('/profile/addresses'),
                  child: const Text('Mở'),
                ),
              ),
            )
          else
            ..._addresses.map(
              (a) => ListTile(
                onTap: () => setState(() => _selectedAddress = a),
                leading: Icon(
                  _selectedAddress?.id == a.id
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                ),
                title: Text(a.label),
                subtitle: Text(a.shortText),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: const ['COD', 'CREDIT_CARD', 'MOMO', 'ZALOPAY'].map((
              method,
            ) {
              return ChoiceChip(
                label: Text(Formatters.paymentMethodLabel(method)),
                selected: _paymentMethod == method,
                onSelected: (_) => setState(() => _paymentMethod = method),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _promoController,
            decoration: const InputDecoration(
              labelText: 'Mã giảm giá',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ghi chú đơn hàng',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _summary('Tạm tính', Formatters.money(cart.subtotal)),
                  _summary('Phí giao hàng', Formatters.money(cart.deliveryFee)),
                  const Divider(),
                  _summary(
                    'Tổng cộng',
                    Formatters.money(cart.total),
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _submitting ? null : _placeOrder,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Xác nhận đặt hàng'),
        ),
      ),
    );
  }

  Widget _summary(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ],
    );
  }
}
