import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/water_entry_model.dart';
import '../models/water_response_model.dart';

abstract class WaterRemoteDataSource {
  Future<WaterEntryModel> addWaterEntry(int amount);
  Future<WaterResponseModel> getTodayWater();
  Future<WaterResponseModel> getWaterEntries({DateTime? startDate, DateTime? endDate});
  Future<void> deleteWaterEntry(String id);
}

class WaterRemoteDataSourceImpl implements WaterRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  WaterRemoteDataSourceImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  String? _getToken() {
    return sharedPreferences.getString('auth_token');
  }

  @override
  Future<WaterEntryModel> addWaterEntry(int amount) async {
    try {
      final token = _getToken();
      if (token == null) {
        throw ServerFailure('Token bulunamadı');
      }

      final response = await apiClient.post(
        ApiConfig.water,
        body: {'amount': amount},
        token: token,
      );

      return WaterEntryModel.fromJson(response);
    } catch (e) {
      throw ServerFailure('Su kaydı eklenemedi: $e');
    }
  }

  @override
  Future<WaterResponseModel> getTodayWater() async {
    try {
      final token = _getToken();
      if (token == null) {
        throw ServerFailure('Token bulunamadı');
      }

      final response = await apiClient.get(
        '${ApiConfig.water}/today',
        token: token,
      );

      return WaterResponseModel.fromJson(response);
    } catch (e) {
      throw ServerFailure('Günlük su kaydı alınamadı: $e');
    }
  }

  @override
  Future<WaterResponseModel> getWaterEntries({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = _getToken();
      if (token == null) {
        throw ServerFailure('Token bulunamadı');
      }

      final queryParams = <String, String>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await apiClient.get(
        ApiConfig.water,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        token: token,
      );

      return WaterResponseModel.fromJson(response);
    } catch (e) {
      throw ServerFailure('Su kayıtları alınamadı: $e');
    }
  }

  @override
  Future<void> deleteWaterEntry(String id) async {
    try {
      final token = _getToken();
      if (token == null) {
        throw ServerFailure('Token bulunamadı');
      }

      await apiClient.delete(
        '${ApiConfig.water}/$id',
        token: token,
      );
    } catch (e) {
      throw ServerFailure('Su kaydı silinemedi: $e');
    }
  }
}
