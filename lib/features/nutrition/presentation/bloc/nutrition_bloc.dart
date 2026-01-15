import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/nutrition_repository.dart';
import 'nutrition_event.dart';
import 'nutrition_state.dart';

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final NutritionRepository repository;

  NutritionBloc({required this.repository}) : super(const NutritionInitial()) {
    on<LoadTodayNutrition>(_onLoadTodayNutrition);
    on<AddNutritionLog>(_onAddNutritionLog);
    on<DeleteNutritionLog>(_onDeleteNutritionLog);
    on<LoadNutritionHistory>(_onLoadNutritionHistory);
    on<RefreshNutrition>(_onRefreshNutrition);
  }

  Future<void> _onLoadTodayNutrition(
    LoadTodayNutrition event,
    Emitter<NutritionState> emit,
  ) async {
    emit(const NutritionLoading());

    final result = await repository.getTodayNutrition();

    result.fold(
      (failure) => emit(NutritionError(failure.message)),
      (data) {
        final logs = data['logs'] as List;
        final totals = data['totals'] as Map<String, double>;
        final count = data['count'] as int;
        final byMealType = data['byMealType'] as Map<String, List>?;

        emit(NutritionLoaded(
          logs: logs.cast(),
          totals: totals,
          count: count,
          byMealType: byMealType?.map((key, value) => MapEntry(key, value.cast())),
        ));
      },
    );
  }

  Future<void> _onAddNutritionLog(
    AddNutritionLog event,
    Emitter<NutritionState> emit,
  ) async {
    emit(const NutritionLoading());

    final result = await repository.addNutritionLog(
      mealType: event.mealType,
      foodName: event.foodName,
      calories: event.calories,
      protein: event.protein,
      carbs: event.carbs,
      fat: event.fat,
    );

    await result.fold(
      (failure) async {
        emit(NutritionError(failure.message));
      },
      (log) async {
        emit(NutritionOperationSuccess('${event.foodName} eklendi'));

        // Reload today's nutrition
        final todayResult = await repository.getTodayNutrition();
        todayResult.fold(
          (failure) => emit(NutritionError(failure.message)),
          (data) {
            final logs = data['logs'] as List;
            final totals = data['totals'] as Map<String, double>;
            final count = data['count'] as int;
            final byMealType = data['byMealType'] as Map<String, List>?;

            emit(NutritionLoaded(
              logs: logs.cast(),
              totals: totals,
              count: count,
              byMealType: byMealType?.map((key, value) => MapEntry(key, value.cast())),
            ));
          },
        );
      },
    );
  }

  Future<void> _onDeleteNutritionLog(
    DeleteNutritionLog event,
    Emitter<NutritionState> emit,
  ) async {
    emit(const NutritionLoading());

    final result = await repository.deleteNutritionLog(event.id);

    await result.fold(
      (failure) async {
        emit(NutritionError(failure.message));
      },
      (_) async {
        emit(const NutritionOperationSuccess('Kayıt silindi'));

        // Reload today's nutrition
        final todayResult = await repository.getTodayNutrition();
        todayResult.fold(
          (failure) => emit(NutritionError(failure.message)),
          (data) {
            final logs = data['logs'] as List;
            final totals = data['totals'] as Map<String, double>;
            final count = data['count'] as int;
            final byMealType = data['byMealType'] as Map<String, List>?;

            emit(NutritionLoaded(
              logs: logs.cast(),
              totals: totals,
              count: count,
              byMealType: byMealType?.map((key, value) => MapEntry(key, value.cast())),
            ));
          },
        );
      },
    );
  }

  Future<void> _onLoadNutritionHistory(
    LoadNutritionHistory event,
    Emitter<NutritionState> emit,
  ) async {
    emit(const NutritionLoading());

    final result = await repository.getNutritionLogs(
      startDate: event.startDate,
      endDate: event.endDate,
      mealType: event.mealType,
    );

    result.fold(
      (failure) => emit(NutritionError(failure.message)),
      (logs) {
        final totals = {
          'calories': logs.fold<double>(0, (sum, log) => sum + log.calories),
          'protein': logs.fold<double>(0, (sum, log) => sum + (log.protein ?? 0)),
          'carbs': logs.fold<double>(0, (sum, log) => sum + (log.carbs ?? 0)),
          'fat': logs.fold<double>(0, (sum, log) => sum + (log.fat ?? 0)),
        };

        emit(NutritionLoaded(
          logs: logs,
          totals: totals,
          count: logs.length,
        ));
      },
    );
  }

  Future<void> _onRefreshNutrition(
    RefreshNutrition event,
    Emitter<NutritionState> emit,
  ) async {
    add(const LoadTodayNutrition());
  }
}
