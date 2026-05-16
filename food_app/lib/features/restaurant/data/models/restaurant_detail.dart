import '../../../../core/constants/app_constants.dart';

class RestaurantDetail {
  RestaurantDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.cuisineType,
    required this.phone,
    required this.streetAddress,
    required this.city,
    required this.ratingAvg,
    required this.ratingCount,
    required this.deliveryFee,
    required this.estimatedDeliveryMinutes,
    required this.isOpen,
    required this.bannerUrl,
    required this.logoUrl,
  });

  final int id;
  final String name;
  final String? description;
  final String cuisineType;
  final String? phone;
  final String? streetAddress;
  final String city;
  final double ratingAvg;
  final int ratingCount;
  final double deliveryFee;
  final int estimatedDeliveryMinutes;
  final bool isOpen;
  final String? bannerUrl;
  final String? logoUrl;

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      cuisineType: (json['cuisineType'] ?? '').toString(),
      phone: json['phone']?.toString(),
      streetAddress: json['streetAddress']?.toString(),
      city: (json['city'] ?? '').toString(),
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0,
      estimatedDeliveryMinutes:
          (json['estimatedDeliveryMinutes'] as num?)?.toInt() ?? 0,
      isOpen: json['open'] == true || json['isOpen'] == true,
      bannerUrl: AppConstants.resolveMediaUrl(json['bannerUrl']?.toString()),
      logoUrl: AppConstants.resolveMediaUrl(json['logoUrl']?.toString()),
    );
  }
}
