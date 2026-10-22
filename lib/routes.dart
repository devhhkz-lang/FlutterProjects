import 'models/item.dart';

/// All route names live here (R25).
class Routes {
  const Routes._();

  static const shell = '/';
  static const detail = '/detail';
  static const form = '/form';
}

const profileTabIndex = 2;

/// Typed arguments for the detail screen (R26).
class DetailArgs {
  const DetailArgs({
    required this.item,
    required this.profileName,
    required this.onChanged,
    required this.onDelete,
    required this.onShowTab,
  });

  final Item item;
  final String profileName;
  final void Function(Item item) onChanged;
  final void Function(String id) onDelete;
  final void Function(int tab) onShowTab;
}

/// Typed arguments for the form: null item means "new".
class FormArgs {
  const FormArgs({this.item});

  final Item? item;
}
