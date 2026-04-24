import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/failures/isolate_failures.dart';
import '../../domain/usecases/get_heavy_payload_usecase.dart';
import 'isolate_event.dart';
import 'isolate_state.dart';

class IsolateBloc extends Bloc<IsolateEvent, IsolateState> {
  final GetHeavyPayloadUseCase getHeavyPayloadUseCase;

  IsolateBloc({required this.getHeavyPayloadUseCase}) : super(IsolateInitial()) {
    on<FetchPayloadEvent>((event, emit) async {
      emit(IsolateLoading());

      final stopwatch = Stopwatch()..start();

      final result = await getHeavyPayloadUseCase(useIsolate: event.useIsolate);

      stopwatch.stop();

      result.fold(
        (failure) => emit(IsolateError(mapIsolateFailureToMessage(failure))),
        (data) => emit(IsolateLoaded(
          data: data,
          timeTakenMs: stopwatch.elapsedMilliseconds,
          usedIsolate: event.useIsolate,
        )),
      );
    });
  }
}

String mapIsolateFailureToMessage(IsolateFailure failure) {
  switch (failure) {
    case IsolateServerFailure _:
      return 'Server error: ${failure.message ?? "Unable to fetch data"}';
    case IsolateParseFailure _:
      return 'Data parsing error: ${failure.message ?? "Invalid response format"}';
    case IsolateTimeoutFailure _:
      return 'Request timed out: ${failure.message ?? "Please try again"}';
  }
}
