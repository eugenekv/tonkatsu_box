class VndbApiException implements Exception {
  const VndbApiException(this.message, {this.statusCode, this.detail});

  final String message;
  final int? statusCode;
  final String? detail;

  @override
  String toString() => 'VndbApiException: $message (status: $statusCode)';
}
