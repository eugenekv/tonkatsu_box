import 'package:dio/dio.dart';

import 'ra_http_client.dart';
import 'ra_types.dart';

/// Game-scoped RetroAchievements calls: per-game progress and console lists.
class RaGamesApi {
  RaGamesApi(this._client);

  final RaHttpClient _client;

  /// Lightweight summary call (`a=0`): metadata + counters, no Achievements
  /// array. Use when opening the game card before user expands the list.
  Future<Map<String, dynamic>> getGameSummary(
    String targetUser,
    int raGameId,
  ) async {
    _client.ensureCredentials();
    try {
      final Response<dynamic> response = await _client.get(
        '/API_GetGameInfoAndUserProgress.php',
        queryParameters: <String, String>{
          'u': targetUser,
          'g': raGameId.toString(),
          'a': '0',
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _client.handleError(e, 'getGameSummary');
    }
  }

  /// Full call (`a=1`): same shape as the summary plus the full Achievements
  /// map with unlock timestamps. Lazy-fetched when the user expands the card.
  Future<Map<String, dynamic>> getGameInfoAndUserProgress(
    String targetUser,
    int raGameId,
  ) async {
    _client.ensureCredentials();
    try {
      final Response<dynamic> response = await _client.get(
        '/API_GetGameInfoAndUserProgress.php',
        queryParameters: <String, String>{
          'u': targetUser,
          'g': raGameId.toString(),
          'a': '1',
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _client.handleError(e, 'getGameInfoAndUserProgress');
    }
  }

  Future<List<RaGameListEntry>> getGameList(int consoleId) async {
    _client.ensureCredentials();
    try {
      final Response<dynamic> response = await _client.get(
        '/API_GetGameList.php',
        queryParameters: <String, String>{'i': consoleId.toString()},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((dynamic item) =>
              RaGameListEntry.fromJson(item as Map<String, dynamic>))
          .where((RaGameListEntry g) => g.numAchievements > 0)
          .toList();
    } on DioException catch (e) {
      throw _client.handleError(e, 'getGameList');
    }
  }
}
