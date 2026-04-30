class ReviewModel {
  ReviewModel({
    required this.id,
    required this.orderId,
    required this.userFirstName,
    required this.userProfilePictureUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final int id;
  final int orderId;
  final String userFirstName;
  final String? userProfilePictureUrl;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      userFirstName: (json['userFirstName'] ?? '').toString(),
      userProfilePictureUrl: json['userProfilePictureUrl']?.toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment']?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}

class RestaurantReviewsModel {
  RestaurantReviewsModel({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });

  final double averageRating;
  final int totalReviews;
  final List<ReviewModel> reviews;

  factory RestaurantReviewsModel.fromJson(Map<String, dynamic> json) {
    return RestaurantReviewsModel(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      reviews:
          (json['reviews'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ReviewModel.fromJson)
              .toList(growable: false) ??
          const <ReviewModel>[],
    );
  }
}
