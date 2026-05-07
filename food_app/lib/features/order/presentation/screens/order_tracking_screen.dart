import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/token_storage.dart';
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
  final TokenStorage _tokenStorage = TokenStorage();

  bool _loading = true;
  String? _error;
  OrderDetailModel? _order;
  Timer? _timer;
  StompClient? _stompClient;
  bool _socketConnected = false;

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
    _connectRealtimeChannel();
    _timer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _load(silent: true),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stompClient?.deactivate();
    super.dispose();
  }

  Future<void> _connectRealtimeChannel() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      return;
    }

    late final StompClient client;
    client = StompClient(
      config: StompConfig.sockJS(
        url: AppConstants.webSocketUrl,
        reconnectDelay: const Duration(seconds: 5),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        onConnect: (_) {
          if (!mounted) {
            return;
          }
          setState(() => _socketConnected = true);
          client.subscribe(
            destination: '/user/queue/orders/${widget.orderId}/status',
            callback: (_) => _load(silent: true),
          );
        },
        onStompError: (_) {
          if (!mounted) {
            return;
          }
          setState(() => _socketConnected = false);
        },
        onWebSocketError: (_) {
          if (!mounted) {
            return;
          }
          setState(() => _socketConnected = false);
        },
        onWebSocketDone: () {
          if (!mounted) {
            return;
          }
          setState(() => _socketConnected = false);
        },
      ),
    );

    _stompClient = client;
    client.activate();
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
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  _socketConnected ? Icons.wifi_tethering : Icons.wifi_off,
                  size: 16,
                  color: _socketConnected ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 6),
                Text(
                  _socketConnected
                      ? 'Realtime: Đang kết nối'
                      : 'Realtime: Mất kết nối (đang dùng polling)',
                  style: TextStyle(
                    color: _socketConnected ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
              clipBehavior: Clip.antiAlias,
              child: Container(
                height: 190,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF1EB), Color(0xFFEAF4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${order.restaurantName} → Địa chỉ của bạn',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Icon(Icons.store_mall_directory_outlined),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Divider(thickness: 2),
                            ),
                          ),
                          Icon(Icons.delivery_dining),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Divider(thickness: 2),
                            ),
                          ),
                          Icon(Icons.home_outlined),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, size: 18),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Bản đồ realtime sẽ tích hợp sau. Hiện tại đang hiển thị tuyến giao ước tính.',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if ((order.restaurantPhone ?? '').isNotEmpty)
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Số nhà hàng: ${order.restaurantPhone}. Tính năng gọi trực tiếp sẽ tích hợp sau.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.phone),
                label: Text('Liên hệ nhà hàng: ${order.restaurantPhone}'),
              ),
          ],
        ),
      ),
    );
  }
}
