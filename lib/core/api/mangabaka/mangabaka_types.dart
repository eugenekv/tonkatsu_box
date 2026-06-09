/// Error from the MangaBaka API. [detail] is a redacted, copyable debug
/// string (request + status + body) consumed by `extractApiError`.
class MangaBakaApiException implements Exception {
  const MangaBakaApiException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final String? detail;

  @override
  String toString() => 'MangaBakaApiException: $message (status: $statusCode)';
}
