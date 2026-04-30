import '../../../core/network/api_client.dart';
import '../../restaurant/data/models/menu_category.dart';
import '../../restaurant/data/models/menu_item.dart';
import '../../restaurant/data/models/restaurant_detail.dart';
import 'models/restaurant_summary.dart';

class RestaurantRepository {
  RestaurantRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<RestaurantSummary>> fetchRestaurants({
    String? search,
    String? city,
    String? cuisineType,
    bool? isOpen,
    int page = 0,
    int size = 20,
    String sortBy = 'rating',
  }) async {
    final data = await _apiClient.get(
      '/restaurants',
      query: {
        'search': search,
        'city': city,
        'cuisineType': cuisineType,
        'isOpen': isOpen,
        'page': page,
        'size': size,
        'sortBy': sortBy,
      }..removeWhere((_, value) => value == null),
    );

    final content = (data as Map<String, dynamic>)['content'] as List?;
    return content
            ?.whereType<Map<String, dynamic>>()
            .map(RestaurantSummary.fromJson)
            .toList(growable: false) ??
        const <RestaurantSummary>[];
  }

  Future<RestaurantDetail> fetchRestaurantDetail(String idOrSlug) async {
    final data = await _apiClient.get('/restaurants/$idOrSlug');
    return RestaurantDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<List<MenuCategory>> fetchMenu(int restaurantId) async {
    final data = await _apiClient.get('/restaurants/$restaurantId/menu');
    final items = data as List?;
    return items
            ?.whereType<Map<String, dynamic>>()
            .map(MenuCategory.fromJson)
            .toList(growable: false) ??
        const <MenuCategory>[];
  }

  Future<MenuItemModel> fetchMenuItem({
    required int restaurantId,
    required int itemId,
  }) async {
    final data = await _apiClient.get(
      '/restaurants/$restaurantId/menu/items/$itemId',
    );
    return MenuItemModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MenuCategory> createCategory({
    required int restaurantId,
    required String name,
    String? description,
    int? displayOrder,
  }) async {
    final data = await _apiClient.post(
      '/restaurants/$restaurantId/menu/categories',
      body:
          {
            'name': name,
            'description': description,
            'displayOrder': displayOrder,
          }..removeWhere(
            (_, value) => value == null || (value is String && value.isEmpty),
          ),
    );
    return MenuCategory.fromJson(data as Map<String, dynamic>);
  }

  Future<MenuItemModel> createMenuItem({
    required int restaurantId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    String? imageUrl,
    bool available = true,
    bool featured = false,
    int? calories,
    int? preparationTimeMinutes,
    int? displayOrder,
  }) async {
    final data = await _apiClient.post(
      '/restaurants/$restaurantId/menu/items',
      body:
          {
            'categoryId': categoryId,
            'name': name,
            'description': description,
            'price': price,
            'imageUrl': imageUrl,
            'available': available,
            'featured': featured,
            'calories': calories,
            'preparationTimeMinutes': preparationTimeMinutes,
            'displayOrder': displayOrder,
          }..removeWhere(
            (_, value) => value == null || (value is String && value.isEmpty),
          ),
    );
    return MenuItemModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MenuItemModel> updateMenuItem({
    required int restaurantId,
    required int itemId,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    bool? available,
    bool? featured,
    int? calories,
    int? preparationTimeMinutes,
    int? displayOrder,
  }) async {
    final data = await _apiClient.put(
      '/restaurants/$restaurantId/menu/items/$itemId',
      body:
          {
            'categoryId': categoryId,
            'name': name,
            'description': description,
            'price': price,
            'imageUrl': imageUrl,
            'available': available,
            'featured': featured,
            'calories': calories,
            'preparationTimeMinutes': preparationTimeMinutes,
            'displayOrder': displayOrder,
          }..removeWhere(
            (_, value) => value == null || (value is String && value.isEmpty),
          ),
    );
    return MenuItemModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteMenuItem({
    required int restaurantId,
    required int itemId,
  }) async {
    await _apiClient.delete('/restaurants/$restaurantId/menu/items/$itemId');
  }

  Future<void> deleteCategory({
    required int restaurantId,
    required int categoryId,
  }) async {
    await _apiClient.delete(
      '/restaurants/$restaurantId/menu/categories/$categoryId',
    );
  }
}
