import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/formatters.dart';
import '../../../order/data/models/order_models.dart';
import '../../../order/data/order_repository.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.orderRepository});

  final OrderRepository orderRepository;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;
  String? _error;
  List<_NotificationItem> _items = const [];

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
      final summaries = await widget.orderRepository.getMyOrders(size: 12);
      final details = await Future.wait(
        summaries.map((order) async {
          try {
            return await widget.orderRepository.getOrderDetail(order.id);
          } catch (_) {
            return null;
          }
        }),
      );

      final items = <_NotificationItem>[];

      for (final detail in details.whereType<OrderDetailModel>()) {
        if (detail.statusHistory.isEmpty) {
          items.add(
            _NotificationItem(
              orderId: detail.id,
              orderNumber: detail.orderNumber,
              restaurantName: detail.restaurantName,
              status: detail.status,
              note: null,
              createdAt: detail.createdAt,
            ),
          );
          continue;
        }

        for (final history in detail.statusHistory) {
          items.add(
            _NotificationItem(
              orderId: detail.id,
              orderNumber: detail.orderNumber,
              restaurantName: detail.restaurantName,
              status: history.status,
              note: history.notes,
              createdAt: history.createdAt ?? detail.createdAt,
            ),
          );
        }
      }

      items.sort((a, b) {
        final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      if (!mounted) {
        return;
      }
      setState(() {
        _items = items.take(30).toList(growable: false);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'CONFIRMED':
      case 'PREPARING':
      case 'READY_FOR_PICKUP':
        return Icons.restaurant;
      case 'PICKED_UP':
      case 'ON_THE_WAY':
        return Icons.delivery_dining;
      case 'DELIVERED':
        return Icons.check_circle;
      case 'CANCELLED':
        return Icons.cancel;
      default:
        return Icons.notifications_none;
    }
  }

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'DELIVERED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      case 'ON_THE_WAY':
      case 'PICKED_UP':
        return Colors.blue;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _relativeTime(DateTime? value) {
    if (value == null) {
      return '--';
    }
    final diff = DateTime.now().difference(value.toLocal());
    if (diff.inSeconds < 60) {
      return 'Vừa xong';
    }
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} giờ';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ngày';
    }
    return Formatters.dateTime(value);
  }

  void _openNotification(_NotificationItem item) {
    final canTrack =
        item.status == 'READY_FOR_PICKUP' ||
        item.status == 'PICKED_UP' ||
        item.status == 'ON_THE_WAY';
    if (canTrack) {
      context.push('/orders/${item.orderId}/tracking');
      return;
    }
    context.push('/orders/${item.orderId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView.separated(
          itemCount: _loading || _error != null || _items.isEmpty
              ? 1
              : _items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, index) {
            if (_loading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (_error != null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text(_error!),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _load,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (_items.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Chưa có thông báo nào từ đơn hàng của bạn'),
                ),
              );
            }

            final item = _items[index];
            final color = _statusColor(context, item.status);
            final title = 'Đơn ${item.orderNumber}';
            final statusLabel = Formatters.orderStatusLabel(item.status);
            final note = (item.note ?? '').trim();
            final subtitle = note.isEmpty
                ? '$statusLabel • ${item.restaurantName}'
                : '$statusLabel • $note';

            return ListTile(
              onTap: () => _openNotification(item),
              leading: Icon(_statusIcon(item.status), color: color),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: Text(_relativeTime(item.createdAt)),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.orderId,
    required this.orderNumber,
    required this.restaurantName,
    required this.status,
    required this.note,
    required this.createdAt,
  });

  final int orderId;
  final String orderNumber;
  final String restaurantName;
  final String status;
  final String? note;
  final DateTime? createdAt;
}
