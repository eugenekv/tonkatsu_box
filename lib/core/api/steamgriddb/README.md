# SteamGridDB API

REST client for SteamGridDB v2 (game artwork). Bearer token.

- Docs: https://www.steamgriddb.com/api/v2
- Endpoint: `https://www.steamgriddb.com/api/v2`

## Layers

| File | Purpose |
|---|---|
| `../steamgriddb_api.dart` | Facade. Entry point for the rest of the code (`steamGridDbApiProvider`). |
| `steamgriddb_types.dart` | `SteamGridDbApiException`. |
| `steamgriddb_http_client.dart` | Dio transport: API key state, Bearer auth injected into `get`, `validateApiKey`, Dio → `SteamGridDbApiException` mapping. |
| `steamgriddb_games_api.dart` | `searchGames` (`/search/autocomplete`). |
| `steamgriddb_images_api.dart` | `getGrids` / `getHeroes` / `getLogos` / `getIcons`. |

## Key points

- **Auth.** The Bearer token lives in `SteamGridDbHttpClient` and is injected as
  the `Authorization` header on every `get`; `ensureApiKey` throws before any
  call when it is missing. `validateApiKey` checks a caller-supplied key.
- **Search term in the path.** The query is URL-encoded into the path
  (`/search/autocomplete/<term>`), not a query parameter.
- **Models.** `SteamGridDbGame` / `SteamGridDbImage` live in `shared/models`.
