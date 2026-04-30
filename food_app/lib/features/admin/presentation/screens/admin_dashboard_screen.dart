import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../discover/data/models/restaurant_summary.dart';
import '../../../discover/data/restaurant_repository.dart';
import '../../../order/data/models/order_models.dart';
import '../../../order/data/order_repository.dart';
import '../../../../core/utils/formatters.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.restaurantRepository,
    required this.orderRepository,
  });

  final RestaurantRepository restaurantRepository;
  final OrderRepository orderRepository;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _loading = true;
  String? _error;
  List<RestaurantSummary> _restaurants = const [];
  RestaurantSummary? _selectedRestaurant;
  List<OrderSummaryModel> _orders = const [];

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
      final restaurants = await widget.restaurantRepository.fetchRestaurants(
        size: 50,
      );
      RestaurantSummary? selected = _selectedRestaurant;
      if (selected == null && restaurants.isNotEmpty) {
        selected = restaurants.first;
      }

      List<OrderSummaryModel> orders = const [];
      if (selected != null) {
        orders = await widget.orderRepository.getRestaurantOrders(
          restaurantId: selected.id,
          size: 20,
        );
      }

      if (!mounted) return;
      setState(() {
        _restaurants = restaurants;
        _selectedRestaurant = selected;
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

  Future<void> _changeRestaurant(RestaurantSummary? restaurant) async {
    if (restaurant == null) return;
    setState(() {
      _selectedRestaurant = restaurant;
      _loading = true;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
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

    final pendingCount = _orders.where((e) => e.status == 'PENDING').length;
    final todayRevenue = _orders.fold<double>(
      0,
      (sum, e) => sum + e.totalAmount,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<RestaurantSummary>(
              initialValue: _selectedRestaurant,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Nhà hàng quản lý',
                border: OutlineInputBorder(),
              ),
              items: _restaurants
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: _changeRestaurant,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _metric('Tổng đơn', '${_orders.length}')),
                const SizedBox(width: 10),
                Expanded(child: _metric('Đơn chờ', '$pendingCount')),
              ],
            ),
            const SizedBox(height: 10),
            _metric(
              'Doanh thu (theo danh sách hiện có)',
              Formatters.money(todayRevenue),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _selectedRestaurant == null
                      ? null
                      : () => context.push(
                          '/admin/menu?restaurantId=${_selectedRestaurant!.id}',
                        ),
                  child: const Text('Quản lý menu'),
                ),
                OutlinedButton(
                  onPressed: _selectedRestaurant == null
                      ? null
                      : () => context.push(
                          '/admin/orders?restaurantId=${_selectedRestaurant!.id}',
                        ),
                  child: const Text('Quản lý đơn'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Đơn gần đây',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_orders.isEmpty)
              const Text('Chưa có đơn hàng nào')
            else
              ..._orders
                  .take(8)
                  .map(
                    (o) => Card(
                      child: ListTile(
                        title: Text(o.orderNumber),
                        subtitle: Text(Formatters.orderStatusLabel(o.status)),
                        trailing: Text(Formatters.money(o.totalAmount)),
                        onTap: () => context.push('/orders/${o.id}'),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _metric(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
