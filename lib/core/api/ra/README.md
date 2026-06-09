# RetroAchievements API

REST client for RetroAchievements. Auth is `(username, web API key)` passed as
`z` + `y` query params on every request.

- Docs: https://api-docs.retroachievements.org/
- Endpoint: `https://retroachievements.org/API`

## Layers

| File | Purpose |
|---|---|
| `../ra_api.dart` | Facade. Entry point for the rest of the code (`raApiProvider`). |
| `ra_types.dart` | `RaApiException`, `RaGameListEntry`. |
| `ra_http_client.dart` | Dio transport: credential state, `z`/`y` injected into `get`, `validateCredentials`, `handleError`. |
| `ra_user_api.dart` | `getUserProfile`, `getCompletedGames` (paged), `getUserAwardDates`. |
| `ra_games_api.dart` | `getGameSummary`, `getGameInfoAndUserProgress`, `getGameList`. |

## Key points

- **Auth.** Credentials live in `RaHttpClient` and are injected as `z`/`y` on
  every `get`; `ensureCredentials` throws before any call when they are missing.
  `validateCredentials` checks caller-supplied creds with a raw request.
- **Rate limit.** RA documents 1 req/s; `getCompletedGames` pages 500 entries
  at a time with a 1s gap between pages.
- **Soft failures.** `getUserAwardDates` and `validateCredentials` log and
  return a default (empty map / false) on error — awards and validation are
  nice-to-have, not blockers; the rest map Dio errors to `RaApiException` via
  `handleError`.
- **Game list filter.** `getGameList` drops entries with `numAchievements == 0`.
- **Models.** `RaUserProfile` / `RaGameProgress` live in `shared/models`;
  `RaGameListEntry` is small and lives in `ra_types.dart`.
