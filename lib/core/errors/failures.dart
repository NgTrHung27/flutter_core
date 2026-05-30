import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {}

class CacheFailure extends Failure {}

class EmptyFailure extends Failure {}

class CredentialFailure extends Failure {}

class DuplicateEmailFailure extends Failure {}

class PasswordNotMatchFailure extends Failure {}

class InvalidEmailFailure extends Failure {}

class InvalidPasswordFailure extends Failure {}

/// Thrown when the device has no active internet connection.
class NetworkFailure extends Failure {
  final String? message;
  NetworkFailure([this.message]);

  @override
  List<Object> get props => [?message];
}

/// Thrown when the connection is present but extremely slow (2G / E / GPRS).
class WeakNetworkFailure extends Failure {
  final int latencyMs;
  WeakNetworkFailure(this.latencyMs);

  @override
  List<Object> get props => [latencyMs];
}
