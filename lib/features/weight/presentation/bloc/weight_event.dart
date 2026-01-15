import 'package:equatable/equatable.dart';

abstract class WeightEvent extends Equatable {
  const WeightEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeightHistory extends WeightEvent {
  final int? limit;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadWeightHistory({this.limit, this.startDate, this.endDate});

  @override
  List<Object?> get props => [limit, startDate, endDate];
}

class LoadWeightStats extends WeightEvent {
  final int days;

  const LoadWeightStats({this.days = 30});

  @override
  List<Object?> get props => [days];
}

class AddWeightEntry extends WeightEvent {
  final double weight;
  final double? bmi;
  final String? notes;
  final DateTime? date;

  const AddWeightEntry({
    required this.weight,
    this.bmi,
    this.notes,
    this.date,
  });

  @override
  List<Object?> get props => [weight, bmi, notes, date];
}

class DeleteWeightEntry extends WeightEvent {
  final String id;

  const DeleteWeightEntry(this.id);

  @override
  List<Object?> get props => [id];
}

class RefreshWeight extends WeightEvent {
  const RefreshWeight();
}
