import 'menu_item.dart';

class MenuCategory {
  MenuCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.items,
  });

  final int id;
  final String name;
  final String? description;
  final List<MenuItemModel> items;

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(MenuItemModel.fromJson)
            .toList(growable: false) ??
        const <MenuItemModel>[];

    return MenuCategory(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      items: items,
    );
  }
}
