import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tonkatsu_box/core/database/database_service.dart';
import 'package:tonkatsu_box/features/releases/models/release_event.dart';
import 'package:tonkatsu_box/features/releases/providers/releases_provider.dart';
import 'package:tonkatsu_box/shared/models/data_source.dart';
import 'package:tonkatsu_box/shared/models/media_type.dart';
import 'package:tonkatsu_box/shared/models/tracked_release.dart';
import 'package:tonkatsu_box/shared/models/tv_episode.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(registerAllFallbacks);

  late MockDatabaseService mockDb;
  late MockTrackedReleaseDao trackedDao;
  late MockTvShowDao tvDao;
  late MockCollectionDao collDao;

  TrackedRelease tracked(int id, DataSource source, MediaType type) =>
      TrackedRelease(
        externalId: id,
        source: source,
        mediaType: type,
        createdAt: DateTime(2024),
      );

  TvEpisode episode(int show, int s, int e, String? air) => TvEpisode(
        tmdbShowId: show,
        seasonNumber: s,
        episodeNumber: e,
        name: 'E$e',
        airDate: air,
      );

  // Comfortably in the future so the "upcoming only" filter keeps these.
  const String future = '2999-01-01';
  const String past = '2000-01-01';

  setUp(() {
    mockDb = MockDatabaseService();
    trackedDao = MockTrackedReleaseDao();
    tvDao = MockTvShowDao();
    collDao = MockCollectionDao();
    when(() => mockDb.trackedReleaseDao).thenReturn(trackedDao);
    when(() => mockDb.tvShowDao).thenReturn(tvDao);
    when(() => mockDb.collectionDao).thenReturn(collDao);

    // By default every tracked show still lives in a collection.
    when(() => collDao.findCollectionItem(
          collectionId: any(named: 'collectionId'),
          mediaType: any(named: 'mediaType'),
          externalId: any(named: 'externalId'),
        )).thenAnswer((_) async => createTestCollectionItem());
    when(() => tvDao.getTvShowByTmdbId(any())).thenAnswer((_) async => null);
    when(() => tvDao.getEpisodesByShowId(any()))
        .thenAnswer((_) async => <TvEpisode>[]);
  });

  ProviderContainer makeContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        databaseServiceProvider.overrideWithValue(mockDb),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ReleasesNotifier', () {
    test('should return empty data when nothing is tracked', () async {
      when(() => trackedDao.getAll())
          .thenAnswer((_) async => <TrackedRelease>[]);

      final ReleasesCalendarData data =
          await makeContainer().read(releasesProvider.future);

      expect(data.trackedCount, 0);
      expect(data.events, isEmpty);
    });

    test('should keep only TMDB TV and anime subscriptions', () async {
      when(() => trackedDao.getAll()).thenAnswer((_) async => <TrackedRelease>[
            tracked(1, DataSource.tmdb, MediaType.tvShow),
            tracked(2, DataSource.anilist, MediaType.manga),
            tracked(3, DataSource.tmdb, MediaType.movie),
          ]);
      when(() => tvDao.getEpisodesByShowId(1))
          .thenAnswer((_) async => <TvEpisode>[episode(1, 1, 1, future)]);

      final ReleasesCalendarData data =
          await makeContainer().read(releasesProvider.future);

      expect(data.trackedCount, 1);
      expect(data.events.map((ReleaseEvent e) => e.externalId), <int>[1]);
    });

    test('should list upcoming episodes only and drop past ones', () async {
      when(() => trackedDao.getAll()).thenAnswer((_) async =>
          <TrackedRelease>[tracked(1, DataSource.tmdb, MediaType.tvShow)]);
      when(() => tvDao.getEpisodesByShowId(1)).thenAnswer(
        (_) async => <TvEpisode>[
          episode(1, 1, 1, past),
          episode(1, 1, 2, future),
        ],
      );

      final ReleasesCalendarData data =
          await makeContainer().read(releasesProvider.future);

      expect(data.events.length, 1);
      final ReleaseEvent only = data.events.single;
      expect(only.episode, 2);
      expect(only.isUpcoming, isTrue);
    });

    test('should drop a show no longer in any collection', () async {
      when(() => trackedDao.getAll()).thenAnswer((_) async =>
          <TrackedRelease>[tracked(1, DataSource.tmdb, MediaType.tvShow)]);
      when(() => tvDao.getEpisodesByShowId(1))
          .thenAnswer((_) async => <TvEpisode>[episode(1, 1, 1, future)]);
      when(() => collDao.findCollectionItem(
            collectionId: any(named: 'collectionId'),
            mediaType: any(named: 'mediaType'),
            externalId: any(named: 'externalId'),
          )).thenAnswer((_) async => null);

      final ReleasesCalendarData data =
          await makeContainer().read(releasesProvider.future);

      expect(data.trackedCount, 1);
      expect(data.events, isEmpty);
    });

    test('should skip episodes without a parseable air date', () async {
      when(() => trackedDao.getAll()).thenAnswer((_) async =>
          <TrackedRelease>[tracked(1, DataSource.tmdb, MediaType.tvShow)]);
      when(() => tvDao.getEpisodesByShowId(1)).thenAnswer(
        (_) async => <TvEpisode>[
          episode(1, 1, 1, null),
          episode(1, 1, 2, future),
        ],
      );

      final ReleasesCalendarData data =
          await makeContainer().read(releasesProvider.future);

      expect(data.events.length, 1);
      expect(data.events.single.episode, 2);
    });
  });
}
