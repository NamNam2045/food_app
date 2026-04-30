import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/models/order_models.dart';
import '../../data/order_repository.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    required this.orderRepository,
  });

  final int orderId;
  final OrderRepository orderRepository;

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  bool _loading = true;
  String? _error;
  OrderDetailModel? _order;
  Timer? _timer;

  static const orderFlow = <String>[
    'PENDING',
    'CONFIRMED',
    'PREPARING',
    'ON_THE_WAY',
    'DELIVERED',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _load(silent: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final order = await widget.orderRepository.getOrderDetail(widget.orderId);
      if (!mounted) return;
      setState(() {
        _order = order;
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Theo dõi đơn hàng')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Không thể tải dữ liệu'),
              const SizedBox(height: 8),
              FilledButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    final order = _order!;
    final currentIndex = orderFlow.indexOf(order.status);

    return Scaffold(
      appBar: AppBar(title: const Text('Theo dõi đơn hàng')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              order.orderNumber,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text('Nhà hàng: ${order.restaurantName}'),
            if (order.estimatedDeliveryAt != null)
              Text(
                'Dự kiến: ${Formatters.dateTime(order.estimatedDeliveryAt)}',
              ),
            const SizedBox(height: 14),
            ...orderFlow.asMap().entries.map((entry) {
              final idx = entry.key;
              final status = entry.value;
              final active = idx <= currentIndex;
              final now = idx == currentIndex;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  active ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: active ? Colors.green : Colors.grey,
                ),
                title: Text(
                  '${Formatters.orderStatusLabel(status)}${now ? ' (NOW)' : ''}',
                ),
              );
            }),
            const SizedBox(height: 8),
            Card(
              color: Colors.grey.shade100,
              child: const SizedBox(
                height: 180,
                child: Center(child: Text('Map view placeholder')),
              ),
            ),
            const SizedBox(height: 8),
            if ((order.restaurantPhone ?? '').isNotEmpty)
              OutlinedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.phone),
                label: Text('Liên hệ nhà hàng: ${order.restaurantPhone}'),
              ),
          ],
        ),
      ),
    );
  }
}
