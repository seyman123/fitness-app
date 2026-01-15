import 'package:equatable/equatable.dart';
import 'user_model.dart';

class AuthResponseModel extends Equatable {
  final String message;
  final UserModel user;
  final String token;

  const AuthResponseModel({
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
      'token': token,
    };
  }

  @override
  List<Object?> get props => [message, user, token];
}
