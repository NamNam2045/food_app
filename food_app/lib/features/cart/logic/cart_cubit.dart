import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/cart_repository.dart';
import '../data/models/cart.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit({required CartRepository repository})
    : _repository = repository,
      super(const CartState());

  final CartRepository _repository;

  Future<void> loadCart() async {
    emit(
      state.copyWith(
        status: CartStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final cart = await _repository.fetchCart();
      emit(
        state.copyWith(status: CartStatus.loaded, cart: cart, clearError: true),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(status: CartStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          status: CartStatus.failure,
          errorMessage: 'Không thể tải giỏ hàng',
        ),
      );
    }
  }

  Future<void> addItem({required int menuItemId, int quantity = 1}) async {
    emit(
      state.copyWith(isUpdating: true, clearError: true, clearSuccess: true),
    );
    try {
      final cart = await _repository.addItem(
        menuItemId: menuItemId,
        quantity: quantity,
      );
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          isUpdating: false,
          successMessage: 'Đã thêm món vào giỏ',
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: 'Không thể thêm món vào giỏ',
        ),
      );
    }
  }

  Future<void> increaseQty(int cartItemId, int currentQty) async {
    await _updateQty(cartItemId, currentQty + 1);
  }

  Future<void> decreaseQty(int cartItemId, int currentQty) async {
    if (currentQty <= 1) {
      await removeItem(cartItemId);
      return;
    }
    await _updateQty(cartItemId, currentQty - 1);
  }

  Future<void> removeItem(int cartItemId) async {
    emit(
      state.copyWith(isUpdating: true, clearError: true, clearSuccess: true),
    );
    try {
      await _repository.removeItem(cartItemId);
      final cart = await _repository.fetchCart();
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          isUpdating: false,
          successMessage: 'Đã xóa món khỏi giỏ',
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(isUpdating: false, errorMessage: 'Không thể xóa món'),
      );
    }
  }

  Future<void> clearCart() async {
    emit(
      state.copyWith(isUpdating: true, clearError: true, clearSuccess: true),
    );
    try {
      await _repository.clearCart();
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: CartModel.empty(),
          isUpdating: false,
          successMessage: 'Đã xóa toàn bộ giỏ hàng',
        ),
      );
      await loadCart();
    } on ApiException catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: 'Không thể xóa giỏ hàng',
        ),
      );
    }
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  Future<void> _updateQty(int cartItemId, int nextQty) async {
    emit(
      state.copyWith(isUpdating: true, clearError: true, clearSuccess: true),
    );
    try {
      final cart = await _repository.updateItem(
        cartItemId: cartItemId,
        quantity: nextQty,
      );
      emit(
        state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          isUpdating: false,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: 'Không thể cập nhật số lượng',
        ),
      );
    }
  }
}
