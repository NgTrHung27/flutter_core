import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

class LoadDemosEvent extends HomeEvent {}

class LogDemoAccessEvent extends HomeEvent {
  final String demoId;

  const LogDemoAccessEvent(this.demoId);

  @override
  List<Object?> get props => [demoId];
}

class RefreshHomeEvent extends HomeEvent {}
