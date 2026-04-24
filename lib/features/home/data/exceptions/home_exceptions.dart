class CacheException extends HomeException {
  CacheException([String? message])
      : super(message ?? 'Cache operation failed');
}

class HomeException implements Exception {
  final String message;
  final String? originalError;

  HomeException(this.message, [this.originalError]);

  @override
  String toString() => 'HomeException: $message';
}
