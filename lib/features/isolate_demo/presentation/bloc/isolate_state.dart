import 'package:equatable/equatable.dart';
import '../../domain/entities/isolate_payload_entity.dart';

abstract class IsolateState extends Equatable {
  const IsolateState();

  @override
  List<Object?> get props => [];
}

class IsolateInitial extends IsolateState {}

class IsolateLoading extends IsolateState {}

class IsolateLoaded extends IsolateState {
  final IsolatePayloadEntity data;
  final int timeTakenMs;
  final bool usedIsolate;

  const IsolateLoaded({
    required this.data,
    required this.timeTakenMs,
    required this.usedIsolate,
  });

  @override
  List<Object?> get props => [data, timeTakenMs, usedIsolate];
}

class IsolateError extends IsolateState {
  final String message;

  const IsolateError(this.message);

  @override
  List<Object?> get props => [message];
}
