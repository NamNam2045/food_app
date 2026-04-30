import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/address_model.dart';
import '../../data/user_repository.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key, required this.userRepository});

  final UserRepository userRepository;

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  bool _loading = true;
  String? _error;
  List<AddressModel> _addresses = const [];

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
      final data = await widget.userRepository.getAddresses();
      if (!mounted) return;
      setState(() {
        _addresses = data;
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

  Future<void> _delete(int id) async {
    try {
      await widget.userRepository.deleteAddress(id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa địa chỉ')));
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ của tôi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/profile/addresses/new');
          _load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Thêm'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Column(
                children: [
                  Text(_error!),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: _load, child: const Text('Thử lại')),
                ],
              )
            else if (_addresses.isEmpty)
              const Center(child: Text('Chưa có địa chỉ nào'))
            else
              ..._addresses.map(
                (a) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      '${a.label}${a.defaultAddress ? ' (Mặc định)' : ''}',
                    ),
                    subtitle: Text(a.shortText),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await context.push(
                            '/profile/addresses/new',
                            extra: a,
                          );
                          _load();
                          return;
                        }
                        if (value == 'delete') {
                          _delete(a.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Sửa')),
                        PopupMenuItem(value: 'delete', child: Text('Xóa')),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
