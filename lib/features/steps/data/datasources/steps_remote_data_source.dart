import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../models/step_entry_model.dart';

abstract class StepsRemoteDataSource {
  Future<StepEntryModel> addSteps({
    required int steps,
    DateTime? date,
  });

  Future<int> getTodaySteps();

  Future<List<StepEntryModel>> getStepsHistory({
    DateTime? startDate,
    DateTime? endDate,
  });
}

class StepsRemoteDataSourceImpl implements StepsRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  StepsRemoteDataSourceImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  String? _getToken() {
    return sharedPreferences.getString('auth_token');
  }

  @override
  Future<StepEntryModel> addSteps({
    required int steps,
    DateTime? date,
  }) async {
    final token = _getToken();
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final Map<String, dynamic> body = {
      'steps': steps,
    };

    if (date != null) {
      body['date'] = date.toIso8601String();
    }

    final data = await apiClient.post(
      ApiConfig.steps,
      body: body,
      token: token,
    );

    return StepEntryModel.fromJson(data);
  }

  @override
  Future<int> getTodaySteps() async {
    final token = _getToken();
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    final data = await apiClient.get(
      '${ApiConfig.steps}/today',
      token: token,
    );

    return data['steps'] as int;
  }

  @override
  Future<List<StepEntryModel>> getStepsHistory({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = _getToken();
    if (token == null) {
      throw Exception('Token bulunamadı');
    }

    String endpoint = ApiConfig.steps;
    final queryParams = <String, String>{};

    if (startDate != null) {
      queryParams['startDate'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['endDate'] = endDate.toIso8601String();
    }

    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      endpoint = '$endpoint?$queryString';
    }

    final data = await apiClient.get(endpoint, token: token);

    final entries = (data['entries'] as List)
        .map((json) => StepEntryModel.fromJson(json))
        .toList();

    return entries;
  }
}
