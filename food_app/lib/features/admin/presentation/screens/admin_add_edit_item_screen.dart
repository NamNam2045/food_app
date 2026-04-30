import 'package:flutter/material.dart';

import '../../../discover/data/restaurant_repository.dart';
import '../../../restaurant/data/models/menu_category.dart';
import '../../../restaurant/data/models/menu_item.dart';

class AdminAddEditItemScreen extends StatefulWidget {
  const AdminAddEditItemScreen({
    super.key,
    required this.restaurantRepository,
    required this.restaurantId,
    this.itemId,
  });

  final RestaurantRepository restaurantRepository;
  final int restaurantId;
  final int? itemId;

  @override
  State<AdminAddEditItemScreen> createState() => _AdminAddEditItemScreenState();
}

class _AdminAddEditItemScreenState extends State<AdminAddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  List<MenuCategory> _categories = const [];
  int? _categoryId;
  bool _available = true;
  bool _featured = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
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
      final categories = menu;
      int? selectedCategory = categories.isNotEmpty
          ? categories.first.id
          : null;

      if (widget.itemId != null) {
        final item = await widget.restaurantRepository.fetchMenuItem(
          restaurantId: widget.restaurantId,
          itemId: widget.itemId!,
        );
        _fill(item);
        selectedCategory = item.categoryId;
      }

      if (!mounted) return;
      setState(() {
        _categories = categories;
        _categoryId = selectedCategory;
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

  void _fill(MenuItemModel item) {
    _nameController.text = item.name;
    _descriptionController.text = item.description ?? '';
    _priceController.text = item.price.toStringAsFixed(0);
    _imageController.text = item.imageUrl ?? '';
    _available = item.isAvailable;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn danh mục')));
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Giá không hợp lệ')));
      return;
    }

    setState(() => _saving = true);
    try {
      if (widget.itemId == null) {
        await widget.restaurantRepository.createMenuItem(
          restaurantId: widget.restaurantId,
          categoryId: _categoryId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          imageUrl: _imageController.text.trim().isEmpty
              ? null
              : _imageController.text.trim(),
          available: _available,
          featured: _featured,
        );
      } else {
        await widget.restaurantRepository.updateMenuItem(
          restaurantId: widget.restaurantId,
          itemId: widget.itemId!,
          categoryId: _categoryId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          price: price,
          imageUrl: _imageController.text.trim().isEmpty
              ? null
              : _imageController.text.trim(),
          available: _available,
          featured: _featured,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.itemId != null;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(editing ? 'Sửa món' : 'Thêm món')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 8),
              FilledButton(onPressed: _load, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Sửa món' : 'Thêm món')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                initialValue: _categoryId,
                decoration: const InputDecoration(
                  labelText: 'Danh mục',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map(
                      (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 10),
              _field(_nameController, 'Tên món'),
              const SizedBox(height: 10),
              _field(_descriptionController, 'Mô tả', required: false),
              const SizedBox(height: 10),
              _field(
                _priceController,
                'Giá',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              _field(_imageController, 'Image URL', required: false),
              SwitchListTile(
                value: _available,
                onChanged: (v) => setState(() => _available = v),
                title: const Text('Đang bán'),
              ),
              SwitchListTile(
                value: _featured,
                onChanged: (v) => setState(() => _featured = v),
                title: const Text('Món nổi bật'),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(editing ? 'Lưu thay đổi' : 'Tạo món mới'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (!required) return null;
        return (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null;
      },
    );
  }
}
