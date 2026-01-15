import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/nutrition_log_model.dart';
import '../models/nutrition_response_model.dart';

abstract class NutritionRemoteDataSource {
  Future<NutritionLogModel> addNutritionLog({
    required String mealType,
    required String foodName,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  });

  Future<NutritionResponseModel> getNutritionLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? mealType,
  });

  Future<NutritionResponseModel> getTodayNutrition();

  Future<void> deleteNutritionLog(String id);

  Future<NutritionLogModel> updateNutritionLog({
    required String id,
    required String mealType,
    required String foodName,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  });
}

class NutritionRemoteDataSourceImpl implements NutritionRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  NutritionRemoteDataSourceImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  String? _getToken() {
    return sharedPreferences.getString('auth_token');
  }

  @override
  Future<NutritionLogModel> addNutritionLog({
    required String mealType,
    required String foodName,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    final token = _getToken();
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final body = {
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
    };

    final response = await apiClient.post(
      ApiConfig.nutrition,
      body: body,
      token: token,
    );

    if (kDebugMode) {
      debugPrint('[Nutrition] POST ${ApiConfig.nutrition} -> ok');
    }

    return NutritionLogModel.fromJson(response);
  }

  @override
  Future<NutritionResponseModel> getNutritionLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? mealType,
  }) async {
    final token = _getToken();
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final queryParams = <String, String>{};
    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }
    if (mealType != null) {
      queryParams['mealType'] = mealType;
    }

    final response = await apiClient.get(
      ApiConfig.nutrition,
      queryParameters: queryParams,
      token: token,
    );

    return NutritionResponseModel.fromJson(response);
  }

  @override
  Future<NutritionResponseModel> getTodayNutrition() async {
    final token = _getToken();
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final response = await apiClient.get(
      '${ApiConfig.nutrition}/today',
      token: token,
    );

    return NutritionResponseModel.fromJson(response);
  }

  @override
  Future<void> deleteNutritionLog(String id) async {
    final token = _getToken();
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    await apiClient.delete(
      '${ApiConfig.nutrition}/$id',
      token: token,
    );
  }

  @override
  Future<NutritionLogModel> updateNutritionLog({
    required String id,
    required String mealType,
    required String foodName,
    required double calories,
    double? protein,
    double? carbs,
    double? fat,
  }) async {
    final token = _getToken();
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final body = {
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
    };

    final response = await apiClient.put(
      '${ApiConfig.nutrition}/$id',
      body: body,
      token: token,
    );

    return NutritionLogModel.fromJson(response);
  }
}
