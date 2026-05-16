import '../../../../core/constants/app_constants.dart';

class MenuItemModel {
  MenuItemModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.calories,
    required this.preparationTimeMinutes,
  });

  final int id;
  final int categoryId;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final bool isAvailable;
  final int? calories;
  final int? preparationTimeMinutes;

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    final rawImage = json['imageUrl'] ?? json['image_url'] ?? json['image'];
    return MenuItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageUrl: AppConstants.resolveMediaUrl(rawImage?.toString()),
      isAvailable: json['available'] == true || json['isAvailable'] == true,
      calories: (json['calories'] as num?)?.toInt(),
      preparationTimeMinutes: (json['preparationTimeMinutes'] as num?)?.toInt(),
    );
  }
}
