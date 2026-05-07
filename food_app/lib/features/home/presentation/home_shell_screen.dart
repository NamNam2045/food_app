import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/logic/auth_cubit.dart';
import '../../discover/data/restaurant_repository.dart';
import '../../discover/logic/discover_cubit.dart';
import '../../discover/presentation/discover_screen.dart';
import '../../order/data/order_repository.dart';
import '../../order/presentation/screens/order_history_screen.dart';
import '../../profile/data/user_repository.dart';
import '../../profile/presentation/screens/profile_screen.dart';
import '../../review/data/review_repository.dart';
import '../../search/presentation/screens/search_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final restaurantRepo = context.read<RestaurantRepository>();
    final orderRepo = context.read<OrderRepository>();
    final reviewRepo = context.read<ReviewRepository>();
    final userRepo = context.read<UserRepository>();
    final authCubit = context.read<AuthCubit>();

    final tabs = <Widget>[
      BlocProvider(
        create: (_) =>
            DiscoverCubit(repository: restaurantRepo)..loadRestaurants(),
        child: const DiscoverScreen(),
      ),
      SearchScreen(repository: restaurantRepo),
      OrderHistoryScreen(
        orderRepository: orderRepo,
        reviewRepository: reviewRepo,
      ),
      ProfileScreen(userRepository: userRepo, authCubit: authCubit),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Khám phá',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Đơn hàng',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
