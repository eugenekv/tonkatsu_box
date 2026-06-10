// "Similar books" section on a book's detail page. Fantlab only — it is the
// one book provider that exposes a similars endpoint. Mirrors the TMDB
// [RecommendationsSection].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/fantlab_api.dart';
import '../../../core/services/image_cache_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/constants/platform_features.dart';
import '../../../shared/models/book.dart';
import '../../../shared/models/data_source.dart';
import '../../../shared/models/media_type.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_spacing.dart';
import '../../../shared/theme/app_typography.dart';
import '../../../shared/utils/cover_image_id.dart';
import '../../../shared/widgets/media_poster_card.dart';
import '../../../shared/widgets/scrollable_row_with_arrows.dart';
import '../../search/widgets/item_details_sheet.dart';
import '../providers/collections_provider.dart';

/// Cache of similar-works providers keyed by Fantlab work id.
final Map<String, FutureProvider<List<Book>>> _similarProviders =
    <String, FutureProvider<List<Book>>>{};

FutureProvider<List<Book>> _getSimilarProvider(String workId) {
  return _similarProviders.putIfAbsent(
    workId,
    () => FutureProvider<List<Book>>(
      (Ref ref) => ref.watch(fantlabApiProvider).getSimilars(workId),
    ),
  );
}

/// Horizontal row of books similar to the one being viewed, fetched from
/// Fantlab's `/work/{id}/similars`. Hidden while loading fails or returns
/// nothing.
class BookSimilarsSection extends ConsumerWidget {
  const BookSimilarsSection({
    required this.workId,
    this.onAddBook,
    super.key,
  });

  /// Fantlab native work id (`book.nativeId`).
  final String workId;

  /// Adds a tapped similar book to a collection.
  final void Function(Book book)? onAddBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Book>> async =
        ref.watch(_getSimilarProvider(workId));
    final Set<int> ownedIds = <int>{
      ...?ref.watch(collectedBookIdsProvider).valueOrNull?.keys,
    };

    return async.when(
      data: (List<Book> books) {
        if (books.isEmpty) return const SizedBox.shrink();
        return _SimilarRow(
          title: S.of(context).bookSimilarTitle,
          books: books,
          ownedIds: ownedIds,
          onTap: (Book book) => _showBook(context, book),
        );
      },
      loading: () => const _SimilarShimmer(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showBook(BuildContext context, Book book) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) => ItemDetailsSheet.book(
        book,
        onAddToCollection: () => onAddBook?.call(book),
      ),
    );
  }
}

class _SimilarRow extends StatefulWidget {
  const _SimilarRow({
    required this.title,
    required this.books,
    required this.ownedIds,
    required this.onTap,
  });

  final String title;
  final List<Book> books;
  final Set<int> ownedIds;
  final void Function(Book book) onTap;

  @override
  State<_SimilarRow> createState() => _SimilarRowState();
}

class _SimilarRowState extends State<_SimilarRow> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool compact = isCompactScreen(context);
    final double posterWidth = compact ? 100 : 130;
    final double rowHeight = compact ? 185 : 230;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.title,
          style: AppTypography.h3.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: rowHeight,
          child: ScrollableRowWithArrows(
            controller: _scrollController,
            height: rowHeight,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: widget.books.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final Book book = widget.books[index];
                return SizedBox(
                  width: posterWidth,
                  child: MediaPosterCard(
                    variant:
                        compact ? CardVariant.compact : CardVariant.grid,
                    title: book.title,
                    imageUrl: book.coverUrl ?? '',
                    cacheImageType: ImageType.bookCover,
                    cacheImageId: coverImageId(
                      mediaType: MediaType.book,
                      externalId: book.externalIdInt,
                      source: DataSource.fantlab,
                      coverUrl: book.coverUrl,
                    ),
                    year: book.publishYear,
                    apiRating: book.rating,
                    splitRatings: true,
                    isInCollection:
                        widget.ownedIds.contains(book.externalIdInt),
                    placeholderIcon: Icons.menu_book,
                    onTap: () => widget.onTap(book),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SimilarShimmer extends StatelessWidget {
  const _SimilarShimmer();

  @override
  Widget build(BuildContext context) {
    final bool compact = isCompactScreen(context);
    final double posterWidth = compact ? 100 : 130;
    final double rowHeight = compact ? 175 : 220;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 150,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: rowHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (_, _) => SizedBox(
              width: posterWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: posterWidth * 0.7,
                    height: 12,
                    color: AppColors.surfaceLight,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
