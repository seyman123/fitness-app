import 'package:equatable/equatable.dart';

abstract class WaterEvent extends Equatable {
  const WaterEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodayWater extends WaterEvent {
  const LoadTodayWater();
}

class AddWaterEntry extends WaterEvent {
  final int amount;

  const AddWaterEntry(this.amount);

  @override
  List<Object?> get props => [amount];
}

class DeleteWaterEntry extends WaterEvent {
  final String id;

  const DeleteWaterEntry(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadWaterHistory extends WaterEvent {
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadWaterHistory({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class RefreshWater extends WaterEvent {
  const RefreshWater();
}
