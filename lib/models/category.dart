import 'package:flutter/material.dart';

enum EventCategory {
  tech('Tech', Icons.computer),
  music('Music', Icons.music_note),
  sport('Sport', Icons.sports_soccer),
  art('Art', Icons.palette),
  career('Career', Icons.work),
  football('Football', Icons.stadium);

  const EventCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Exhaustive switch expression returning a colorScheme role (R2).
  Color color(ColorScheme scheme) => switch (this) {
    EventCategory.tech => scheme.primary,
    EventCategory.music => scheme.secondary,
    EventCategory.sport => scheme.tertiary,
    EventCategory.art => scheme.error,
    EventCategory.career => scheme.outline,
    EventCategory.football => scheme.inversePrimary,
  };
}
