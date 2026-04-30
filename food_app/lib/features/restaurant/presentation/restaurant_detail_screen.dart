import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../data/models/menu_item.dart';
import '../logic/restaurant_detail_cubit.dart';
import '../logic/restaurant_detail_state.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );

    return BlocConsumer<RestaurantDetailCubit, RestaurantDetailState>(
      listenWhen: (p, c) =>
          p.errorMessage != c.errorMessage ||
          p.successMessage != c.successMessage,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          messenger
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          context.read<RestaurantDetailCubit>().clearMessages();
        } else if (state.successMessage != null &&
            state.successMessage!.isNotEmpty) {
          messenger
            ..clearSnackBars()
            ..showSnackBar(SnackBar(content: Text(state.successMessage!)));
          context.read<RestaurantDetailCubit>().clearMessages();
        }
      },
      builder: (context, state) {
        if (state.status == RestaurantDetailStatus.loading ||
            state.status == RestaurantDetailStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == RestaurantDetailStatus.failure ||
            state.restaurant == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Chi tiết nhà hàng')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Không thể tải dữ liệu'),
                    const SizedBox(height: 10),
                    FilledButton(
                      onPressed: () =>
                          context.read<RestaurantDetailCubit>().load(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final restaurant = state.restaurant!;

        return Scaffold(
          appBar: AppBar(
            title: Text(restaurant.name),
            actions: [
              IconButton(
                onPressed: () => context.push('/cart'),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => context.read<RestaurantDetailCubit>().load(),
            child: ListView(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child:
                      restaurant.bannerUrl != null &&
                          restaurant.bannerUrl!.isNotEmpty
                      ? Image.network(
                          restaurant.bannerUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _bannerFallback(),
                        )
                      : _bannerFallback(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurant.name,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${restaurant.cuisineType} • ⭐ ${restaurant.ratingAvg.toStringAsFixed(1)} (${restaurant.ratingCount})',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${restaurant.estimatedDeliveryMinutes} phút • Phí ship ${currency.format(restaurant.deliveryFee)} • ${restaurant.isOpen ? 'Đang mở cửa' : 'Đã đóng cửa'}',
                      ),
                      if (restaurant.description != null &&
                          restaurant.description!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(restaurant.description!),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 24),
                for (final category in state.menu) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (category.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Chưa có món trong danh mục này'),
                    )
                  else
                    ...category.items.map(
                      (item) => _MenuItemTile(
                        item: item,
                        currency: currency,
                        onTap: () => context.push(
                          '/restaurants/${restaurant.id}/items/${item.id}',
                        ),
                        onAdd: state.isAddingToCart
                            ? null
                            : () => context
                                  .read<RestaurantDetailCubit>()
                                  .addItemToCart(item.id),
                      ),
                    ),
                  const SizedBox(height: 6),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bannerFallback() {
    return Container(
      color: Colors.orange.shade100,
      child: const Icon(Icons.storefront, size: 56, color: Colors.deepOrange),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.item,
    required this.currency,
    required this.onTap,
    required this.onAdd,
  });

  final MenuItemModel item;
  final NumberFormat currency;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 56,
          height: 56,
          child: item.imageUrl != null && item.imageUrl!.isNotEmpty
              ? Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _fallbackThumb(),
                )
              : _fallbackThumb(),
        ),
      ),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
      subtitle: Text(currency.format(item.price)),
      trailing: FilledButton.tonalIcon(
        onPressed: item.isAvailable ? onAdd : null,
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
    );
  }

  Widget _fallbackThumb() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.fastfood, color: Colors.grey),
    );
  }
}
