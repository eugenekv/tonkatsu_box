import 'package:intl/intl.dart';

enum DateFormatPreset {
  monthDayYear('month_day_year', 'MMM d, yyyy'),
  iso('iso', 'yyyy-MM-dd'),
  dmyDot('dmy_dot', 'dd.MM.yyyy'),
  mdySlash('mdy_slash', 'MM/dd/yyyy'),
  dmyWord('dmy_word', 'dd MMM yyyy');

  const DateFormatPreset(this.id, this.pattern);

  final String id;
  final String pattern;

  static DateFormatPreset fromId(String? id) {
    for (final DateFormatPreset p in DateFormatPreset.values) {
      if (p.id == id) return p;
    }
    return DateFormatPreset.monthDayYear;
  }

  String format(DateTime date, {String? locale}) =>
      DateFormat(pattern, locale).format(date);
}
