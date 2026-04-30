import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../../cart/data/cart_repository.dart';
import '../../cart/data/models/cart.dart';
import '../../discover/data/restaurant_repository.dart';
import 'restaurant_detail_state.dart';

class RestaurantDetailCubit extends Cubit<RestaurantDetailState> {
  RestaurantDetailCubit({
    required RestaurantRepository restaurantRepository,
    required CartRepository cartRepository,
    required this.restaurantIdOrSlug,
  }) : _restaurantRepository = restaurantRepository,
       _cartRepository = cartRepository,
       super(const RestaurantDetailState());

  final RestaurantRepository _restaurantRepository;
  final CartRepository _cartRepository;
  final String restaurantIdOrSlug;

  Future<void> load() async {
    emit(
      state.copyWith(status: RestaurantDetailStatus.loading, clearError: true),
    );
    try {
      final detail = await _restaurantRepository.fetchRestaurantDetail(
        restaurantIdOrSlug,
      );
      final menu = await _restaurantRepository.fetchMenu(detail.id);
      emit(
        state.copyWith(
          status: RestaurantDetailStatus.loaded,
          restaurant: detail,
          menu: menu,
          clearError: true,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(
          status: RestaurantDetailStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: RestaurantDetailStatus.failure,
          errorMessage: 'Không thể tải chi tiết nhà hàng',
        ),
      );
    }
  }

  Future<void> addItemToCart(int menuItemId) async {
    emit(
      state.copyWith(
        isAddingToCart: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final CartModel cart = await _cartRepository.addItem(
        menuItemId: menuItemId,
        quantity: 1,
      );
      emit(
        state.copyWith(
          isAddingToCart: false,
          addedCart: cart,
          successMessage: 'Đã thêm món vào giỏ',
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isAddingToCart: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isAddingToCart: false,
          errorMessage: 'Không thể thêm vào giỏ',
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }
}
