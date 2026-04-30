import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/discover/data/models/restaurant_summary.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({super.key, required this.restaurant, this.onTap});

  final RestaurantSummary restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    ).format(restaurant.deliveryFee);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child:
                  restaurant.bannerUrl != null &&
                      restaurant.bannerUrl!.isNotEmpty
                  ? Image.network(
                      restaurant.bannerUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackBanner(),
                    )
                  : _fallbackBanner(),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _OpenBadge(isOpen: restaurant.isOpen),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${restaurant.cuisineType} • ${restaurant.city}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '⭐ ${restaurant.ratingAvg.toStringAsFixed(1)} (${restaurant.ratingCount}) • ${restaurant.estimatedDeliveryMinutes} phút • Phí ship $money',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackBanner() {
    return Container(
      color: Colors.orange.shade100,
      child: const Icon(Icons.restaurant, size: 48, color: Colors.deepOrange),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.isOpen});

  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final bg = isOpen ? Colors.green.shade50 : Colors.grey.shade200;
    final fg = isOpen ? Colors.green.shade800 : Colors.grey.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isOpen ? 'Mở cửa' : 'Đóng cửa',
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
