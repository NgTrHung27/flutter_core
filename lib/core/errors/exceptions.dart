class ServerException implements Exception {}

class CacheException implements Exception {}

class AuthException implements Exception {}

class EmptyException implements Exception {}

class DuplicateEmailException implements Exception {}

/// Thrown when device has no active internet connection.
class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown when network is present but very slow (2G / E / GPRS level).
class WeakNetworkException implements Exception {
  final int latencyMs;
  const WeakNetworkException(this.latencyMs);

  @override
  String toString() => 'WeakNetworkException: latency ${latencyMs}ms';
}
