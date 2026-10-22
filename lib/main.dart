import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'router.dart';
import 'routes.dart';
import 'screens/shell.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ThemeMode lives above MaterialApp (R11).
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus events',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: _themeMode,
      routes: {
        Routes.shell: (_) =>
            Shell(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
      },
      onGenerateRoute: generateAppRoute,
      onUnknownRoute: unknownAppRoute,
    );
  }
}
