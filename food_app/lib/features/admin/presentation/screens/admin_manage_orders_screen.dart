import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../order/data/models/order_models.dart';
import '../../../order/data/order_repository.dart';
import '../../../../core/utils/formatters.dart';

class AdminManageOrdersScreen extends StatefulWidget {
  const AdminManageOrdersScreen({
    super.key,
    required this.orderRepository,
    required this.restaurantId,
  });

  final OrderRepository orderRepository;
  final int restaurantId;

  @override
  State<AdminManageOrdersScreen> createState() =>
      _AdminManageOrdersScreenState();
}

class _AdminManageOrdersScreenState extends State<AdminManageOrdersScreen> {
  bool _loading = true;
  String? _error;
  String? _status;
  List<OrderSummaryModel> _orders = const [];

  static const statusFilters = <String?>[
    null,
    'PENDING',
    'CONFIRMED',
    'PREPARING',
    'ON_THE_WAY',
    'DELIVERED',
    'CANCELLED',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await widget.orderRepository.getRestaurantOrders(
        restaurantId: widget.restaurantId,
        status: _status,
      );
      if (!mounted) return;
      setState(() {
        _orders = orders;
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

  Future<void> _updateStatus(OrderSummaryModel order) async {
    String status = order.status;
    final noteController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cập nhật trạng thái ${order.orderNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: status,
              items: const [
                'PENDING',
                'CONFIRMED',
                'PREPARING',
                'READY_FOR_PICKUP',
                'PICKED_UP',
                'ON_THE_WAY',
                'DELIVERED',
                'CANCELLED',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (value) => status = value ?? status,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await widget.orderRepository.updateOrderStatus(
        orderId: order.id,
        status: status,
        notes: noteController.text.trim().isEmpty
            ? null
            : noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật trạng thái')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý đơn hàng')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              children: statusFilters
                  .map(
                    (s) => ChoiceChip(
                      selected: _status == s,
                      label: Text(s ?? 'Tất cả'),
                      onSelected: (_) {
                        setState(() => _status = s);
                        _load();
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Column(
                children: [
                  Text(_error!),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: _load, child: const Text('Thử lại')),
                ],
              )
            else if (_orders.isEmpty)
              const Text('Không có đơn hàng')
            else
              ..._orders.map(
                (o) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(o.orderNumber),
                    subtitle: Text(
                      '${Formatters.orderStatusLabel(o.status)} • ${Formatters.date(o.createdAt)}',
                    ),
                    trailing: Text(Formatters.money(o.totalAmount)),
                    onTap: () => context.push('/orders/${o.id}'),
                    onLongPress: () => _updateStatus(o),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
