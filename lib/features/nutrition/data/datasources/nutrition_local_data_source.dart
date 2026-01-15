import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nutrition_log_model.dart';

abstract class NutritionLocalDataSource {
  Future<List<NutritionLogModel>> getCachedNutritionLogs();
  Future<void> cacheNutritionLogs(List<NutritionLogModel> logs);
  Future<void> clearCache();
}

class NutritionLocalDataSourceImpl implements NutritionLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cacheKey = 'CACHED_NUTRITION_LOGS';

  NutritionLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<NutritionLogModel>> getCachedNutritionLogs() async {
    final jsonString = sharedPreferences.getString(_cacheKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => NutritionLogModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheNutritionLogs(List<NutritionLogModel> logs) async {
    final jsonString = json.encode(
      logs.map((log) => log.toJson()).toList(),
    );
    await sharedPreferences.setString(_cacheKey, jsonString);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cacheKey);
  }
}
