import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/home_usecases.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;
  final GetAvailableDemosUseCase getAvailableDemosUseCase;
  final LogDemoAccessUseCase logDemoAccessUseCase;

  HomeBloc({
    required this.getHomeDataUseCase,
    required this.getAvailableDemosUseCase,
    required this.logDemoAccessUseCase,
  }) : super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<LoadDemosEvent>(_onLoadDemos);
    on<LogDemoAccessEvent>(_onLogDemoAccess);
    on<RefreshHomeEvent>(_onRefreshHome);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    final homeResult = await getHomeDataUseCase();
    final demosResult = await getAvailableDemosUseCase();

    homeResult.fold(
      (failure) => emit(HomeError(failure.toString())),
      (homeData) {
        demosResult.fold(
          (failure) => emit(HomeError(failure.toString())),
          (demos) => emit(HomeLoaded(homeData: homeData, demos: demos)),
        );
      },
    );
  }

  Future<void> _onLoadDemos(
    LoadDemosEvent event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded) {
      emit(HomeLoading());
    }

    final result = await getAvailableDemosUseCase();

    result.fold(
      (failure) => emit(HomeError(failure.toString())),
      (demos) {
        if (currentState is HomeLoaded) {
          emit(HomeLoaded(homeData: currentState.homeData, demos: demos));
        } else {
          emit(HomeLoaded(
            homeData: currentState is HomeLoaded
                ? currentState.homeData
                : throw UnimplementedError('Need home data first'),
            demos: demos,
          ));
        }
      },
    );
  }

  Future<void> _onLogDemoAccess(
    LogDemoAccessEvent event,
    Emitter<HomeState> emit,
  ) async {
    await logDemoAccessUseCase(event.demoId);
  }

  Future<void> _onRefreshHome(
    RefreshHomeEvent event,
    Emitter<HomeState> emit,
  ) async {
    add(LoadHomeDataEvent());
  }
}
