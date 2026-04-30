class OrderSummaryModel {
  OrderSummaryModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.restaurantName,
    required this.restaurantLogoUrl,
    required this.itemCount,
    required this.totalAmount,
    required this.createdAt,
  });

  final int id;
  final String orderNumber;
  final String status;
  final String restaurantName;
  final String? restaurantLogoUrl;
  final int itemCount;
  final double totalAmount;
  final DateTime? createdAt;

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNumber: (json['orderNumber'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      restaurantName: (json['restaurantName'] ?? '').toString(),
      restaurantLogoUrl: json['restaurantLogoUrl']?.toString(),
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}

class OrderItemModel {
  OrderItemModel({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.specialInstructions,
  });

  final int id;
  final int menuItemId;
  final String menuItemName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? specialInstructions;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      menuItemId: (json['menuItemId'] as num?)?.toInt() ?? 0,
      menuItemName: (json['menuItemName'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      specialInstructions: json['specialInstructions']?.toString(),
    );
  }
}

class OrderStatusHistoryModel {
  OrderStatusHistoryModel({
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  final String status;
  final String? notes;
  final DateTime? createdAt;

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      status: (json['status'] ?? '').toString(),
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}

class OrderDetailModel {
  OrderDetailModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantPhone,
    required this.deliveryAddressSnapshot,
    required this.items,
    required this.statusHistory,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.specialInstructions,
    required this.estimatedDeliveryAt,
    required this.deliveredAt,
    required this.cancelledAt,
    required this.cancellationReason,
    required this.createdAt,
  });

  final int id;
  final String orderNumber;
  final String status;
  final int? restaurantId;
  final String restaurantName;
  final String? restaurantPhone;
  final String? deliveryAddressSnapshot;
  final List<OrderItemModel> items;
  final List<OrderStatusHistoryModel> statusHistory;
  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double totalAmount;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? specialInstructions;
  final DateTime? estimatedDeliveryAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final DateTime? createdAt;

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNumber: (json['orderNumber'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      restaurantId: (json['restaurantId'] as num?)?.toInt(),
      restaurantName: (json['restaurantName'] ?? '').toString(),
      restaurantPhone: json['restaurantPhone']?.toString(),
      deliveryAddressSnapshot: json['deliveryAddressSnapshot']?.toString(),
      items:
          (json['items'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(OrderItemModel.fromJson)
              .toList(growable: false) ??
          const <OrderItemModel>[],
      statusHistory:
          (json['statusHistory'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(OrderStatusHistoryModel.fromJson)
              .toList(growable: false) ??
          const <OrderStatusHistoryModel>[],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['paymentMethod']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      specialInstructions: json['specialInstructions']?.toString(),
      estimatedDeliveryAt: DateTime.tryParse(
        (json['estimatedDeliveryAt'] ?? '').toString(),
      ),
      deliveredAt: DateTime.tryParse((json['deliveredAt'] ?? '').toString()),
      cancelledAt: DateTime.tryParse((json['cancelledAt'] ?? '').toString()),
      cancellationReason: json['cancellationReason']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}

class PaymentInfoModel {
  PaymentInfoModel({
    required this.id,
    required this.orderId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.amount,
    required this.transactionId,
    required this.paidAt,
    required this.createdAt,
  });

  final int id;
  final int orderId;
  final String paymentMethod;
  final String paymentStatus;
  final double amount;
  final String? transactionId;
  final DateTime? paidAt;
  final DateTime? createdAt;

  factory PaymentInfoModel.fromJson(Map<String, dynamic> json) {
    return PaymentInfoModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      paymentMethod: (json['paymentMethod'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      transactionId: json['transactionId']?.toString(),
      paidAt: DateTime.tryParse((json['paidAt'] ?? '').toString()),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
