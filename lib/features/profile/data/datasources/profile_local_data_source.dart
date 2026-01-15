import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../models/profile_model.dart';

/// Profile local data source
/// Handles profile caching with SharedPreferences
abstract class ProfileLocalDataSource {
  /// Get cached profile
  Future<ProfileModel?> getCachedProfile();

  /// Cache profile data
  Future<void> cacheProfile(ProfileModel profile);

  /// Clear cached profile
  Future<void> clearProfile();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedProfileKey = 'CACHED_PROFILE';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ProfileModel?> getCachedProfile() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedProfileKey);
      if (jsonString == null) return null;

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return ProfileModel.fromJson(jsonMap);
    } catch (e) {
      throw CacheFailure('Önbellekten profil okunamadı: $e');
    }
  }

  @override
  Future<void> cacheProfile(ProfileModel profile) async {
    try {
      final jsonString = json.encode(profile.toJson());
      await sharedPreferences.setString(_cachedProfileKey, jsonString);
    } catch (e) {
      throw CacheFailure('Profil önbelleğe yazılamadı: $e');
    }
  }

  @override
  Future<void> clearProfile() async {
    try {
      await sharedPreferences.remove(_cachedProfileKey);
    } catch (e) {
      throw CacheFailure('Profil önbelleği temizlenemedi: $e');
    }
  }
}
