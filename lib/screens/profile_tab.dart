import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/profile.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.items,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Item> items;
  final ThemeMode themeMode;
  final void Function(Profile profile) onProfileChanged;
  final void Function(ThemeMode mode) onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  static final _groupPattern = RegExp(r'^[A-Z]{2,4}-\d{2,3}$');

  final _formKey = GlobalKey<FormState>();
  final _groupFocus = FocusNode();
  late final TextEditingController _nameCtrl = TextEditingController(
    text: widget.profile.name,
  );
  late final TextEditingController _groupCtrl = TextEditingController(
    text: widget.profile.group,
  );

  // Local mirror of the chip selection: route pages are cached by the
  // Navigator, so a parameter alone may not repaint the chips.
  late ThemeMode _mode = widget.themeMode;

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The shell replaced the profile (e.g. "Reset data"): refill the fields.
    if (oldWidget.profile != widget.profile) {
      if (_nameCtrl.text != widget.profile.name) {
        _nameCtrl.text = widget.profile.name;
      }
      if (_groupCtrl.text != widget.profile.group) {
        _groupCtrl.text = widget.profile.group;
      }
    }
    if (oldWidget.themeMode != widget.themeMode) {
      _mode = widget.themeMode;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _groupCtrl.dispose();
    _groupFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return text.length < 2 ? 'Name is too short' : null;
  }

  String? _validateGroup(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    return _groupPattern.hasMatch(text) ? null : 'Use a format like CS-101';
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    widget.onProfileChanged(
      widget.profile.copyWith(
        name: _nameCtrl.text.trim(),
        group: _groupCtrl.text.trim(),
      ),
    );
  }

  void _setMode(ThemeMode mode) {
    setState(() => _mode = mode);
    widget.onThemeModeChanged(mode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = widget.profile.name;
    // Computed from the list on every build (R38).
    final lists = name.isEmpty
        ? 0
        : widget.items.where((i) => i.contains(name)).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: _validateName,
                onFieldSubmitted: (_) {
                  _submit();
                  _groupFocus.requestFocus();
                },
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _groupCtrl,
                focusNode: _groupFocus,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'CS-101',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                validator: _validateGroup,
                onFieldSubmitted: (_) => _submit(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Theme', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(mode.name),
                selected: _mode == mode,
                onSelected: (_) => _setMode(mode),
              ),
          ],
        ),
      ],
    );
  }
}
