import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/network/api_client.dart';
import 'core/routing/go_router_refresh_stream.dart';
import 'core/storage/token_storage.dart';
import 'features/admin/presentation/screens/admin_add_edit_item_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'features/admin/presentation/screens/admin_manage_menu_screen.dart';
import 'features/admin/presentation/screens/admin_manage_orders_screen.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_cubit.dart';
import 'features/auth/logic/auth_state.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/cart/data/cart_repository.dart';
import 'features/cart/logic/cart_cubit.dart';
import 'features/cart/presentation/cart_screen.dart';
import 'features/discover/data/restaurant_repository.dart';
import 'features/home/presentation/home_shell_screen.dart';
import 'features/notification/presentation/screens/notifications_screen.dart';
import 'features/order/data/order_repository.dart';
import 'features/order/presentation/screens/checkout_screen.dart';
import 'features/order/presentation/screens/order_detail_screen.dart';
import 'features/order/presentation/screens/order_history_screen.dart';
import 'features/order/presentation/screens/order_tracking_screen.dart';
import 'features/profile/data/models/address_model.dart';
import 'features/profile/data/user_repository.dart';
import 'features/profile/presentation/screens/add_address_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/profile/presentation/screens/help_faq_screen.dart';
import 'features/profile/presentation/screens/payment_methods_screen.dart';
import 'features/profile/presentation/screens/privacy_policy_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/saved_addresses_screen.dart';
import 'features/profile/presentation/screens/terms_of_use_screen.dart';
import 'features/restaurant/logic/restaurant_detail_cubit.dart';
import 'features/restaurant/presentation/restaurant_detail_screen.dart';
import 'features/restaurant/presentation/screens/item_detail_screen.dart';
import 'features/restaurant/presentation/screens/restaurant_list_screen.dart';
import 'features/review/data/review_repository.dart';
import 'features/search/presentation/screens/search_screen.dart';

class FoodRushApp extends StatefulWidget {
  const FoodRushApp({super.key});

  @override
  State<FoodRushApp> createState() => _FoodRushAppState();
}

