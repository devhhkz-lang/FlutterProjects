import 'package:flutter/material.dart';

import '../models/item.dart';
import 'item_card.dart';

const _gridBreakpoint = 600.0;
const _gridCellMaxWidth = 360.0;
const _gridCellHeight = 140.0;
const _listPadding = EdgeInsets.fromLTRB(12, 12, 12, 88);

/// Phone: ListView.separated. Wide: GridView.builder.
/// The choice is made by LayoutBuilder, not MediaQuery (R20).
class ItemList extends StatelessWidget {
  const ItemList({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onToggleFavourite,
  });

  final List<Item> items;
  final void Function(Item item) onOpen;
  final void Function(String id) onToggleFavourite;

  Widget _card(Item item) => ItemCard(
    item: item,
    onTap: () => onOpen(item),
    onToggleFavourite: () => onToggleFavourite(item.id),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _gridBreakpoint) {
          return GridView.builder(
            padding: _listPadding,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: _gridCellMaxWidth,
              mainAxisExtent: _gridCellHeight,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => _card(items[i]),
          );
        }
        return ListView.separated(
          padding: _listPadding,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _card(items[i]),
        );
      },
    );
  }
}
