import 'package:flutter/material.dart';

import '../models/item.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_list.dart';

class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onGoToList,
  });

  final List<Item> items;
  final void Function(Item item) onOpen;
  final void Function(String id) onToggleFavourite;
  final VoidCallback onGoToList;

  @override
  Widget build(BuildContext context) {
    final favourites = items.where((i) => i.isFavourite).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));

    if (favourites.isEmpty) {
      return EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet',
        buttonLabel: 'Browse events',
        onPressed: onGoToList,
      );
    }
    return ItemList(
      items: favourites,
      onOpen: onOpen,
      onToggleFavourite: onToggleFavourite,
    );
  }
}
