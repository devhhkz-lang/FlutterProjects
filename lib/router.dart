import 'package:flutter/material.dart';

import 'models/item.dart';
import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/item_form_screen.dart';

Route<dynamic>? generateAppRoute(RouteSettings settings) {
  final args = settings.arguments;
  if (settings.name == Routes.detail && args is DetailArgs) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    );
  }
  if (settings.name == Routes.form && args is FormArgs) {
    return MaterialPageRoute<Item>(
      settings: settings,
      builder: (_) => ItemFormScreen(args: args),
    );
  }
  return null;
}

Route<dynamic> unknownAppRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Not found')),
      body: const Center(child: Text('Not found')),
    ),
  );
}
