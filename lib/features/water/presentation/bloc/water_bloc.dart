import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/water_repository.dart';
import 'water_event.dart';
import 'water_state.dart';

class WaterBloc extends Bloc<WaterEvent, WaterState> {
  final WaterRepository repository;

  WaterBloc({required this.repository}) : super(const WaterInitial()) {
    on<LoadTodayWater>(_onLoadTodayWater);
    on<AddWaterEntry>(_onAddWaterEntry);
    on<DeleteWaterEntry>(_onDeleteWaterEntry);
    on<LoadWaterHistory>(_onLoadWaterHistory);
    on<RefreshWater>(_onRefreshWater);
  }

  Future<void> _onLoadTodayWater(
    LoadTodayWater event,
    Emitter<WaterState> emit,
  ) async {
    emit(const WaterLoading());

    final result = await repository.getTodayWater();

    result.fold(
      (failure) => emit(WaterError(failure.message)),
      (entries) {
        final total = entries.fold<int>(0, (sum, entry) => sum + entry.amount);
        emit(WaterLoaded(entries: entries, totalAmount: total));
      },
    );
  }

  Future<void> _onAddWaterEntry(
    AddWaterEntry event,
    Emitter<WaterState> emit,
  ) async {
    // Show loading
    emit(const WaterLoading());

    final result = await repository.addWaterEntry(event.amount);

    await result.fold(
      (failure) async {
        emit(WaterError(failure.message));
      },
      (entry) async {
        // Show success message
        emit(WaterOperationSuccess('${event.amount}ml su eklendi'));

        // Reload today's water
        final todayResult = await repository.getTodayWater();
        todayResult.fold(
          (failure) => emit(WaterError(failure.message)),
          (entries) {
            final total = entries.fold<int>(0, (sum, e) => sum + e.amount);
            emit(WaterLoaded(entries: entries, totalAmount: total));
          },
        );
      },
    );
  }

  Future<void> _onDeleteWaterEntry(
    DeleteWaterEntry event,
    Emitter<WaterState> emit,
  ) async {
    emit(const WaterLoading());

    final result = await repository.deleteWaterEntry(event.id);

    await result.fold(
      (failure) async {
        emit(WaterError(failure.message));
      },
      (_) async {
        emit(const WaterOperationSuccess('Kayıt silindi'));

        // Reload today's water
        final todayResult = await repository.getTodayWater();
        todayResult.fold(
          (failure) => emit(WaterError(failure.message)),
          (entries) {
            final total = entries.fold<int>(0, (sum, e) => sum + e.amount);
            emit(WaterLoaded(entries: entries, totalAmount: total));
          },
        );
      },
    );
  }

  Future<void> _onLoadWaterHistory(
    LoadWaterHistory event,
    Emitter<WaterState> emit,
  ) async {
    emit(const WaterLoading());

    final result = await repository.getWaterEntries(
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (failure) => emit(WaterError(failure.message)),
      (entries) {
        final total = entries.fold<int>(0, (sum, entry) => sum + entry.amount);
        emit(WaterLoaded(entries: entries, totalAmount: total));
      },
    );
  }

  Future<void> _onRefreshWater(
    RefreshWater event,
    Emitter<WaterState> emit,
  ) async {
    // Reload today's water
    add(const LoadTodayWater());
  }
}
