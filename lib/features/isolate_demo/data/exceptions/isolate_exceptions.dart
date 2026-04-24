class IsolateException implements Exception {
  final String message;
  final String? originalError;

  IsolateException(this.message, [this.originalError]);

  @override
  String toString() => 'IsolateException: $message';
}

class IsolateParseException extends IsolateException {
  IsolateParseException([String? message])
      : super(message ?? 'Failed to parse payload data');
}

class IsolateTimeoutException extends IsolateException {
  IsolateTimeoutException([String? message])
      : super(message ?? 'Operation timed out');
}
