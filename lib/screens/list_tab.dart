import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/item.dart';
import '../widgets/empty_state.dart';
import '../widgets/item_list.dart';

class ListTab extends StatefulWidget {
  const ListTab({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onToggleFavourite,
    required this.onAdd,
  });

  final List<Item> items;
  final void Function(Item item) onOpen;
  final void Function(String id) onToggleFavourite;
  final VoidCallback onAdd;

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  EventCategory? _category;
  bool _showPast = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// where() builds a new list, so sort() never touches the state (R7).
  List<Item> _visible() {
    final q = _query.trim().toLowerCase();
    final result = widget.items
        .where(
          (i) =>
              (_category == null || i.category == _category) &&
              (_showPast || !i.isPast) &&
              (q.isEmpty ||
                  i.title.toLowerCase().contains(q) ||
                  i.place.toLowerCase().contains(q)),
        )
        .toList();
    result.sort((a, b) {
      if (a.isPast != b.isPast) return a.isPast ? 1 : -1; // past last
      return a.startsAt.compareTo(b.startsAt);
    });
    return result;
  }

  void _clearSearch() {
    _searchCtrl.clear();
    setState(() => _query = '');
  }

  void _resetFilters() {
    _searchCtrl.clear();
    setState(() {
      _query = '';
      _category = null;
      _showPast = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy,
        message: 'No events yet',
        buttonLabel: 'Add event',
        onPressed: widget.onAdd,
      );
    }

    final visible = _visible();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search events',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _category == null,
                onSelected: (_) => setState(() => _category = null),
              ),
              for (final c in EventCategory.values) ...[
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: Icon(c.icon, size: 18),
                  label: Text(c.label),
                  selected: _category == c,
                  onSelected: (_) => setState(() => _category = c),
                ),
              ],
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (v) => setState(() => _showPast = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No events match',
                  buttonLabel: 'Reset filters',
                  onPressed: _resetFilters,
                )
              : ItemList(
                  items: visible,
                  onOpen: widget.onOpen,
                  onToggleFavourite: widget.onToggleFavourite,
                ),
        ),
      ],
    );
  }
}
