import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<_PaymentMethodItem> _items = <_PaymentMethodItem>[
    _PaymentMethodItem(
      icon: Icons.money,
      label: 'Tiền mặt (COD)',
      subtitle: 'Thanh toán khi nhận hàng',
      badge: 'Mặc định',
    ),
    _PaymentMethodItem(
      icon: Icons.account_balance_wallet_outlined,
      label: 'Ví MoMo',
      subtitle: 'Liên kết nhanh cho đơn hàng nhỏ',
    ),
    _PaymentMethodItem(
      icon: Icons.credit_card_outlined,
      label: 'Visa •••• 8891',
      subtitle: 'Hết hạn 09/28',
    ),
  ];

  int _selected = 0;

  void _addCard() {
    final cardNumberController = TextEditingController();
    final holderController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Thêm thẻ thanh toán',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số thẻ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: holderController,
                decoration: const InputDecoration(
                  labelText: 'Tên chủ thẻ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expiryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (!mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'UI đã sẵn sàng. Tích hợp lưu thẻ sẽ xử lý ở bước API.',
                        ),
                      ),
                    );
                  },
                  child: const Text('Lưu thẻ'),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      cardNumberController.dispose();
      holderController.dispose();
      expiryController.dispose();
      cvvController.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phương thức thanh toán')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Chọn phương thức mặc định',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final selected = _selected == index;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                onTap: () => setState(() => _selected = index),
                leading: Icon(item.icon),
                title: Text(item.label),
                subtitle: Text(item.subtitle),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : item.badge != null
                    ? Text(
                        item.badge!,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      )
                    : const Icon(Icons.radio_button_unchecked),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addCard,
            icon: const Icon(Icons.add),
            label: const Text('Thêm thẻ mới'),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodItem {
  const _PaymentMethodItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final String? badge;
}
