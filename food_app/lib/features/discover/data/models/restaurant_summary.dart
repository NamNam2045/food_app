import '../../../../core/constants/app_constants.dart';

class RestaurantSummary {
  RestaurantSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.cuisineType,
    required this.logoUrl,
    required this.bannerUrl,
    required this.ratingAvg,
    required this.ratingCount,
    required this.deliveryFee,
    required this.estimatedDeliveryMinutes,
    required this.isOpen,
    required this.city,
  });

  final int id;
  final String name;
  final String slug;
  final String cuisineType;
  final String? logoUrl;
  final String? bannerUrl;
  final double ratingAvg;
  final int ratingCount;
  final double deliveryFee;
  final int estimatedDeliveryMinutes;
  final bool isOpen;
  final String city;

  factory RestaurantSummary.fromJson(Map<String, dynamic> json) {
    return RestaurantSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      cuisineType: (json['cuisineType'] ?? '').toString(),
      logoUrl: AppConstants.resolveMediaUrl(json['logoUrl']?.toString()),
      bannerUrl: AppConstants.resolveMediaUrl(json['bannerUrl']?.toString()),
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      estimatedDeliveryMinutes:
          (json['estimatedDeliveryMinutes'] as num?)?.toInt() ?? 0,
      isOpen: json['open'] == true || json['isOpen'] == true,
      city: (json['city'] ?? '').toString(),
    );
  }
}
