import '../../../core/network/api_client.dart';
import 'models/cart.dart';

class CartRepository {
  CartRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<CartModel> fetchCart() async {
    final data = await _apiClient.get('/cart');
    if (data == null) {
      return CartModel.empty();
    }
    return CartModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CartModel> addItem({
    required int menuItemId,
    int quantity = 1,
    String? specialInstructions,
  }) async {
    final data = await _apiClient.post(
      '/cart/items',
      body: {
        'menuItemId': menuItemId,
        'quantity': quantity,
        'specialInstructions': specialInstructions,
      }..removeWhere((_, value) => value == null),
    );
    return CartModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CartModel> updateItem({
    required int cartItemId,
    required int quantity,
  }) async {
    final data = await _apiClient.put(
      '/cart/items/$cartItemId',
      body: {'quantity': quantity},
    );
    return CartModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> removeItem(int cartItemId) {
    return _apiClient.delete('/cart/items/$cartItemId');
  }

  Future<void> clearCart() {
    return _apiClient.delete('/cart');
  }
}
