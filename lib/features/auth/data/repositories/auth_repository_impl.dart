import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await remoteDataSource.register(
        email: email,
        password: password,
        name: name,
      );

      // Token ve kullanıcıyı cache'le
      await localDataSource.cacheToken(response.token);
      await localDataSource.cacheUser(response.user);

      return Right(response.user.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('[DEBUG] Login başlatıldı: $email');

      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      print('[DEBUG] Login response alındı: ${response.user.email}');
      print('[DEBUG] Token: ${response.token.substring(0, 20)}...');

      // Token ve kullanıcıyı cache'le
      await localDataSource.cacheToken(response.token);
      await localDataSource.cacheUser(response.user);

      print('[DEBUG] Token ve user cache\'lendi');

      return Right(response.user.toEntity());
    } catch (e) {
      print('[DEBUG] Login HATASI: $e');
      print('[DEBUG] Hata tipi: ${e.runtimeType}');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      // Önce cache'den token'ı al
      final token = await localDataSource.getCachedToken();
      if (token == null) {
        return Left(AuthenticationFailure('Token bulunamadı'));
      }

      // Cache'den kullanıcıyı al
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      // Cache'de yoksa API'den çek
      final user = await remoteDataSource.getCurrentUser(token);
      await localDataSource.cacheUser(user);

      return Right(user.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearToken();
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Çıkış yapılırken hata oluştu'));
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getCachedToken();
    return token != null;
  }

  Failure _handleError(dynamic error) {
    if (error.toString().contains('401')) {
      return AuthenticationFailure('Kimlik doğrulama hatası');
    } else if (error.toString().contains('400')) {
      return ValidationFailure('Geçersiz bilgiler');
    } else if (error.toString().contains('Network')) {
      return NetworkFailure('İnternet bağlantısı yok');
    } else {
      return ServerFailure('Sunucu hatası: ${error.toString()}');
    }
  }
}
