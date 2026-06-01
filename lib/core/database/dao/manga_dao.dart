// DAO for manga from AniList / MangaBaka.

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../shared/models/data_source.dart';
import '../../../shared/models/manga.dart';

/// DAO for `manga_cache`. Row identity is the pair `(id, source)`, so the same
/// numeric `id` from AniList and MangaBaka can coexist.
class MangaDao {
  const MangaDao(this._getDatabase);

  final Future<Database> Function() _getDatabase;

  Future<void> upsertManga(Manga manga) async {
    final Database db = await _getDatabase();
    await db.insert(
      'manga_cache',
      manga.toDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertMangas(List<Manga> mangas) async {
    if (mangas.isEmpty) return;
    final Database db = await _getDatabase();
    final Batch batch = db.batch();
    for (final Manga manga in mangas) {
      batch.insert(
        'manga_cache',
        manga.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Manga?> getManga(
    int id, {
    DataSource source = DataSource.anilist,
  }) async {
    final Database db = await _getDatabase();
    final List<Map<String, dynamic>> rows = await db.query(
      'manga_cache',
      where: 'id = ? AND source = ?',
      whereArgs: <Object?>[id, source.name],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Manga.fromDb(rows.first);
  }

  /// Returns matches across all sources for the given ids; callers
  /// disambiguate by [Manga.source] (two rows can share a numeric `id`).
  Future<List<Manga>> getMangaByIds(List<int> ids) async {
    if (ids.isEmpty) return <Manga>[];
    final Database db = await _getDatabase();
    final String placeholders =
        List<String>.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> rows = await db.rawQuery(
      'SELECT * FROM manga_cache WHERE id IN ($placeholders)',
      ids,
    );
    return rows.map(Manga.fromDb).toList();
  }
}
