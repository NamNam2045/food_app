import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_exception.dart';
import '../data/restaurant_repository.dart';
import 'discover_state.dart';

class DiscoverCubit extends Cubit<DiscoverState> {
  DiscoverCubit({required RestaurantRepository repository})
    : _repository = repository,
      super(const DiscoverState());

  final RestaurantRepository _repository;

  Future<void> loadRestaurants({String? search}) async {
    emit(
      state.copyWith(
        status: DiscoverStatus.loading,
        searchText: search ?? state.searchText,
        clearError: true,
      ),
    );

    try {
      final data = await _repository.fetchRestaurants(
        search: search ?? state.searchText,
      );
      emit(
        state.copyWith(
          status: DiscoverStatus.success,
          restaurants: data,
          clearError: true,
        ),
      );
    } on ApiException catch (e) {
      emit(
        state.copyWith(status: DiscoverStatus.failure, errorMessage: e.message),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: DiscoverStatus.failure,
          errorMessage: 'Không thể tải danh sách nhà hàng',
        ),
      );
    }
  }
}