class _FoodRushAppState extends State<FoodRushApp> {
  late final TokenStorage _tokenStorage;
  late final ApiClient _apiClient;
  late final AuthRepository _authRepository;
  late final RestaurantRepository _restaurantRepository;
  late final CartRepository _cartRepository;
  late final UserRepository _userRepository;
  late final OrderRepository _orderRepository;
  late final ReviewRepository _reviewRepository;
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _tokenStorage = TokenStorage();
    _apiClient = ApiClient(tokenStorage: _tokenStorage);
    _authRepository = AuthRepository(
      apiClient: _apiClient,
      tokenStorage: _tokenStorage,
    );
    _restaurantRepository = RestaurantRepository(apiClient: _apiClient);
    _cartRepository = CartRepository(apiClient: _apiClient);
    _userRepository = UserRepository(apiClient: _apiClient);
    _orderRepository = OrderRepository(apiClient: _apiClient);
    _reviewRepository = ReviewRepository(apiClient: _apiClient);
    _authCubit = AuthCubit(
      authRepository: _authRepository,
      tokenStorage: _tokenStorage,
    );
    _router = _buildRouter();
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: GoRouterRefreshStream(_authCubit.stream),
      redirect: (context, state) {
        final authState = _authCubit.state;
        final location = state.uri.path;

        final bool inAuthPages =
            location == '/login' ||
            location == '/register' ||
            location == '/onboarding' ||
            location == '/forgot-password';

        final bool isRestaurantPublicRoute =
            location == '/restaurants' ||
            RegExp(r'^/restaurants/[^/]+$').hasMatch(location);

        final bool isPublic =
            location == '/' ||
            location == '/onboarding' ||
            location == '/login' ||
            location == '/register' ||
            location == '/forgot-password' ||
            isRestaurantPublicRoute;

        if (authState.status == AuthStatus.unknown) {
          return location == '/' ? null : '/';
        }

        if (!authState.onboardingSeen) {
          return location == '/onboarding' ? null : '/onboarding';
        }

        if (!authState.isAuthenticated && !isPublic) {
          return '/login';
        }

        if (authState.isAuthenticated && (inAuthPages || location == '/')) {
          return '/home';
        }

        if (location.startsWith('/admin') && !authState.isRestaurantAdmin) {
          return '/home';
        }

        if (!authState.isAuthenticated && location == '/') {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(
          path: '/onboarding',
          builder: (_, __) => const OnboardingScreen(),
        ),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
          path: '/forgot-password',
          builder: (_, __) => ForgotPasswordScreen(repository: _authRepository),
        ),
        GoRoute(path: '/home', builder: (_, __) => const HomeShellScreen()),
        GoRoute(
          path: '/restaurants',
          builder: (_, state) => RestaurantListScreen(
            repository: _restaurantRepository,
            initialSearch: state.uri.queryParameters['search'],
            title: 'Danh sách nhà hàng',
          ),
        ),
        GoRoute(
          path: '/search',
          builder: (_, state) => SearchScreen(
            repository: _restaurantRepository,
            initialQuery: state.uri.queryParameters['q'],
            showAppBar: true,
          ),
        ),
        GoRoute(
          path: '/restaurants/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return BlocProvider(
              create: (_) => RestaurantDetailCubit(
                restaurantRepository: _restaurantRepository,
                cartRepository: _cartRepository,
                restaurantIdOrSlug: id,
              )..load(),
              child: const RestaurantDetailScreen(),
            );
          },
        ),
        GoRoute(
          path: '/restaurants/:rId/items/:id',
          builder: (_, state) {
            final rId = int.tryParse(state.pathParameters['rId'] ?? '');
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (rId == null || id == null) {
              return const _MissingParamScreen(message: 'Thiếu tham số món ăn');
            }
            return ItemDetailScreen(
              restaurantId: rId,
              itemId: id,
              restaurantRepository: _restaurantRepository,
              cartRepository: _cartRepository,
            );
          },
        ),
        GoRoute(
          path: '/cart',
          builder: (_, __) => BlocProvider(
            create: (_) => CartCubit(repository: _cartRepository)..loadCart(),
            child: const CartScreen(),
          ),
        ),
        GoRoute(
          path: '/checkout',
          builder: (_, __) => CheckoutScreen(
            cartRepository: _cartRepository,
            userRepository: _userRepository,
            orderRepository: _orderRepository,
          ),
        ),
        GoRoute(
          path: '/orders',
          builder: (_, __) => OrderHistoryScreen(
            orderRepository: _orderRepository,
            reviewRepository: _reviewRepository,
          ),
        ),
        GoRoute(
          path: '/orders/:id',
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const _MissingParamScreen(message: 'Thiếu orderId');
            }
            return OrderDetailScreen(
              orderId: id,
              orderRepository: _orderRepository,
            );
          },
        ),
        GoRoute(
          path: '/orders/:id/tracking',
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const _MissingParamScreen(message: 'Thiếu orderId');
            }
            return OrderTrackingScreen(
              orderId: id,
              orderRepository: _orderRepository,
            );
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => ProfileScreen(
            userRepository: _userRepository,
            authCubit: _authCubit,
          ),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (_, __) =>
              EditProfileScreen(userRepository: _userRepository),
        ),
        GoRoute(
          path: '/profile/addresses',
          builder: (_, __) =>
              SavedAddressesScreen(userRepository: _userRepository),
        ),
        GoRoute(
          path: '/profile/addresses/new',
          builder: (_, state) => AddAddressScreen(
            userRepository: _userRepository,
            initial: state.extra is AddressModel
                ? state.extra as AddressModel
                : null,
          ),
        ),
        GoRoute(
          path: '/profile/payment-methods',
          builder: (_, __) => const PaymentMethodsScreen(),
        ),
        GoRoute(
          path: '/support/faq',
          builder: (_, __) => const HelpFaqScreen(),
        ),
        GoRoute(
          path: '/support/terms',
          builder: (_, __) => const TermsOfUseScreen(),
        ),
        GoRoute(
          path: '/support/privacy',
          builder: (_, __) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (_, __) =>
              NotificationsScreen(orderRepository: _orderRepository),
        ),
        GoRoute(
          path: '/admin',
          builder: (_, __) => AdminDashboardScreen(
            restaurantRepository: _restaurantRepository,
            orderRepository: _orderRepository,
          ),
        ),
        GoRoute(
          path: '/admin/menu',
          builder: (_, state) {
            final restaurantId = int.tryParse(
              state.uri.queryParameters['restaurantId'] ?? '',
            );
            if (restaurantId == null) {
              return const _MissingParamScreen(
                message: 'Thiếu restaurantId cho quản lý menu',
              );
            }
            return AdminManageMenuScreen(
              restaurantRepository: _restaurantRepository,
              restaurantId: restaurantId,
            );
          },
        ),
        GoRoute(
          path: '/admin/menu/items/new',
          builder: (_, state) {
            final restaurantId = int.tryParse(
              state.uri.queryParameters['restaurantId'] ?? '',
            );
            if (restaurantId == null) {
              return const _MissingParamScreen(message: 'Thiếu restaurantId');
            }
            return AdminAddEditItemScreen(
              restaurantRepository: _restaurantRepository,
              restaurantId: restaurantId,
            );
          },
        ),
        GoRoute(
          path: '/admin/menu/items/:id',
          builder: (_, state) {
            final restaurantId = int.tryParse(
              state.uri.queryParameters['restaurantId'] ?? '',
            );
            final itemId = int.tryParse(state.pathParameters['id'] ?? '');
            if (restaurantId == null || itemId == null) {
              return const _MissingParamScreen(
                message: 'Thiếu restaurantId hoặc itemId',
              );
            }
            return AdminAddEditItemScreen(
              restaurantRepository: _restaurantRepository,
              restaurantId: restaurantId,
              itemId: itemId,
            );
          },
        ),
        GoRoute(
          path: '/admin/orders',
          builder: (_, state) {
            final restaurantId = int.tryParse(
              state.uri.queryParameters['restaurantId'] ?? '',
            );
            if (restaurantId == null) {
              return const _MissingParamScreen(
                message: 'Thiếu restaurantId cho quản lý đơn',
              );
            }
            return AdminManageOrdersScreen(
              orderRepository: _orderRepository,
              restaurantId: restaurantId,
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _restaurantRepository),
        RepositoryProvider.value(value: _cartRepository),
        RepositoryProvider.value(value: _userRepository),
        RepositoryProvider.value(value: _orderRepository),
        RepositoryProvider.value(value: _reviewRepository),
      ],
      child: BlocProvider.value(
        value: _authCubit,
        child: MaterialApp.router(
          title: 'FoodRush',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFE85B2E),
              primary: const Color(0xFFE85B2E),
            ),
            scaffoldBackgroundColor: const Color(0xFFFAFAFA),
            useMaterial3: true,
          ),
          routerConfig: _router,
        ),
      ),
    );
  }
}

class _MissingParamScreen extends StatelessWidget {
  const _MissingParamScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Không thể mở màn hình')),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
      ),
    );
  }
}
