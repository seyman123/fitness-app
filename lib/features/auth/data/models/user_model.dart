import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    required this.createdAt,
  });

  // JSON'dan model oluştur
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Model'i JSON'a çevir
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Entity'e dönüştür
  User toEntity() {
    return User(
      id: id,
      email: email,
      name: name,
      createdAt: createdAt,
    );
  }

  // Entity'den oluştur
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      name: user.name,
      createdAt: user.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, createdAt];
}
