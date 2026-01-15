import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/steps_repository.dart';
import 'steps_event.dart';
import 'steps_state.dart';

class StepsBloc extends Bloc<StepsEvent, StepsState> {
  final StepsRepository repository;

  StepsBloc({required this.repository}) : super(const StepsInitial()) {
    on<LoadTodaySteps>(_onLoadTodaySteps);
    on<AddSteps>(_onAddSteps);
    on<LoadStepsHistory>(_onLoadStepsHistory);
    on<RefreshSteps>(_onRefreshSteps);
  }

  Future<void> _onLoadTodaySteps(
    LoadTodaySteps event,
    Emitter<StepsState> emit,
  ) async {
    emit(const StepsLoading());

    final result = await repository.getTodaySteps();

    result.fold(
      (failure) => emit(StepsError(failure.message)),
      (steps) => emit(StepsLoaded(todaySteps: steps)),
    );
  }

  Future<void> _onAddSteps(
    AddSteps event,
    Emitter<StepsState> emit,
  ) async {
    final result = await repository.addSteps(
      steps: event.steps,
      date: event.date,
    );

    await result.fold(
      (failure) async => emit(StepsError(failure.message)),
      (entry) async {
        emit(StepsOperationSuccess('Adım kaydı eklendi'));

        // Reload today's steps after adding
        final stepsResult = await repository.getTodaySteps();
        stepsResult.fold(
          (failure) => emit(StepsError(failure.message)),
          (steps) => emit(StepsLoaded(todaySteps: steps)),
        );
      },
    );
  }

  Future<void> _onLoadStepsHistory(
    LoadStepsHistory event,
    Emitter<StepsState> emit,
  ) async {
    final currentState = state;
    final currentSteps = currentState is StepsLoaded ? currentState.todaySteps : 0;

    final result = await repository.getStepsHistory(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(StepsError(failure.message)),
      (history) => emit(StepsLoaded(
        todaySteps: currentSteps,
        history: history,
      )),
    );
  }

  Future<void> _onRefreshSteps(
    RefreshSteps event,
    Emitter<StepsState> emit,
  ) async {
    final result = await repository.getTodaySteps();

    result.fold(
      (failure) => emit(StepsError(failure.message)),
      (steps) => emit(StepsLoaded(todaySteps: steps)),
    );
  }
}
