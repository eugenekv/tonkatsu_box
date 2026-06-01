import '../models/data_source.dart';
import '../models/media_type.dart';

/// Canonical image-cache id for a media cover.
///
/// Manga is the only multi-provider media type: AniList and MangaBaka can
/// share a numeric `externalId`, so manga covers are namespaced by source
/// (`anilist_1995`, `mangabaka_1995`) to avoid one overwriting the other.
/// Every other media type keeps the bare external id.
///
/// MUST be used by both the write side (download/save) and the read side
/// (display) so the keys line up.
String coverImageId({
  required MediaType mediaType,
  required int externalId,
  DataSource? source,
}) {
  if (mediaType == MediaType.manga) {
    return '${(source ?? DataSource.anilist).name}_$externalId';
  }
  return externalId.toString();
}
