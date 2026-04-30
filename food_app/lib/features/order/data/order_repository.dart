import '../../../core/network/api_client.dart';
import 'models/order_models.dart';

class OrderRepository {
  OrderRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<OrderSummaryModel>> getMyOrders({
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    final data = await _apiClient.get(
      '/orders',
      query: {'status': status, 'page': page, 'size': size}
        ..removeWhere((_, value) => value == null),
    );
    final content = (data as Map<String, dynamic>)['content'] as List?;
    return content
            ?.whereType<Map<String, dynamic>>()
            .map(OrderSummaryModel.fromJson)
            .toList(growable: false) ??
        const <OrderSummaryModel>[];
  }

  Future<OrderDetailModel> getOrderDetail(int orderId) async {
    final data = await _apiClient.get('/orders/$orderId');
    return OrderDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<OrderDetailModel> placeOrder({
    required int deliveryAddressId,
    required String paymentMethod,
    String? specialInstructions,
    String? promoCode,
  }) async {
    final data = await _apiClient.post(
      '/orders',
      body:
          {
            'deliveryAddressId': deliveryAddressId,
            'paymentMethod': paymentMethod,
            'specialInstructions': specialInstructions,
            'promoCode': promoCode,
          }..removeWhere(
            (_, value) => value == null || (value is String && value.isEmpty),
          ),
    );
    return OrderDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<OrderDetailModel> cancelOrder(int orderId, {String? reason}) async {
    final data = await _apiClient.patch(
      '/orders/$orderId/cancel',
      body: {'reason': reason},
    );
    return OrderDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<OrderDetailModel> updateOrderStatus({
    required int orderId,
    required String status,
    String? notes,
  }) async {
    final data = await _apiClient.put(
      '/orders/$orderId/status',
      body: {'status': status, 'notes': notes}
        ..removeWhere((_, value) => value == null || value.toString().isEmpty),
    );
    return OrderDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<OrderSummaryModel>> getRestaurantOrders({
    required int restaurantId,
    String? status,
    String? date,
    int page = 0,
    int size = 20,
  }) async {
    final data = await _apiClient.get(
      '/restaurants/$restaurantId/orders',
      query: {'status': status, 'date': date, 'page': page, 'size': size}
        ..removeWhere((_, value) => value == null || value.toString().isEmpty),
    );
    final content = (data as Map<String, dynamic>)['content'] as List?;
    return content
            ?.whereType<Map<String, dynamic>>()
            .map(OrderSummaryModel.fromJson)
            .toList(growable: false) ??
        const <OrderSummaryModel>[];
  }

  Future<PaymentInfoModel> getPaymentByOrder(int orderId) async {
    final data = await _apiClient.get('/payments/orders/$orderId');
    return PaymentInfoModel.fromJson(data as Map<String, dynamic>);
  }
}
