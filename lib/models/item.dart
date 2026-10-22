import 'category.dart';
import 'countdown.dart';

class Item {
  const Item({
    required this.id,
    required this.title,
    required this.category,
    required this.startsAt,
    required this.place,
    required this.capacity,
    required this._attendees,
    this.isOnline = false,
    this.description,
    this.isFavourite = false,
  });

  /// Defaults for a new item (R3).
  Item.empty()
    : this(
        id: '',
        title: '',
        category: EventCategory.tech,
        startsAt: DateTime.now().add(const Duration(days: 1)),
        place: '',
        capacity: 20,
        attendees: const [],
      );

  final String id;
  final String title;
  final EventCategory category;
  final DateTime startsAt;
  final String place;
  final int capacity;
  final bool isOnline;
  final String? description;
  final bool isFavourite;
  final List<String> _attendees;

  /// Read-only view: the list cannot be mutated from outside (R1).
  List<String> get attendees => List.unmodifiable(_attendees);

  // Derived values are getters, never fields (R4).
  int get count => _attendees.length;
  int get freePlaces => capacity - count < 0 ? 0 : capacity - count;
  bool get isFull => count >= capacity;
  bool get isPast => startsAt.isBefore(DateTime.now());
  bool contains(String name) => _attendees.contains(name);

  /// Record getter (R5).
  ({int taken, int free}) get places => (taken: count, free: freePlaces);

  Countdown countdown(DateTime now) {
    final diff = startsAt.difference(now);
    if (!diff.isNegative) return Upcoming(diff);
    final ago = -diff;
    return ago < const Duration(hours: 2) ? Started(ago) : const Ended();
  }

  Item copyWith({
    String? id,
    String? title,
    EventCategory? category,
    DateTime? startsAt,
    String? place,
    int? capacity,
    List<String>? attendees,
    bool? isOnline,
    String? description,
    bool? isFavourite,
  }) => Item(
    id: id ?? this.id,
    title: title ?? this.title,
    category: category ?? this.category,
    startsAt: startsAt ?? this.startsAt,
    place: place ?? this.place,
    capacity: capacity ?? this.capacity,
    attendees: List.of(attendees ?? _attendees),
    isOnline: isOnline ?? this.isOnline,
    description: description ?? this.description,
    isFavourite: isFavourite ?? this.isFavourite,
  );
}
