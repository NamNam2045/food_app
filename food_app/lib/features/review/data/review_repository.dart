import '../../../core/network/api_client.dart';
import 'models/review_models.dart';

class ReviewRepository {
  ReviewRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<void> createReview({
    required int orderId,
    required int rating,
    String? comment,
  }) async {
    await _apiClient.post(
      '/reviews',
      body: {'orderId': orderId, 'rating': rating, 'comment': comment}
        ..removeWhere(
          (_, value) => value == null || (value is String && value.isEmpty),
        ),
    );
  }

  Future<RestaurantReviewsModel> getRestaurantReviews(
    int restaurantId, {
    int page = 0,
    int size = 20,
  }) async {
    final data = await _apiClient.get(
      '/restaurants/$restaurantId/reviews',
      query: {'page': page, 'size': size},
    );
    return RestaurantReviewsModel.fromJson(data as Map<String, dynamic>);
  }
}
