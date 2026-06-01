import 'package:flutter_test/flutter_test.dart';
import 'package:tonkatsu_box/shared/models/data_source.dart';
import 'package:tonkatsu_box/shared/models/media_type.dart';
import 'package:tonkatsu_box/shared/utils/cover_image_id.dart';

void main() {
  group('coverImageId', () {
    test('namespaces manga by source', () {
      expect(
        coverImageId(
          mediaType: MediaType.manga,
          externalId: 1995,
          source: DataSource.mangabaka,
        ),
        'mangabaka_1995',
      );
      expect(
        coverImageId(
          mediaType: MediaType.manga,
          externalId: 1995,
          source: DataSource.anilist,
        ),
        'anilist_1995',
      );
    });

    test('manga with null source defaults to anilist', () {
      expect(
        coverImageId(mediaType: MediaType.manga, externalId: 1995),
        'anilist_1995',
      );
    });

    test('manga key contains exactly one separator usable for import split', () {
      final String id = coverImageId(
        mediaType: MediaType.manga,
        externalId: 1995,
        source: DataSource.mangabaka,
      );
      // Import splits `folder/imageId` on '/', so the id itself must not add
      // a second slash.
      expect(id.contains('/'), isFalse);
    });

    test('non-manga types keep the bare external id', () {
      for (final MediaType type in <MediaType>[
        MediaType.game,
        MediaType.movie,
        MediaType.tvShow,
        MediaType.anime,
        MediaType.visualNovel,
      ]) {
        expect(
          coverImageId(mediaType: type, externalId: 42),
          '42',
        );
      }
    });
  });
}
