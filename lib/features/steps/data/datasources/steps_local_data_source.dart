import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/step_entry_model.dart';

abstract class StepsLocalDataSource {
  Future<void> cacheTodaySteps(int steps);
  Future<int?> getCachedTodaySteps();
  Future<void> cacheStepsHistory(List<StepEntryModel> entries);
  Future<List<StepEntryModel>?> getCachedStepsHistory();
}

class StepsLocalDataSourceImpl implements StepsLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _todayStepsKey = 'CACHED_TODAY_STEPS';
  static const String _stepsHistoryKey = 'CACHED_STEPS_HISTORY';

  StepsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheTodaySteps(int steps) async {
    await sharedPreferences.setInt(_todayStepsKey, steps);
  }

  @override
  Future<int?> getCachedTodaySteps() async {
    return sharedPreferences.getInt(_todayStepsKey);
  }

  @override
  Future<void> cacheStepsHistory(List<StepEntryModel> entries) async {
    final jsonList = entries.map((entry) => entry.toJson()).toList();
    await sharedPreferences.setString(_stepsHistoryKey, json.encode(jsonList));
  }

  @override
  Future<List<StepEntryModel>?> getCachedStepsHistory() async {
    final jsonString = sharedPreferences.getString(_stepsHistoryKey);
    if (jsonString == null) return null;

    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((json) => StepEntryModel.fromJson(json)).toList();
  }
}
