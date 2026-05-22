# IGDB API

REST-клиент IGDB v4 через Twitch OAuth (Client Credentials).

- Docs: https://api-docs.igdb.com/
- Twitch OAuth: `https://id.twitch.tv/oauth2/token`
- IGDB endpoint: `https://api.igdb.com/v4`

## Слои

| Файл | Назначение |
|---|---|
| `../igdb_api.dart` | Фасад. Точка входа для остального кода (`igdbApiProvider`). |
| `igdb_types.dart` | `TwitchAuthResult`, `IgdbApiException`, `IgdbTokenRefreshedCallback`. |
| `igdb_http_client.dart` | Dio + Twitch OAuth (`getAccessToken`, `validateCredentials`), хранение кредов, auto-refresh на 401, маппинг ошибок Dio → `IgdbApiException`. |
| `igdb_platforms_api.dart` | `fetchPlatforms` (постранично), `fetchPlatformsByIds`. |
| `igdb_games_api.dart` | `searchGames`, `multiSearchGamesByName`, `lookupSteamGames`, `getGameById/ById/Ids`, `getTopGamesByPlatform`, `browseGames`. |
| `igdb_genres_api.dart` | `fetchGenres` для seed справочника. |

## Ключевые моменты

- **OAuth.** Креды хранятся в `IgdbHttpClient`. На 401 один раз пробуется `_tryRefreshToken` (`client_credentials` grant), guard'нутый `_isRefreshing` — параллельные 401 не штормят токен. Свежий токен пробрасывается наружу через `onTokenRefreshed`, чтобы caller успел сохранить в `SharedPreferences`.
- **Лимит multiquery.** IGDB режет `/multiquery` на 10 sub-queries за запрос — `IgdbGamesApi.maxMultiQueryBatch = 10`. Caller отвечает за батчинг.
- **Лимит обычных запросов.** IGDB cap 500 записей на запрос; `fetchPlatforms` и `getGamesByIds` режут на батчи сами.
- **DSL запросов.** IGDB не GraphQL: строится строка вида `fields …; where …; search "…"; limit N; offset M;`. Порядок секций имеет значение, поиск идёт последним.
- **NULL в unique индексах.** Не относится напрямую к IGDB, но связанная миграция v37 использует `COALESCE(platform_id, -1)` чтобы два NULL не считались разными — см. `migration_v37.dart`.
- **Steam lookup.** Двухшаговый: `external_games` (`external_game_source = 1`) переводит Steam appId → IGDB game id, потом `getGamesByIds` догружает full payload (deduped).
