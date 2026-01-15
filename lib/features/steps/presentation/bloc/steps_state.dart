import 'package:equatable/equatable.dart';
import '../../domain/entities/step_entry.dart';

abstract class StepsState extends Equatable {
  const StepsState();

  @override
  List<Object?> get props => [];
}

class StepsInitial extends StepsState {
  const StepsInitial();
}

class StepsLoading extends StepsState {
  const StepsLoading();
}

class StepsLoaded extends StepsState {
  final int todaySteps;
  final List<StepEntry> history;

  const StepsLoaded({
    required this.todaySteps,
    this.history = const [],
  });

  @override
  List<Object?> get props => [todaySteps, history];

  StepsLoaded copyWith({
    int? todaySteps,
    List<StepEntry>? history,
  }) {
    return StepsLoaded(
      todaySteps: todaySteps ?? this.todaySteps,
      history: history ?? this.history,
    );
  }
}

class StepsOperationSuccess extends StepsState {
  final String message;

  const StepsOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StepsError extends StepsState {
  final String message;

  const StepsError(this.message);

  @override
  List<Object?> get props => [message];
}
