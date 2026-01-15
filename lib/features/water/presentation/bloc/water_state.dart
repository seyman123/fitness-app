import 'package:equatable/equatable.dart';
import '../../domain/entities/water_entry.dart';

abstract class WaterState extends Equatable {
  const WaterState();

  @override
  List<Object?> get props => [];
}

class WaterInitial extends WaterState {
  const WaterInitial();
}

class WaterLoading extends WaterState {
  const WaterLoading();
}

class WaterLoaded extends WaterState {
  final List<WaterEntry> entries;
  final int totalAmount;

  const WaterLoaded({
    required this.entries,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [entries, totalAmount];
}

class WaterOperationSuccess extends WaterState {
  final String message;

  const WaterOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class WaterError extends WaterState {
  final String message;

  const WaterError(this.message);

  @override
  List<Object?> get props => [message];
}
