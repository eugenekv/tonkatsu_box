# Fantlab API

REST client for Fantlab, a community book catalog with detailed metadata (ratings, awards, series, editions). No auth. API is beta v0.9.

- Docs: https://github.com/FantLab/FantLab-API
- Endpoint: `https://api.fantlab.ru`
- Covers / work pages: `https://fantlab.ru`

## Layers

| File | Purpose |
|---|---|
| `../fantlab_api.dart` | Facade. Entry point for the rest of the code (`fantlabApiProvider`). |
| `fantlab_types.dart` | `FantlabApiException`. |
| `fantlab_http_client.dart` | Dio transport: base URL, User-Agent, Dio → `FantlabApiException` mapping. |
| `fantlab_search_api.dart` | `searchWorks` (`/search-works`) → lightweight `Book`s for the grid. |
| `fantlab_works_api.dart` | `getWork` (`/work/{id}/extended`) → full `Book`; `getSimilars` (`/work/{id}/similars`). |

## Key points

- **Loose typing.** The Perl backend may return numbers as strings (`work_id`, `rating`) and ratings as arrays (`[8.53]`). All `Book.fromFantlab*` parsers coerce tolerantly.
- **Identity.** Works have a native numeric `work_id` (`3104`). `Book` stores it in both `id` and `nativeId`; `externalUrl` is `https://fantlab.ru/work{id}`.
- **Three construction paths.** Search rows come from `/search-works` `matches[]` (`Book.fromFantlabSearchMatch`, lightweight); the detail view loads `/work/{id}/extended` (`Book.fromFantlabWork`, with description / subjects / series / awards / editions); similar-works come from `/work/{id}/similars`, which has its own shape (`Book.fromFantlabSimilar`).
- **Extended is a superset.** `/work/{id}/extended` carries the base work fields *and* the populated `classificatory` / `awards` / `parents` / `editions_blocks` (null on the bare `/work/{id}`), so `getWork` makes a single call.
- **Ratings scale.** Fantlab ratings are already 1–10 — no doubling (unlike OpenLibrary).
- **Search is bare.** `/search-works` takes only `q` / `page` / `onlymatches`: no server-side type / year / language / genre filter or sort. Page size is a fixed 25, capped at 1000 results. Ordering is relevance-only. Non-book matches (reviews, interviews, articles) are dropped in `FantlabSearchApi`; the one filter `FantlabSource` exposes — work type — is applied client-side there by matching `name_eng` (so a narrow type yields sparser pages, which paginate normally). Author search works implicitly: `q` already matches author names. Language / genre would need a per-result `/work/{id}` fetch, so they are not offered.
- **Descriptions** carry BB-codes and HTML/LINK tags — stripped via `stripBbCodes` (`lib/shared/utils/bbcode.dart`).
- **Covers.** `image` is a path fragment (`/images/editions/big/24724?r=…`); the host `https://fantlab.ru` is prefixed in `Book._fantlabCoverUrl`. Search rows build the path from `pic_edition_id`.
