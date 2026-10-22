import 'package:flutter/material.dart';

// The only literal colour in lib/: ColorScheme.fromSeed needs a seed.
const _seed = Color(0xFF3F51B5);

ThemeData lightTheme() =>
    ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seed));

ThemeData darkTheme() => ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: Brightness.dark,
  ),
);
