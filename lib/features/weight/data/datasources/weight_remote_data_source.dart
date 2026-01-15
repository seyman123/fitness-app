import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/error/exceptions.dart';
import '../models/weight_entry_model.dart';
import '../models/weight_response_model.dart';

abstract class WeightRemoteDataSource {
  Future<WeightEntryModel> createWeightEntry({
    required double weight,
    double? bmi,
    String? notes,
    DateTime? date,
  });
  Future<List<WeightEntryModel>> getWeightHistory({int? limit, DateTime? startDate, DateTime? endDate});
  Future<WeightStatsModel> getWeightStats({int days});
  Future<void> deleteWeightEntry(String id);
}

class WeightRemoteDataSourceImpl implements WeightRemoteDataSource {
  final ApiClient client;

  WeightRemoteDataSourceImpl({required this.client});

  @override
  Future<WeightEntryModel> createWeightEntry({
    required double weight,
    double? bmi,
    String? notes,
    DateTime? date,
  }) async {
    try {
      // ApiClient içindeki SharedPreferences'tan token al
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await client.post(
        '/weight',  // baseUrl zaten ApiClient'ta ekleniyor
        body: {
          'weight': weight,
          if (bmi != null) 'bmi': bmi,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (date != null) 'date': date.toIso8601String(),
        },
        token: token,
      );

      return WeightEntryModel.fromJson(response['entry']);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<WeightEntryModel>> getWeightHistory({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await client.get(
        '/weight',  // baseUrl zaten ApiClient'ta ekleniyor
        queryParameters: queryParams,
        token: token,
      );

      final responseModel = WeightResponseModel.fromJson(response);
      return responseModel.history;
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<WeightStatsModel> getWeightStats({int days = 30}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await client.get(
        '/weight/stats',
        queryParameters: {'days': days.toString()},
        token: token,
      );

      return WeightStatsModel.fromJson(response);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteWeightEntry(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      await client.delete(
        '/weight/$id',
        token: token,
      );
    } catch (e) {
      throw ServerException();
    }
  }
}
