import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_service.dart';
import '../../shared/models/mangabaka_genre.dart';

/// MangaBaka genres are a fixed enum seeded into `mangabaka_genres` (no API
/// endpoint), so this provider just reads the static catalog from SQLite.
final FutureProvider<List<MangaBakaGenre>> mangaBakaGenresProvider =
    FutureProvider<List<MangaBakaGenre>>((Ref ref) async {
  return ref.watch(mangaBakaGenreDaoProvider).getAll();
});
