import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/category.dart';
import '../models/item.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/confirm_dialog.dart';

/// New and edit in one screen: args.item == null means "new".
class ItemFormScreen extends StatefulWidget {
  const ItemFormScreen({super.key, required this.args});

  final FormArgs args;

  @override
  State<ItemFormScreen> createState() => _ItemFormScreenState();
}

class _ItemFormScreenState extends State<ItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _placeFocus = FocusNode();
  final _limitFocus = FocusNode();
  final _descFocus = FocusNode();

  late final Item _initial;
  late final bool _isNew;
  late final DateTime? _initialDate;
  late final TimeOfDay? _initialTime;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _placeCtrl;
  late final TextEditingController _limitCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _timeCtrl;
  late final TextEditingController _descCtrl;

  late EventCategory _category;
  late bool _online;
  DateTime? _date;
  TimeOfDay? _time;

  bool _dirty = false;
  bool _saving = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.args.item;
    _isNew = existing == null;
    _initial = existing ?? Item.empty();

    final start = existing?.startsAt;
    _initialDate = start == null ? null : DateUtils.dateOnly(start);
    _initialTime = start == null ? null : TimeOfDay.fromDateTime(start);
    _date = _initialDate;
    _time = _initialTime;

    _category = _initial.category;
    _online = _initial.isOnline;

    _titleCtrl = TextEditingController(text: _initial.title);
    _placeCtrl = TextEditingController(text: _initial.place);
    _limitCtrl = TextEditingController(text: _initial.capacity.toString());
    _descCtrl = TextEditingController(text: _initial.description ?? '');
    _dateCtrl = TextEditingController(
      text: start == null ? '' : formatDay(start),
    );
    _timeCtrl = TextEditingController(
      text: start == null ? '' : formatClock(start.hour, start.minute),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _titleCtrl,
      _placeCtrl,
      _limitCtrl,
      _dateCtrl,
      _timeCtrl,
      _descCtrl,
    ]) {
      c.dispose();
    }
    for (final f in [_titleFocus, _placeFocus, _limitFocus, _descFocus]) {
      f.dispose();
    }
    super.dispose();
  }

  // Current values vs. the ones the form opened with (R30).
  bool _computeDirty() =>
      _titleCtrl.text != _initial.title ||
      _placeCtrl.text != _initial.place ||
      _limitCtrl.text != _initial.capacity.toString() ||
      _descCtrl.text != (_initial.description ?? '') ||
      _category != _initial.category ||
      _online != _initial.isOnline ||
      _date != _initialDate ||
      _time != _initialTime;

  void _syncDirty() {
    final dirty = _computeDirty();
    if (dirty != _dirty) setState(() => _dirty = dirty);
  }

  DateTime? _combined() {
    final d = _date;
    final t = _time;
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  void _dismissKeyboard(PointerDownEvent event) =>
      FocusManager.instance.primaryFocus?.unfocus();

  // ---- validators (R34) ----

  String? _validateTitle(String? value) {
    final t = (value ?? '').trim();
    if (t.length < 3) return 'Title must be at least 3 characters';
    if (t.length > 60) return 'Title must be at most 60 characters';
    return null;
  }

  String? _validatePlace(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return _online ? 'Enter a meeting link' : 'Enter a place';
    if (_online && !t.contains('://')) return 'A link must contain ://';
    return null;
  }

  String? _validateLimit(String? value) {
    final n = int.tryParse((value ?? '').trim());
    if (n == null) return 'Enter a whole number';
    if (n < 1 || n > 500) return 'Limit must be between 1 and 500';
    final taken = widget.args.item?.count ?? 0;
    if (n < taken) return 'Cannot be below the current $taken attendees';
    return null;
  }

  String? _validateDate(String? value) {
    final d = _date;
    if (d == null) return 'Pick a date';
    if (_isNew && d.isBefore(DateUtils.dateOnly(DateTime.now()))) {
      return 'Date must be in the future';
    }
    return null;
  }

  String? _validateTime(String? value) {
    if (_time == null) return 'Pick a time';
    final start = _combined();
    if (start == null) return null; // the date field reports the missing date
    if (_isNew && !start.isAfter(DateTime.now())) {
      return 'Start must be in the future';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    return (value ?? '').length > 300 ? 'Keep it under 300 characters' : null;
  }

  // ---- pickers (R36): Cancel returns null and keeps the old value ----

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    _dateCtrl.text = formatDay(picked);
    _syncDirty();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked == null || !mounted) return;
    setState(() => _time = picked);
    _timeCtrl.text = formatClock(picked.hour, picked.minute);
    _syncDirty();
  }

  // ---- leaving and saving ----

  /// canPop is false while dirty, so we first allow it, then pop next frame.
  void _leave([Item? result]) {
    setState(() => _leaving = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
  }

  Item _buildItem() {
    final base = widget.args.item;
    final desc = _descCtrl.text.trim();
    return Item(
      id: base?.id ?? 'e${DateTime.now().microsecondsSinceEpoch}',
      title: _titleCtrl.text.trim(),
      category: _category,
      startsAt: _combined() ?? _initial.startsAt,
      place: _placeCtrl.text.trim(),
      capacity: int.tryParse(_limitCtrl.text.trim()) ?? _initial.capacity,
      attendees: base?.attendees ?? const [],
      isOnline: _online,
      description: desc.isEmpty ? null : desc,
      isFavourite: base?.isFavourite ?? false,
    );
  }

  Future<void> _save() async {
    if (_saving) return; // a double tap does not save twice (R17)
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return; // one validate() (R33)
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return; // R14
    final item = _buildItem();
    setState(() => _saving = false);
    _leave(item); // Save never asks "Discard changes?"
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_dirty || _leaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final discard = await confirm(
          context,
          title: 'Discard changes?',
          message: 'Your edits will be lost.',
          confirmLabel: 'Discard',
          cancelLabel: 'Keep editing',
        );
        if (discard && mounted) _leave();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_isNew ? 'New event' : 'Edit event')),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: _syncDirty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      focusNode: _titleFocus,
                      maxLength: 60,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: _validateTitle,
                      onFieldSubmitted: (_) => _placeFocus.requestFocus(),
                      onTapOutside: _dismissKeyboard,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<EventCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        for (final c in EventCategory.values)
                          DropdownMenuItem(
                            value: c,
                            child: Row(
                              children: [
                                Icon(c.icon),
                                const SizedBox(width: 8),
                                Text(c.label),
                              ],
                            ),
                          ),
                      ],
                      validator: (v) => v == null ? 'Choose a category' : null,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _category = v);
                        _syncDirty();
                      },
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Online event'),
                      value: _online,
                      onChanged: (v) {
                        setState(() => _online = v ?? false);
                        _syncDirty();
                      },
                    ),
                    TextFormField(
                      controller: _placeCtrl,
                      focusNode: _placeFocus,
                      decoration: InputDecoration(
                        labelText: _online ? 'Meeting link' : 'Place',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: _online
                          ? TextInputType.url
                          : TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: _validatePlace,
                      onFieldSubmitted: (_) => _limitFocus.requestFocus(),
                      onTapOutside: _dismissKeyboard,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _limitCtrl,
                      focusNode: _limitFocus,
                      decoration: const InputDecoration(
                        labelText: 'Limit (places)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputAction: TextInputAction.next,
                      validator: _validateLimit,
                      onFieldSubmitted: (_) => _descFocus.requestFocus(),
                      onTapOutside: _dismissKeyboard,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _dateCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Date',
                              suffixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            validator: _validateDate,
                            onTap: _pickDate,
                            onTapOutside: _dismissKeyboard,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _timeCtrl,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Time',
                              suffixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(),
                            ),
                            validator: _validateTime,
                            onTap: _pickTime,
                            onTapOutside: _dismissKeyboard,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      focusNode: _descFocus,
                      minLines: 1,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      validator: _validateDescription,
                      onTapOutside: _dismissKeyboard,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
