class CartItem {
  CartItem({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.menuItemImageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.specialInstructions,
  });

  final int id;
  final int menuItemId;
  final String menuItemName;
  final String? menuItemImageUrl;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? specialInstructions;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      menuItemId: (json['menuItemId'] as num?)?.toInt() ?? 0,
      menuItemName: (json['menuItemName'] ?? '').toString(),
      menuItemImageUrl: json['menuItemImageUrl']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      specialInstructions: json['specialInstructions']?.toString(),
    );
  }
}
