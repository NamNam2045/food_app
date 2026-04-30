import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../logic/auth_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  static const _slides = <({IconData icon, String title, String subtitle})>[
    (
      icon: Icons.delivery_dining,
      title: 'Đặt món nhanh chóng',
      subtitle: 'Tìm món yêu thích và đặt chỉ với vài thao tác.',
    ),
    (
      icon: Icons.restaurant_menu,
      title: 'Nhà hàng đa dạng',
      subtitle: 'Khám phá menu theo khu vực, danh mục và đánh giá.',
    ),
    (
      icon: Icons.route,
      title: 'Theo dõi đơn realtime',
      subtitle: 'Cập nhật trạng thái đơn hàng liên tục đến khi giao xong.',
    ),
  ];

  Future<void> _finish() async {
    await context.read<AuthCubit>().completeOnboarding();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _index == _slides.length - 1;
    return Scaffold(
      appBar: AppBar(
        actions: [TextButton(onPressed: _finish, child: const Text('Bỏ qua'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (_, index) {
                  final s = _slides[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(s.icon, size: 120, color: Colors.deepOrange),
                      const SizedBox(height: 24),
                      Text(
                        s.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.subtitle,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? Colors.deepOrange
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  if (isLast) {
                    await _finish();
                    return;
                  }
                  await _pageController.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                  );
                },
                child: Text(isLast ? 'Bắt đầu' : 'Tiếp theo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
