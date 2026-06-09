import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;

import '../../../l10n/app_localizations.dart';
import '../models/search_source.dart';

/// VNDB play-time estimate (`length`, 1 = Very short … 5 = Very long).
class VndbLengthFilter extends SearchFilter {
  @override
  String get key => 'length';

  @override
  String placeholder(S l) => l.browseFilterLength;

  @override
  FilterOption get allOption =>
      const FilterOption(id: 'any', label: 'Any', value: null);

  @override
  Future<List<FilterOption>> options(WidgetRef ref, S l) async {
    return <FilterOption>[
      FilterOption(id: '1', label: l.vndbLengthVeryShort, value: 1),
      FilterOption(id: '2', label: l.vndbLengthShort, value: 2),
      FilterOption(id: '3', label: l.vndbLengthMedium, value: 3),
      FilterOption(id: '4', label: l.vndbLengthLong, value: 4),
      FilterOption(id: '5', label: l.vndbLengthVeryLong, value: 5),
    ];
  }
}
