import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/restaurant_card.dart';
import '../logic/discover_cubit.dart';
import '../logic/discover_state.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () => context.read<DiscoverCubit>().loadRestaurants(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Khám phá nhà hàng',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Tìm món ngon gần bạn'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm nhà hàng, món ăn...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    context
                                        .read<DiscoverCubit>()
                                        .loadRestaurants(search: '');
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (value) {
                          _debounce?.cancel();
                          _debounce = Timer(
                            const Duration(milliseconds: 350),
                            () {
                              context.read<DiscoverCubit>().loadRestaurants(
                                search: value.trim(),
                              );
                            },
                          );
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (state.status == DiscoverStatus.loading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.status == DiscoverStatus.failure)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.errorMessage ?? 'Không thể tải dữ liệu'),
                          const SizedBox(height: 10),
                          FilledButton(
                            onPressed: () =>
                                context.read<DiscoverCubit>().loadRestaurants(),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (state.restaurants.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('Không tìm thấy nhà hàng phù hợp.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  sliver: SliverList.separated(
                    itemCount: state.restaurants.length,
                    itemBuilder: (_, index) {
                      final restaurant = state.restaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                        onTap: () =>
                            context.push('/restaurants/${restaurant.id}'),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 2),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
