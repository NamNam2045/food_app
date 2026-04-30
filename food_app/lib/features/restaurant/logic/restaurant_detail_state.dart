import 'package:equatable/equatable.dart';

import '../../cart/data/models/cart.dart';
import '../data/models/menu_category.dart';
import '../data/models/restaurant_detail.dart';

enum RestaurantDetailStatus { initial, loading, loaded, failure }

class RestaurantDetailState extends Equatable {
  const RestaurantDetailState({
    this.status = RestaurantDetailStatus.initial,
    this.restaurant,
    this.menu = const <MenuCategory>[],
    this.errorMessage,
    this.isAddingToCart = false,
    this.addedCart,
    this.successMessage,
  });

  final RestaurantDetailStatus status;
  final RestaurantDetail? restaurant;
  final List<MenuCategory> menu;
  final String? errorMessage;
  final bool isAddingToCart;
  final CartModel? addedCart;
  final String? successMessage;

  RestaurantDetailState copyWith({
    RestaurantDetailStatus? status,
    RestaurantDetail? restaurant,
    List<MenuCategory>? menu,
    String? errorMessage,
    bool? isAddingToCart,
    CartModel? addedCart,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return RestaurantDetailState(
      status: status ?? this.status,
      restaurant: restaurant ?? this.restaurant,
      menu: menu ?? this.menu,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isAddingToCart: isAddingToCart ?? this.isAddingToCart,
      addedCart: addedCart ?? this.addedCart,
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    restaurant,
    menu,
    errorMessage,
    isAddingToCart,
    addedCart,
    successMessage,
  ];
}
