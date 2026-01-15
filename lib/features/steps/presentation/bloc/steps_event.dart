import 'package:equatable/equatable.dart';

abstract class StepsEvent extends Equatable {
  const StepsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodaySteps extends StepsEvent {
  const LoadTodaySteps();
}

class AddSteps extends StepsEvent {
  final int steps;
  final DateTime? date;

  const AddSteps({
    required this.steps,
    this.date,
  });

  @override
  List<Object?> get props => [steps, date];
}

class LoadStepsHistory extends StepsEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadStepsHistory({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

class RefreshSteps extends StepsEvent {
  const RefreshSteps();
}
