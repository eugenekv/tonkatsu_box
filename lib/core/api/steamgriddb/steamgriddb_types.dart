class SteamGridDbApiException implements Exception {
  const SteamGridDbApiException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final String? detail;

  @override
  String toString() =>
      'SteamGridDbApiException: $message (status: $statusCode)';
}
