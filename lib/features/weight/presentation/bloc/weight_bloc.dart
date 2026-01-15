import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/weight_repository.dart';
import 'weight_event.dart';
import 'weight_state.dart';

class WeightBloc extends Bloc<WeightEvent, WeightState> {
  final WeightRepository repository;

  WeightBloc({required this.repository}) : super(WeightInitial()) {
    on<LoadWeightHistory>(_onLoadWeightHistory);
    on<LoadWeightStats>(_onLoadWeightStats);
    on<AddWeightEntry>(_onAddWeightEntry);
    on<DeleteWeightEntry>(_onDeleteWeightEntry);
    on<RefreshWeight>(_onRefreshWeight);
  }

  Future<void> _onLoadWeightHistory(
    LoadWeightHistory event,
    Emitter<WeightState> emit,
  ) async {
    emit(WeightLoading());

    final result = await repository.getWeightHistory(
      limit: event.limit,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(const WeightError('Kilo geçmişi yüklenemedi')),
      (history) => emit(WeightHistoryLoaded(history)),
    );
  }

  Future<void> _onLoadWeightStats(
    LoadWeightStats event,
    Emitter<WeightState> emit,
  ) async {
    emit(WeightLoading());

    final result = await repository.getWeightStats(days: event.days);

    result.fold(
      (failure) => emit(const WeightError('İstatistikler yüklenemedi')),
      (stats) => emit(WeightStatsLoaded(stats)),
    );
  }

  Future<void> _onAddWeightEntry(
    AddWeightEntry event,
    Emitter<WeightState> emit,
  ) async {
    final result = await repository.createWeightEntry(
      weight: event.weight,
      bmi: event.bmi,
      notes: event.notes,
      date: event.date,
    );

    result.fold(
      (failure) => emit(const WeightError('Kilo kaydı eklenemedi')),
      (_) => emit(const WeightOperationSuccess('Kilo kaydı eklendi')),
    );
  }

  Future<void> _onDeleteWeightEntry(
    DeleteWeightEntry event,
    Emitter<WeightState> emit,
  ) async {
    final result = await repository.deleteWeightEntry(event.id);

    result.fold(
      (failure) => emit(const WeightError('Kilo kaydı silinemedi')),
      (_) => emit(const WeightOperationSuccess('Kilo kaydı silindi')),
    );
  }

  Future<void> _onRefreshWeight(
    RefreshWeight event,
    Emitter<WeightState> emit,
  ) async {
    add(const LoadWeightHistory());
  }
}
