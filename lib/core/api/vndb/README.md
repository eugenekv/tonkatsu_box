# VNDB API

REST client for the VNDB Kana API (visual novels). No auth required.

- Docs: https://api.vndb.org/kana
- Endpoint: `https://api.vndb.org/kana`

## Layers

| File | Purpose |
|---|---|
| `../vndb_api.dart` | Facade. Entry point for the rest of the code (`vndbApiProvider`). |
| `vndb_types.dart` | `VndbApiException`. |
| `vndb_http_client.dart` | Dio transport: `post` (base URL + endpoint), Dio → `VndbApiException` mapping. |
| `vndb_vn_api.dart` | `/vn` queries: `searchVn`, `browseVn`, `getVnById`, `getVnByIds`. |
| `vndb_tags_api.dart` | `/tag` catalog: `fetchTags`. |

## Key points

- **Query shape.** VNDB filters are nested arrays: `['search', '=', q]`, combined
  with `['and', ...]`; bulk id lookup uses `['or', ['id','=',a], ...]` to issue a
  single request instead of one-per-id.
- **Browse floor.** With no free-text query, `browseVn` adds `votecount >= 10` to
  keep junk entries out of the default view.
- **Fields.** `VndbVnApi._vnFields` is the shared field projection for all `/vn`
  calls; `VndbTag` lives in `shared/models/visual_novel.dart`.
- **Tags.** `fetchTags` returns the top 100 content tags (category `cont`) by
  usage count — surfaced as "genres" in the UI.
