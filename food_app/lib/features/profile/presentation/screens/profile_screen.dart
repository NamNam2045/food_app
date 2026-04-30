import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/logic/auth_cubit.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/user_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.userRepository,
    required this.authCubit,
  });

  final UserRepository userRepository;
  final AuthCubit authCubit;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String? _error;
  UserProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await widget.userRepository.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _logout() async {
    await widget.authCubit.logout();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hồ sơ')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'Không thể tải hồ sơ'),
              const SizedBox(height: 8),
              FilledButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    final profile = _profile!;

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            const SizedBox(height: 14),
            ListTile(
              leading: CircleAvatar(
                radius: 26,
                child: Text(
                  profile.firstName.isEmpty ? '?' : profile.firstName[0],
                ),
              ),
              title: Text(profile.fullName),
              subtitle: Text(profile.email),
              trailing: TextButton(
                onPressed: () => context.push('/profile/edit'),
                child: const Text('Chỉnh sửa'),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: const Text('Địa chỉ của tôi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/profile/addresses'),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card_outlined),
              title: const Text('Phương thức thanh toán'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Màn phương thức thanh toán sẽ cập nhật ở bước sau.',
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('Thông báo'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/notifications'),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Trợ giúp & FAQ'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Điều khoản sử dụng'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: const Text('Chính sách bảo mật'),
              onTap: () {},
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.tonal(
                onPressed: _logout,
                child: const Text('Đăng xuất'),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
