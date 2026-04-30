import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../logic/cart_cubit.dart';
import '../logic/cart_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        actions: [
          TextButton(
            onPressed: () => context.read<CartCubit>().clearCart(),
            child: const Text('Xóa hết'),
          ),
        ],
      ),
      body: BlocConsumer<CartCubit, CartState>(
        listenWhen: (p, c) =>
            p.errorMessage != c.errorMessage ||
            p.successMessage != c.successMessage,
        listener: (context, state) {
          final messenger = ScaffoldMessenger.of(context);
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            messenger
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<CartCubit>().clearMessages();
          }
          if (state.successMessage != null &&
              state.successMessage!.isNotEmpty) {
            messenger
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(state.successMessage!)));
            context.read<CartCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (state.status == CartStatus.loading ||
              state.status == CartStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CartStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Không thể tải giỏ hàng'),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () => context.read<CartCubit>().loadCart(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          final cart = state.cart;
          if (cart == null || cart.isEmpty) {
            return const Center(
              child: Text('Giỏ hàng đang trống. Hãy thêm món để tiếp tục.'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    if (cart.restaurantName != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                        child: Text(
                          cart.restaurantName!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ...cart.items.map(
                      (item) => ListTile(
                        title: Text(item.menuItemName),
                        subtitle: Text(currency.format(item.subtotal)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: state.isUpdating
                                  ? null
                                  : () => context.read<CartCubit>().decreaseQty(
                                      item.id,
                                      item.quantity,
                                    ),
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text('${item.quantity}'),
                            IconButton(
                              onPressed: state.isUpdating
                                  ? null
                                  : () => context.read<CartCubit>().increaseQty(
                                      item.id,
                                      item.quantity,
                                    ),
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                            IconButton(
                              onPressed: state.isUpdating
                                  ? null
                                  : () => context.read<CartCubit>().removeItem(
                                      item.id,
                                    ),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      _summaryRow('Tạm tính', currency.format(cart.subtotal)),
                      _summaryRow(
                        'Phí giao hàng',
                        currency.format(cart.deliveryFee),
                      ),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Tổng cộng',
                        currency.format(cart.total),
                        bold: true,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.push('/checkout'),
                          child: const Text('Tiến hành đặt'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      fontSize: bold ? 16 : 14,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
