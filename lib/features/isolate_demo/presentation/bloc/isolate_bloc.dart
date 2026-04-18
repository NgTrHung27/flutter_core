import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_heavy_payload_usecase.dart';
import 'isolate_event.dart';
import 'isolate_state.dart';

class IsolateBloc extends Bloc<IsolateEvent, IsolateState> {
  final GetHeavyPayloadUseCase getHeavyPayloadUseCase;

  IsolateBloc({required this.getHeavyPayloadUseCase}) : super(IsolateInitial()) {
    on<FetchPayloadEvent>((event, emit) async {
      emit(IsolateLoading());
      
      final stopwatch = Stopwatch()..start();
      
      try {
        final data = await getHeavyPayloadUseCase(useIsolate: event.useIsolate);
        stopwatch.stop();
        
        emit(IsolateLoaded(
          data: data,
          timeTakenMs: stopwatch.elapsedMilliseconds,
          usedIsolate: event.useIsolate,
        ));
      } catch (e) {
        stopwatch.stop();
        emit(IsolateError(e.toString()));
      }
    });
  }
}
