# MangaBaka API

REST client for MangaBaka (manga catalog). No auth; rate-limited (429) —
results are cached at the repository / DB layer.

- Endpoint: `https://api.mangabaka.org/v1/`

## Layers

| File | Purpose |
|---|---|
| `../mangabaka_api.dart` | Facade. Entry point for the rest of the code (`mangaBakaApiProvider`). |
| `mangabaka_types.dart` | `MangaBakaApiException`. |
| `mangabaka_http_client.dart` | Dio transport (base URL in `BaseOptions`), `get`, Dio → `MangaBakaApiException` mapping. |
| `mangabaka_manga_api.dart` | `browseManga`, `getById` (`/series`). |
| `mangabaka_tags_api.dart` | `fetchTagCatalog` (`/tags`). |

## Key points

- **Host.** `.dev` is deprecated (works until 2026-08-01); `.org` is current —
  same schema, shared rate limit.
- **Genre encoding.** `browseManga` sends `genre` as a repeated key
  (`genre=a&genre=b`) via `ListFormat.multi`; `multiCompatible` (`genre[]=a`)
  is rejected with a 400. `tag` is comma-joined.
- **No server-side sort.** Results come back in MangaBaka's relevance order.
- **Lenient parsing.** A malformed series / tag row is skipped (parse errors are
  `Error`s, not `Exception`s, so they would otherwise escape the catch); 404 on
  `getById` returns null.
- **Models.** `Manga` (via `Manga.fromMangaBaka`) and `MangaBakaTag` live in
  `shared/models`.
