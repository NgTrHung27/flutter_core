import 'package:equatable/equatable.dart';

abstract class IsolateEvent extends Equatable {
  const IsolateEvent();

  @override
  List<Object?> get props => [];
}

class FetchPayloadEvent extends IsolateEvent {
  final bool useIsolate;

  const FetchPayloadEvent({required this.useIsolate});

  @override
  List<Object?> get props => [useIsolate];
}
