import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = const [
      ('Đơn hàng #FR-20260402-00100', 'Đang được giao đến bạn', '11:30'),
      ('Khuyến mãi mới', 'Giảm 20% cho đơn hàng đầu tuần', 'Hôm nay'),
      ('Nhà hàng xác nhận', 'Phở Hà Nội đã xác nhận đơn của bạn', 'Hôm qua'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo')),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) {
          final n = notifications[index];
          return ListTile(
            leading: const Icon(Icons.notifications_none),
            title: Text(n.$1),
            subtitle: Text(n.$2),
            trailing: Text(n.$3),
          );
        },
      ),
    );
  }
}
