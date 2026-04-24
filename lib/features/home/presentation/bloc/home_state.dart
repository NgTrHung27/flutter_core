import 'package:equatable/equatable.dart';
import '../../domain/entities/home_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeEntity homeData;
  final List<DemoItem> demos;

  const HomeLoaded({
    required this.homeData,
    required this.demos,
  });

  @override
  List<Object?> get props => [homeData, demos];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
