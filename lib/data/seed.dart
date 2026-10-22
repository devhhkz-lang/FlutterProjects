import '../models/category.dart';
import '../models/item.dart';

DateTime _in(Duration d) => DateTime.now().add(d);

List<Item> seedItems() => [
  Item(
    id: 'e1', // 60-character title
    title: 'Annual Campus Hackathon: Building Apps With Flutter in 24 h!',
    category: EventCategory.tech,
    startsAt: _in(const Duration(days: 3)),
    place: 'Main Hall, Building A',
    capacity: 40,
    attendees: const ['Aigerim', 'Dana', 'Timur'],
    description: 'Teams of four build an app in one day.',
  ),
  Item(
    id: 'e2', // at its limit
    title: 'Jazz Night',
    category: EventCategory.music,
    startsAt: _in(const Duration(days: 5, hours: 2)),
    place: 'Student Club',
    capacity: 3,
    attendees: const ['Aruzhan', 'Bekzat', 'Madina'],
    description: 'Live band, free entry for students.',
  ),
  Item(
    id: 'e3', // past
    title: 'Autumn Football Cup',
    category: EventCategory.sport,
    startsAt: _in(const Duration(days: -2)),
    place: 'University Stadium',
    capacity: 22,
    attendees: const ['Nurlan', 'Askar'],
    description: 'Final of the inter-faculty cup.',
  ),
  Item(
    id: 'e4', // online: place is a link
    title: 'Intro to Dart Webinar',
    category: EventCategory.tech,
    startsAt: _in(const Duration(days: 1, hours: 4)),
    place: 'https://meet.example.com/dart-intro',
    capacity: 100,
    attendees: const ['Sanzhar'],
    isOnline: true,
    description: 'Records, sealed classes and pattern matching.',
  ),
  Item(
    id: 'e5', // no optional text
    title: 'Career Day',
    category: EventCategory.career,
    startsAt: _in(const Duration(days: 7)),
    place: 'Conference Room 2',
    capacity: 60,
    attendees: const [],
  ),
  Item(
    id: 'e6',
    title: 'Watercolour Workshop',
    category: EventCategory.art,
    startsAt: _in(const Duration(days: 2, hours: 5)),
    place: 'Art Studio',
    capacity: 12,
    attendees: const [
      'Laura',
      'Alina',
      'Dana',
      'Kamila',
      'Ernar',
      'Ruslan',
      'Zhanna',
      'Ali',
    ],
    description: 'All materials provided.',
  ),
  Item(
    id: 'e7',
    title: 'Basketball Open Training',
    category: EventCategory.sport,
    startsAt: _in(const Duration(days: 4)),
    place: 'Gym 1',
    capacity: 20,
    attendees: const ['Yerlan', 'Arman'],
    isFavourite: true,
  ),
  Item(
    id: 'e8',
    title: 'Open Mic Evening',
    category: EventCategory.music,
    startsAt: _in(const Duration(days: 9)),
    place: 'Cafe Library',
    capacity: 30,
    attendees: const ['Aisulu'],
    description: 'Poems, songs and stand-up.',
  ),
  Item(
    id: 'e9', // past
    title: 'CV Writing Clinic',
    category: EventCategory.career,
    startsAt: _in(const Duration(days: -6)),
    place: 'Room 305',
    capacity: 25,
    attendees: const ['Dias', 'Karina'],
    description: 'Personal feedback from recruiters.',
  ),
  Item(
    id: 'e10',
    title: 'UI Design Talk',
    category: EventCategory.art,
    startsAt: _in(const Duration(days: 6, hours: 3)),
    place: 'https://meet.example.com/ui-talk',
    capacity: 80,
    attendees: const ['Samal', 'Nazym'],
    isOnline: true,
    isFavourite: true,
  ),
  Item(
    id: 'e11', // almost full: "3 left" badge
    title: 'Robotics Lab Tour',
    category: EventCategory.tech,
    startsAt: _in(const Duration(days: 8)),
    place: 'Lab 12',
    capacity: 8,
    attendees: const ['Ilyas', 'Mira', 'Tair', 'Adil', 'Zarina'],
    description: 'See the robots built by senior students.',
  ),
  Item(
    id: 'e12', // started 20 minutes ago
    title: 'Chess Club Meetup',
    category: EventCategory.sport,
    startsAt: _in(const Duration(minutes: -20)),
    place: 'Common Room',
    capacity: 16,
    attendees: const ['Marat', 'Olzhas', 'Dana'],
  ),
];
