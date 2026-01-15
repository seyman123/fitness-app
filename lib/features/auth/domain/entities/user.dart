import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, email, name, createdAt];
}
