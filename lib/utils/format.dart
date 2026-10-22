const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 18 Oct
String formatDay(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// 10:00
String formatClock(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

/// 18 Oct, 10:00
String formatDate(DateTime d) =>
    '${formatDay(d)}, ${formatClock(d.hour, d.minute)}';
