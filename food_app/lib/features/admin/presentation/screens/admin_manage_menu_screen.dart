import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../discover/data/restaurant_repository.dart';
import '../../../restaurant/data/models/menu_category.dart';
import '../../../../core/utils/formatters.dart';

class AdminManageMenuScreen extends StatefulWidget {
  const AdminManageMenuScreen({
    super.key,
    required this.restaurantRepository,
    required this.restaurantId,
  });

  final RestaurantRepository restaurantRepository;
  final int restaurantId;

  @override
  State<AdminManageMenuScreen> createState() => _AdminManageMenuScreenState();
}

class _AdminManageMenuScreenState extends State<AdminManageMenuScreen> {
  bool _loading = true;
  String? _error;
  List<MenuCategory> _categories = const [];

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
      final menu = await widget.restaurantRepository.fetchMenu(
        widget.restaurantId,
      );
      if (!mounted) return;
      setState(() {
        _categories = menu;
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

  Future<void> _addCategory() async {
    final nameController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh mục'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tên danh mục',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
    if (ok != true || nameController.text.trim().isEmpty) return;

    try {
      await widget.restaurantRepository.createCategory(
        restaurantId: widget.restaurantId,
        name: nameController.text.trim(),
      );
      if (!mounted) return;
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _toggleItem(MenuCategory category, int itemIndex) async {
    final item = category.items[itemIndex];
    try {
      await widget.restaurantRepository.updateMenuItem(
        restaurantId: widget.restaurantId,
        itemId: item.id,
        available: !item.isAvailable,
      );
      if (!mounted) return;
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteItem(int itemId) async {
    try {
      await widget.restaurantRepository.deleteMenuItem(
        restaurantId: widget.restaurantId,
        itemId: itemId,
      );
      if (!mounted) return;
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
      appBar: AppBar(
        title: const Text('Quản lý Menu'),
        actions: [
          IconButton(
            onPressed: _addCategory,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
          IconButton(
            onPressed: () => context.push(
              '/admin/menu/items/new?restaurantId=${widget.restaurantId}',
            ),
            icon: const Icon(Icons.add),
          ),
        ],
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
            else if (_categories.isEmpty)
              const Text('Chưa có danh mục nào')
            else
              ..._categories.map(
                (c) => Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    title: Text(c.name),
                    subtitle: Text('${c.items.length} món'),
                    children: c.items
                        .asMap()
                        .entries
                        .map(
                          (entry) => ListTile(
                            title: Text(entry.value.name),
                            subtitle: Text(
                              '${Formatters.money(entry.value.price)} • ${entry.value.isAvailable ? 'Đang bán' : 'Đang ẩn'}',
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'toggle') {
                                  _toggleItem(c, entry.key);
                                  return;
                                }
                                if (value == 'edit') {
                                  context
                                      .push(
                                        '/admin/menu/items/${entry.value.id}?restaurantId=${widget.restaurantId}',
                                      )
                                      .then((_) => _load());
                                  return;
                                }
                                if (value == 'delete') {
                                  _deleteItem(entry.value.id);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'toggle',
                                  child: Text('Toggle trạng thái'),
                                ),
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa'),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
