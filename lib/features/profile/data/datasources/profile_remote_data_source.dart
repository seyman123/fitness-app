import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/profile_model.dart';
import '../models/profile_response_model.dart';

/// Profile remote data source
/// Handles HTTP requests to profile endpoints
abstract class ProfileRemoteDataSource {
  /// Create new profile
  Future<ProfileModel> createProfile({
    required int age,
    required String gender,
    required double height,
    required double weight,
    required double activityLevel,
    double? goalWeight,
    String? goalType,
  });

  /// Get user's profile
  Future<ProfileModel> getProfile();

  /// Update existing profile
  Future<ProfileModel> updateProfile({
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? activityLevel,
    double? goalWeight,
    String? goalType,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  ProfileRemoteDataSourceImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  String? _getToken() {
    return sharedPreferences.getString('auth_token');
  }

  @override
  Future<ProfileModel> createProfile({
    required int age,
    required String gender,
    required double height,
    required double weight,
    required double activityLevel,
    double? goalWeight,
    String? goalType,
  }) async {
    try {
      final body = {
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
        'activityLevel': activityLevel,
        if (goalWeight != null) 'goalWeight': goalWeight,
        if (goalType != null) 'goalType': goalType,
      };

      final token = _getToken();
      if (token == null) {
        throw ServerFailure('Token bulunamadı');
      }

      final response = await apiClient.post(
        ApiConfig.profileEndpoint,
        body: body,
        token: token,
      );

      // Backend returns: { profile: {...}, calculations: {...} }
      final responseModel = ProfileResponseModel.fromJson(response);
      return responseModel.profileWithCalculations;
    } catch (e) {
      throw ServerFailure('Profil oluşturulamadı: $e');
    }
  }

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final token = _getToken();
      if (token == null) {
        throw ServerFailure('Token bulunamadı');
      }

      final response = await apiClient.get(
        ApiConfig.profileEndpoint,
        token: token,
      );

      // Backend returns: { profile: {...}, calculations: {...} }
      final responseModel = ProfileResponseModel.fromJson(response);
      return responseModel.profileWithCalculations;
    } catch (e) {
      // Check if it's 404 (profile not found)
      if (e.toString().contains('404')) {
        throw ServerFailure('Profil bulunamadı');
      }
      throw ServerFailure('Profil bilgileri alınamadı: $e');
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? activityLevel,
    double? goalWeight,
    String? goalType,
  }) async {
    try {
      // Backend requires ALL fields for update (age, gender, height, weight are required)
      // Profile page always sends all fields, so they should never be null
      if (age == null || gender == null || height == null || weight == null || activityLevel == null) {
        throw ServerFailure('Tüm profil bilgileri gerekli');
      }

      final body = {
        'age': age,
        'gender': gender,
        'height': height,
        'weight': weight,
        'activityLevel': activityLevel,
        if (goalWeight != null) 'goalWeight': goalWeight,
        if (goalType != null) 'goalType': goalType,
      };

      final token = _getToken();
      if (token == null) {
        throw ServerFailure('Token bulunamadı');
      }

      final response = await apiClient.put(
        ApiConfig.profileEndpoint,
        body: body,
        token: token,
      );

      // Backend returns: { profile: {...}, calculations: {...} }
      final responseModel = ProfileResponseModel.fromJson(response);
      return responseModel.profileWithCalculations;
    } catch (e) {
      // Extract error message from backend if available
      final errorMsg = e.toString();
      if (errorMsg.contains('400: Bad Request')) {
        // Try to extract the actual validation error
        final match = RegExp(r'"error":"([^"]+)"').firstMatch(errorMsg);
        if (match != null) {
          throw ServerFailure('Validation hatası: ${match.group(1)}');
        }
      }
      throw ServerFailure('Profil güncellenemedi: $e');
    }
  }
}
