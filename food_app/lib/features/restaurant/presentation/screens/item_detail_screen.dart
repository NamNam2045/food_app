import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/data/cart_repository.dart';
import '../../../discover/data/restaurant_repository.dart';
import '../../data/models/menu_item.dart';
import '../../../../core/utils/formatters.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({
    super.key,
    required this.restaurantId,
    required this.itemId,
    required this.restaurantRepository,
    required this.cartRepository,
  });

  final int restaurantId;
  final int itemId;
  final RestaurantRepository restaurantRepository;
  final CartRepository cartRepository;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final _noteController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  MenuItemModel? _item;
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final item = await widget.restaurantRepository.fetchMenuItem(
        restaurantId: widget.restaurantId,
        itemId: widget.itemId,
      );
      if (!mounted) return;
      setState(() {
        _item = item;
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

  Future<void> _addToCart() async {
    if (_item == null) return;
    setState(() => _submitting = true);
    try {
      await widget.cartRepository.addItem(
        menuItemId: _item!.id,
        quantity: _qty,
        specialInstructions: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã thêm vào giỏ hàng')));
      context.push('/cart');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _item == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết món')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Không tải được dữ liệu'),
              const SizedBox(height: 8),
              FilledButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    final item = _item!;
    final total = item.price * _qty;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết món')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 16 / 10,
            child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                ? Image.network(
                    item.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(),
                  )
                : _fallback(),
          ),
          const SizedBox(height: 12),
          Text(
            item.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(Formatters.money(item.price)),
          if (item.preparationTimeMinutes != null || item.calories != null) ...[
            const SizedBox(height: 6),
            Text(
              '🕐 ~${item.preparationTimeMinutes ?? '--'} phút   🔥${item.calories ?? '--'} kcal',
            ),
          ],
          if ((item.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(item.description!),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Ghi chú đặc biệt',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              IconButton(
                onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('$_qty', style: const TextStyle(fontSize: 18)),
              IconButton(
                onPressed: () => setState(() => _qty++),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: _submitting ? null : _addToCart,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Thêm vào giỏ ${Formatters.money(total)}'),
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.fastfood, size: 52, color: Colors.grey),
    );
  }
}
