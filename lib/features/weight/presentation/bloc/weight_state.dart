import 'package:equatable/equatable.dart';
import '../../domain/entities/weight_entry.dart';
import '../../data/models/weight_response_model.dart';

abstract class WeightState extends Equatable {
  const WeightState();

  @override
  List<Object?> get props => [];
}

class WeightInitial extends WeightState {}

class WeightLoading extends WeightState {}

class WeightHistoryLoaded extends WeightState {
  final List<WeightEntry> history;

  const WeightHistoryLoaded(this.history);

  @override
  List<Object?> get props => [history];
}

class WeightStatsLoaded extends WeightState {
  final WeightStatsModel stats;

  const WeightStatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class WeightOperationSuccess extends WeightState {
  final String message;

  const WeightOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WeightError extends WeightState {
  final String message;

  const WeightError(this.message);

  @override
  List<Object?> get props => [message];
}
