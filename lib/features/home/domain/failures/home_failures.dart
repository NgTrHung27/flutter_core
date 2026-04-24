import 'package:equatable/equatable.dart';

sealed class HomeFailure extends Equatable {
  @override
  List<Object?> get props => [];
}

class HomeCacheFailure extends HomeFailure {
  final String? message;
  HomeCacheFailure([this.message]);
  @override
  List<Object?> get props => [message];
}

class HomeNetworkFailure extends HomeFailure {
  final String? message;
  HomeNetworkFailure([this.message]);
  @override
  List<Object?> get props => [message];
}
