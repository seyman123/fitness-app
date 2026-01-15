import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_entry_model.dart';

abstract class WaterLocalDataSource {
  Future<void> cacheWaterEntries(List<WaterEntryModel> entries);
  Future<List<WaterEntryModel>?> getCachedWaterEntries();
  Future<void> clearCache();
}

class WaterLocalDataSourceImpl implements WaterLocalDataSource {
  static const String _cacheKey = 'cached_water_entries';

  final SharedPreferences sharedPreferences;

  WaterLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheWaterEntries(List<WaterEntryModel> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    await sharedPreferences.setString(_cacheKey, json.encode(jsonList));
  }

  @override
  Future<List<WaterEntryModel>?> getCachedWaterEntries() async {
    final jsonString = sharedPreferences.getString(_cacheKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => WaterEntryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cacheKey);
  }
}
