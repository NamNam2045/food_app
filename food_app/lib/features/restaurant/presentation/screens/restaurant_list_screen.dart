import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../discover/data/models/restaurant_summary.dart';
import '../../../discover/data/restaurant_repository.dart';
import '../../../../shared/widgets/restaurant_card.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({
    super.key,
    required this.repository,
    this.initialSearch,
    this.title = 'Nhà hàng',
  });

  final RestaurantRepository repository;
  final String? initialSearch;
  final String title;

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _loading = true;
  String? _error;
  List<RestaurantSummary> _items = const [];
  String _sortBy = 'rating';

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialSearch ?? '';
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.repository.fetchRestaurants(
        search: _controller.text.trim().isEmpty
            ? null
            : _controller.text.trim(),
        sortBy: _sortBy,
      );
      if (!mounted) return;
      setState(() {
        _items = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Tìm nhà hàng...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (_) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 350), _load);
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Sắp xếp:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                    DropdownMenuItem(
                      value: 'deliveryTime',
                      child: Text('Thời gian giao'),
                    ),
                    DropdownMenuItem(
                      value: 'distance',
                      child: Text('Khoảng cách'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _sortBy = value);
                    _load();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
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
            else if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('Không có nhà hàng phù hợp')),
              )
            else
              ..._items.map(
                (e) => RestaurantCard(
                  restaurant: e,
                  onTap: () => context.push('/restaurants/${e.id}'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
