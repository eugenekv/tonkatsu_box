import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';

/// Sentinel for the "All" reset item: PopupMenuButton treats null as menu
/// dismissal (onSelected is not called), so the caller maps this back to null.
const String kFilterResetSentinel = '__filter_reset__';

Color filterAccentForGroup(String groupId) {
  return switch (groupId) {
    'tmdb' => AppColors.movieAccent,
    'igdb' => AppColors.gameAccent,
    // AniList and MangaBaka are both manga/anime providers — same accent.
    'anilist' => AppColors.animeAccent,
    'mangabaka' => AppColors.animeAccent,
    'vndb' => AppColors.visualNovelAccent,
    // All book providers share the book accent — ComicVine volumes are
    // MediaType.book too, so comics aren't split out by colour.
    'openlibrary' => AppColors.bookAccent,
    'fantlab' => AppColors.bookAccent,
    'googlebooks' => AppColors.bookAccent,
    'comicvine' => AppColors.bookAccent,
    _ => AppColors.brand,
  };
}
