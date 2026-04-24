import 'package:equatable/equatable.dart';

sealed class IsolateFailure extends Equatable {
  @override
  List<Object?> get props => [];
}

class IsolateServerFailure extends IsolateFailure {
  final String? message;
  IsolateServerFailure([this.message]);
  @override
  List<Object?> get props => [message];
}

class IsolateParseFailure extends IsolateFailure {
  final String? message;
  IsolateParseFailure([this.message]);
  @override
  List<Object?> get props => [message];
}

class IsolateTimeoutFailure extends IsolateFailure {
  final String? message;
  IsolateTimeoutFailure([this.message]);
  @override
  List<Object?> get props => [message];
}
