// "Similar books" section on a book's detail page. Fantlab only — it is the
// one book provider with a native similars endpoint. Renders the shared
// [BookSimilarsCarousel]; mirrors the TMDB [RecommendationsSection].

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/fantlab_api.dart';
import '../../../shared/models/book.dart';
import '../../../shared/widgets/book_carousel.dart';
import '../providers/collections_provider.dart';
import 'book_similars_carousel.dart';

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
      data: (List<Book> books) => books.isEmpty
          ? const SizedBox.shrink()
          : BookSimilarsCarousel(
              books: books,
              ownedIds: ownedIds,
              onAddBook: onAddBook,
            ),
      loading: () => const BookCarouselShimmer(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
