import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;

import '../../../l10n/app_localizations.dart';
import '../models/search_source.dart';

/// Keeps only VNs that have an anime adaptation (`has_anime`).
class VndbHasAnimeFilter extends SearchFilter {
  @override
  String get key => 'hasAnime';

  @override
  String placeholder(S l) => l.browseFilterAnimeAdaptation;

  @override
  FilterOption get allOption =>
      const FilterOption(id: 'any', label: 'Any', value: null);

  @override
  Future<List<FilterOption>> options(WidgetRef ref, S l) async {
    return <FilterOption>[
      FilterOption(id: 'yes', label: l.vndbHasAnimeAdaptation, value: true),
    ];
  }
}
