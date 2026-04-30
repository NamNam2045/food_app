import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../review/data/review_repository.dart';
import '../../data/models/order_models.dart';
import '../../data/order_repository.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({
    super.key,
    required this.orderRepository,
    required this.reviewRepository,
  });

  final OrderRepository orderRepository;
  final ReviewRepository reviewRepository;

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  bool _loading = true;
  String? _error;
  String? _status;
  List<OrderSummaryModel> _orders = const [];

  static const statusFilters = <String?>[
    null,
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
      final data = await widget.orderRepository.getMyOrders(status: _status);
      if (!mounted) return;
      setState(() {
        _orders = data;
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

  Future<void> _openReviewDialog(OrderSummaryModel order) async {
    int rating = 5;
    final controller = TextEditingController();
    final submitted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đánh giá đơn hàng'),
        content: StatefulBuilder(
          builder: (context, setInner) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: rating,
                  items: const [1, 2, 3, 4, 5]
                      .map(
                        (e) =>
                            DropdownMenuItem(value: e, child: Text('$e sao')),
                      )
                      .toList(),
                  onChanged: (value) =>
                      setInner(() => rating = value ?? rating),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Nhận xét của bạn',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
    if (submitted != true) return;
    try {
      await widget.reviewRepository.createReview(
        orderId: order.id,
        rating: rating,
        comment: controller.text.trim().isEmpty ? null : controller.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cảm ơn bạn đã đánh giá!')));
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
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              children: statusFilters.map((value) {
                final label = value == null
                    ? 'Tất cả'
                    : Formatters.orderStatusLabel(value);
                return ChoiceChip(
                  label: Text(label),
                  selected: _status == value,
                  onSelected: (_) {
                    setState(() => _status = value);
                    _load();
                  },
                );
              }).toList(),
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
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Chưa có đơn hàng nào')),
              )
            else
              ..._orders.map((o) {
                final status = Formatters.orderStatusLabel(o.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.restaurantName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('${o.orderNumber} • $status'),
                        Text(
                          '${Formatters.date(o.createdAt)} • ${o.itemCount} món',
                        ),
                        Text(Formatters.money(o.totalAmount)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.push('/orders/${o.id}'),
                              child: const Text('Chi tiết'),
                            ),
                            if (o.status == 'ON_THE_WAY' ||
                                o.status == 'PICKED_UP')
                              FilledButton.tonal(
                                onPressed: () =>
                                    context.push('/orders/${o.id}/tracking'),
                                child: const Text('Theo dõi'),
                              ),
                            if (o.status == 'DELIVERED')
                              FilledButton.tonal(
                                onPressed: () => _openReviewDialog(o),
                                child: const Text('Đánh giá'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
