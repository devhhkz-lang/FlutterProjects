import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/format.dart';

const _lowPlacesThreshold = 5;

/// The one reusable card (R18).
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final Item item;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(item: item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDate(item.startsAt),
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      item.place,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onToggleFavourite,
                icon: Icon(
                  item.isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavourite ? scheme.error : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (taken: _, free: left) = item.places;
    final badge = item.isFull
        ? 'FULL'
        : (left <= _lowPlacesThreshold ? '$left left' : null);
    final color = item.category.color(scheme);

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(item.category.icon, color: color),
            ),
          ),
          if (badge != null)
            Positioned(
              bottom: -6,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.isFull ? scheme.error : scheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: item.isFull ? scheme.onError : scheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
