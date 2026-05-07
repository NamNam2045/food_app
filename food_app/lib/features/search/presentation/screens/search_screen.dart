import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../discover/data/models/restaurant_summary.dart';
import '../../../discover/data/restaurant_repository.dart';
import '../../../../shared/widgets/restaurant_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    required this.repository,
    this.initialQuery,
    this.showAppBar = false,
  });

  final RestaurantRepository repository;
  final String? initialQuery;
  final bool showAppBar;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _sortOptions = <String, String>{
    'rating': 'Rating',
    'deliveryTime': 'Thời gian giao',
    'distance': 'Khoảng cách',
  };

  final TextEditingController _queryController = TextEditingController();
  Timer? _debounce;

  bool _loading = true;
  String? _error;
  List<RestaurantSummary> _items = const [];
  bool _openNowOnly = false;
  String _sortBy = 'rating';

  @override
  void initState() {
    super.initState();
    _queryController.text = widget.initialQuery?.trim() ?? '';
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final items = await widget.repository.fetchRestaurants(
        search: _queryController.text.trim().isEmpty
            ? null
            : _queryController.text.trim(),
        isOpen: _openNowOnly ? true : null,
        sortBy: _sortBy,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _load();
    });
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () => _load(silent: false),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          TextField(
            controller: _queryController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm nhà hàng, món ăn...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _queryController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _queryController.clear();
                        _load();
                      },
                      icon: const Icon(Icons.close),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilterChip(
                label: const Text('Đang mở'),
                selected: _openNowOnly,
                onSelected: (value) {
                  setState(() => _openNowOnly = value);
                  _load();
                },
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _sortBy,
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() => _sortBy = value);
                  _load();
                },
                items: _sortOptions.entries
                    .map(
                      (entry) => DropdownMenuItem<String>(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
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
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Không tìm thấy nhà hàng phù hợp.')),
            )
          else
            ..._items.map(
              (restaurant) => RestaurantCard(
                restaurant: restaurant,
                onTap: () => context.push('/restaurants/${restaurant.id}'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAppBar) {
      return SafeArea(child: _buildBody());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: _buildBody(),
    );
  }
}
