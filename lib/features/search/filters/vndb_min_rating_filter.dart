import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;

import '../../../l10n/app_localizations.dart';
import '../models/search_source.dart';

/// Minimum VNDB rating. VNDB uses a 10–100 Bayesian scale, so the option
/// values are the API-scale thresholds (a "7+" star rating is `70`).
class VndbMinRatingFilter extends SearchFilter {
  @override
  String get key => 'minRating';

  @override
  String placeholder(S l) => l.browseFilterMinRating;

  @override
  FilterOption get allOption =>
      const FilterOption(id: 'any', label: 'Any', value: null);

  @override
  Future<List<FilterOption>> options(WidgetRef ref, S l) async {
    return const <FilterOption>[
      FilterOption(id: '6', label: '6+', value: 60),
      FilterOption(id: '7', label: '7+', value: 70),
      FilterOption(id: '8', label: '8+', value: 80),
      FilterOption(id: '9', label: '9+', value: 90),
    ];
  }
}
