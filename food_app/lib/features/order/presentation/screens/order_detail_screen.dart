import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/models/order_models.dart';
import '../../data/order_repository.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.orderRepository,
  });

  final int orderId;
  final OrderRepository orderRepository;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _loading = true;
  String? _error;
  OrderDetailModel? _order;
  PaymentInfoModel? _payment;

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
      final order = await widget.orderRepository.getOrderDetail(widget.orderId);
      PaymentInfoModel? payment;
      try {
        payment = await widget.orderRepository.getPaymentByOrder(
          widget.orderId,
        );
      } catch (_) {
        payment = null;
      }

      if (!mounted) return;
      setState(() {
        _order = order;
        _payment = payment;
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

  Future<void> _cancelOrder() async {
    final reasonController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: TextField(
          controller: reasonController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Lý do hủy (tuỳ chọn)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await widget.orderRepository.cancelOrder(
        widget.orderId,
        reason: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã hủy đơn hàng')));
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
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết đơn hàng')),
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
    final addressMap = Formatters.parseAddressSnapshot(
      order.deliveryAddressSnapshot,
    );
    final canCancel = order.status == 'PENDING' || order.status == 'CONFIRMED';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        actions: [
          if (canCancel)
            TextButton(onPressed: _cancelOrder, child: const Text('Hủy đơn')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              order.orderNumber,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(Formatters.orderStatusLabel(order.status)),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    if ((order.restaurantPhone ?? '').isNotEmpty)
                      Text('☎ ${order.restaurantPhone}'),
                    if (addressMap != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '📍 ${(addressMap['streetLine1'] ?? '')} ${(addressMap['city'] ?? '')}',
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text('Đặt lúc: ${Formatters.dateTime(order.createdAt)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Món đã đặt',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...order.items.map(
              (i) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(i.menuItemName),
                subtitle: Text(
                  'SL ${i.quantity} • ${Formatters.money(i.unitPrice)}',
                ),
                trailing: Text(Formatters.money(i.subtotal)),
              ),
            ),
            const Divider(),
            _row('Tạm tính', Formatters.money(order.subtotal)),
            _row('Phí giao hàng', Formatters.money(order.deliveryFee)),
            _row('Giảm giá', Formatters.money(order.discountAmount)),
            _row('Tổng cộng', Formatters.money(order.totalAmount), bold: true),
            const SizedBox(height: 10),
            if (_payment != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thanh toán',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Phương thức: ${Formatters.paymentMethodLabel(_payment!.paymentMethod)}',
                      ),
                      Text('Trạng thái: ${_payment!.paymentStatus}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 10),
            const Text(
              'Lịch sử trạng thái',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...order.statusHistory.map(
              (h) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(Formatters.orderStatusLabel(h.status)),
                subtitle: Text(
                  '${Formatters.dateTime(h.createdAt)}${h.notes != null ? ' • ${h.notes}' : ''}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Row(
      children: [
        Expanded(child: Text(k, style: style)),
        Text(v, style: style),
      ],
    );
  }
}
