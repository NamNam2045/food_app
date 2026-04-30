import 'package:equatable/equatable.dart';

import '../data/models/restaurant_summary.dart';

enum DiscoverStatus { initial, loading, success, failure }

class DiscoverState extends Equatable {
  const DiscoverState({
    this.status = DiscoverStatus.initial,
    this.restaurants = const <RestaurantSummary>[],
    this.errorMessage,
    this.searchText = '',
  });

  final DiscoverStatus status;
  final List<RestaurantSummary> restaurants;
  final String? errorMessage;
  final String searchText;

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<RestaurantSummary>? restaurants,
    String? errorMessage,
    String? searchText,
    bool clearError = false,
  }) {
    return DiscoverState(
      status: status ?? this.status,
      restaurants: restaurants ?? this.restaurants,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      searchText: searchText ?? this.searchText,
    );
  }

  @override
  List<Object?> get props => [status, restaurants, errorMessage, searchText];
}
