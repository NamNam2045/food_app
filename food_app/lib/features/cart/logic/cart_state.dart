import 'package:equatable/equatable.dart';

import '../data/models/cart.dart';

enum CartStatus { initial, loading, loaded, failure }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.errorMessage,
    this.successMessage,
    this.isUpdating = false,
  });

  final CartStatus status;
  final CartModel? cart;
  final String? errorMessage;
  final String? successMessage;
  final bool isUpdating;

  CartState copyWith({
    CartStatus? status,
    CartModel? cart,
    String? errorMessage,
    String? successMessage,
    bool? isUpdating,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [
    status,
    cart,
    errorMessage,
    successMessage,
    isUpdating,
  ];
}
