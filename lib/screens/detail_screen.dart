import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/item.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Item _item = widget.args.item;
  DateTime _now = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _onPrimary() async {
    final name = widget.args.profileName;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(
            label: 'Profile',
            onPressed: () => widget.args.onShowTab(profileTabIndex),
          ),
        ),
      );
      return;
    }
    final onList = _item.contains(name);
    final ok = await confirm(
      context,
      title: onList ? 'Cancel registration?' : 'Register?',
      message: onList
          ? 'Remove "$name" from "${_item.title}"?'
          : 'Add "$name" to "${_item.title}"?',
      confirmLabel: onList ? 'Cancel registration' : 'Register',
      cancelLabel: 'Back',
    );
    if (!ok || !mounted) return;
    final updated = _item.copyWith(
      attendees: onList
          ? [
              for (final n in _item.attendees)
                if (n != name) n,
            ]
          : [..._item.attendees, name],
    );
    setState(() => _item = updated);
    widget.args.onChanged(updated);
  }

  Future<void> _edit() async {
    final result = await Navigator.pushNamed<Item>(
      context,
      Routes.form,
      arguments: FormArgs(item: _item),
    );
    if (result == null || !mounted) return;
    setState(() => _item = result);
    widget.args.onChanged(result);
  }

  Future<void> _delete() async {
    final ok = await confirm(
      context,
      title: 'Delete event?',
      message: '"${_item.title}" will be removed.',
      confirmLabel: 'Delete',
    );
    if (!ok || !mounted) return;
    widget.args.onDelete(_item.id);
    Navigator.pop(context);
  }

  Future<void> _onMenu(_MenuAction action) => switch (action) {
    _MenuAction.edit => _edit(),
    _MenuAction.delete => _delete(),
  };

  @override
  Widget build(BuildContext context) {
    final name = widget.args.profileName;
    final onList = name.isNotEmpty && _item.contains(name);
    final blocked = !onList && _item.isFull;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: _onMenu,
              itemBuilder: (_) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            _Header(item: _item, now: _now),
            TabBar(
              tabs: [
                const Tab(text: 'About'),
                Tab(text: 'Names (${_item.count})'), // live count
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _AboutTab(item: _item),
                  _NamesTab(item: _item, you: name),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: blocked ? null : _onPrimary,
                    child: Text(
                      onList
                          ? 'Cancel registration'
                          : (_item.isFull ? 'Full' : 'Register'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _span(Duration d) {
  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
  if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
  return '${d.inMinutes}m';
}

/// Exhaustive switch over the sealed Countdown (R9).
String _countdownText(Countdown c) => switch (c) {
  Upcoming(:final left) => 'Starts in ${_span(left)}',
  Started(:final ago) => 'Started ${ago.inMinutes} min ago',
  Ended() => 'Ended',
};

class _Header extends StatelessWidget {
  const _Header({required this.item, required this.now});

  final Item item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 180,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/header.jpg', fit: BoxFit.cover),
          ColoredBox(color: scheme.scrim.withValues(alpha: 0.3)),
          Center(
            child: CircleAvatar(
              radius: 36,
              backgroundColor: scheme.surface,
              child: Icon(
                item.category.icon,
                size: 40,
                color: item.category.color(scheme),
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _Pill(text: item.category.label),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: _Pill(text: _countdownText(item.countdown(now))),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(text, style: theme.textTheme.labelMedium),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final (taken: taken, free: free) = item.places; // destructured (R5)
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow(icon: Icons.event, text: formatDate(item.startsAt)),
        _InfoRow(
          icon: item.isOnline ? Icons.link : Icons.place,
          text: item.place,
        ),
        _InfoRow(
          icon: Icons.people,
          text: '$taken of ${item.capacity} places taken, $free free',
        ),
        if (item.description case final text?)
          _InfoRow(icon: Icons.notes, text: text),
      ],
    );
  }
}

class _NamesTab extends StatelessWidget {
  const _NamesTab({required this.item, required this.you});

  final Item item;
  final String you;

  @override
  Widget build(BuildContext context) {
    final names = item.attendees;
    if (names.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        message: 'Nobody has registered yet',
      );
    }
    final theme = Theme.of(context);
    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (_, i) {
        final mine = you.isNotEmpty && names[i] == you;
        return ListTile(
          title: Text(
            mine ? 'You' : names[i],
            style: mine
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : null,
          ),
          trailing: Text('${i + 1}'),
        );
      },
    );
  }
}
