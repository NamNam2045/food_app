import 'cart_item.dart';

class CartModel {
  CartModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  final int id;
  final int? restaurantId;
  final String? restaurantName;
  final List<CartItem> items;
  final int itemCount;
  final double subtotal;
  final double deliveryFee;
  final double total;

  bool get isEmpty => items.isEmpty;

  factory CartModel.empty() {
    return CartModel(
      id: 0,
      restaurantId: null,
      restaurantName: null,
      items: const <CartItem>[],
      itemCount: 0,
      subtotal: 0,
      deliveryFee: 0,
      total: 0,
    );
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(CartItem.fromJson)
            .toList(growable: false) ??
        const <CartItem>[];

    return CartModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      restaurantId: (json['restaurantId'] as num?)?.toInt(),
      restaurantName: json['restaurantName']?.toString(),
      items: items,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? items.length,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num?)?.toDouble() ?? 0,
    );
  }
}
