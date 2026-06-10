/// Error from the Fantlab API. [detail] is a redacted, copyable debug string
/// (request + status + body) consumed by `extractApiError`.
class FantlabApiException implements Exception {
  const FantlabApiException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final String? detail;

  @override
  String toString() => 'FantlabApiException: $message (status: $statusCode)';
}
