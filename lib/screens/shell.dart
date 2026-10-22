import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/item.dart';
import '../models/profile.dart';
import '../routes.dart';
import '../widgets/app_drawer.dart';
import '../widgets/confirm_dialog.dart';
import 'favourites_tab.dart';
import 'list_tab.dart';
import 'profile_tab.dart';

class Shell extends StatefulWidget {
  const Shell({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final void Function(ThemeMode mode) onThemeModeChanged;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  // The list and the profile live here (R10).
  List<Item> _items = seedItems();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _selectTab(int index) => setState(() => _tab = index);

  /// Used by pushed screens: close them, then switch the tab (R28).
  void _showTab(int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    _selectTab(index);
  }

  void _toggleFavourite(String id) {
    setState(() {
      _items = [
        for (final i in _items)
          if (i.id == id) i.copyWith(isFavourite: !i.isFavourite) else i,
      ];
    });
  }

  void _replaceItem(Item updated) {
    setState(() {
      _items = [
        for (final i in _items)
          if (i.id == updated.id) updated else i,
      ];
    });
  }

  void _deleteItem(String id) {
    setState(() => _items = _items.where((i) => i.id != id).toList());
  }

  void _setProfile(Profile profile) => setState(() => _profile = profile);

  void _openDetail(Item item) {
    Navigator.pushNamed<void>(
      context,
      Routes.detail,
      arguments: DetailArgs(
        item: item,
        profileName: _profile.name,
        onChanged: _replaceItem,
        onDelete: _deleteItem,
        onShowTab: _showTab,
      ),
    );
  }

  Future<void> _addItem() async {
    final created = await Navigator.pushNamed<Item>(
      context,
      Routes.form,
      arguments: const FormArgs(),
    );
    if (created == null || !mounted) {
      return; // backing out changes nothing (R27)
    }
    setState(() => _items = [..._items, created]);
  }

  Future<void> _showAbout() {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About'),
        content: const Text('Campus events: a Flutter lab app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    final ok = await confirm(
      context,
      title: 'Reset data?',
      message: 'Events return to the seed and the profile is cleared.',
      confirmLabel: 'Reset',
    );
    if (!ok || !mounted) return;
    setState(() {
      _items = seedItems();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favCount = _items.where((i) => i.isFavourite).length;
    return Scaffold(
      appBar: AppBar(title: const Text('Campus events')),
      drawer: AppDrawer(onAbout: _showAbout, onReset: _resetData),
      body: IndexedStack(
        index: _tab,
        children: [
          ListTab(
            items: _items,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
            onAdd: _addItem,
          ),
          FavouritesTab(
            items: _items,
            onOpen: _openDetail,
            onToggleFavourite: _toggleFavourite,
            onGoToList: () => _selectTab(0),
          ),
          ProfileTab(
            profile: _profile,
            items: _items,
            themeMode: widget.themeMode,
            onProfileChanged: _setProfile,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _addItem,
              tooltip: 'New event',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite),
            ),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
