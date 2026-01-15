import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/workout_log_model.dart';
import '../models/workout_model.dart';

abstract class WorkoutRemoteDataSource {
  Future<List<WorkoutModel>> getWorkouts();
  Future<WorkoutModel> getWorkoutById(String id);
  Future<WorkoutModel> createWorkout(WorkoutModel workout);
  Future<WorkoutModel> updateWorkout(String id, WorkoutModel workout);
  Future<void> deleteWorkout(String id);
  Future<List<WorkoutLogModel>> getWorkoutLogs({
    String? workoutId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Map<String, dynamic>> getTodayWorkoutLogs();
  Future<WorkoutLogModel> createWorkoutLog(WorkoutLogModel log);
  Future<void> deleteWorkoutLog(String id);
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  WorkoutRemoteDataSourceImpl({
    required this.apiClient,
    required this.sharedPreferences,
  });

  String? _getToken() {
    return sharedPreferences.getString('auth_token');
  }

  @override
  Future<List<WorkoutModel>> getWorkouts() async {
    try {
      print('=== GET WORKOUTS DATA SOURCE ===');
      final token = _getToken();
      print('Token retrieved: ${token != null ? "YES" : "NO"}');
      if (token == null) {
        print('ERROR: No token found');
        throw ServerException();
      }

      print('Calling API: GET /workouts');
      final data = await apiClient.get('/workouts', token: token);
      print('API Response received');
      print('Workouts count: ${(data['workouts'] as List).length}');
      
      final workoutsList = data['workouts'] as List<dynamic>;
      final workouts = workoutsList
          .map((json) => WorkoutModel.fromJson(json as Map<String, dynamic>))
          .toList();
      print('Parsed ${workouts.length} workouts successfully');
      return workouts;
    } catch (e, stackTrace) {
      print('ERROR in getWorkouts: $e');
      print('Stack trace: $stackTrace');
      throw ServerException();
    }
  }

  @override
  Future<WorkoutModel> getWorkoutById(String id) async {
    try {
      final token = _getToken();
      if (token == null) throw ServerException();

      final data = await apiClient.get('/workouts/$id', token: token);
      return WorkoutModel.fromJson(data);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<WorkoutModel> createWorkout(WorkoutModel workout) async {
    try {
      print('=== CREATE WORKOUT DATA SOURCE ===');
      final token = await _getToken();
      print('Token retrieved: ${token != null ? "YES" : "NO"}');
      if (token == null) {
        print('ERROR: No token found');
        throw ServerException();
      }

      final workoutJson = workout.toJson();
      print('Workout JSON to send: $workoutJson');

      print('Calling API: POST /workouts');
      final data = await apiClient.post(
        '/workouts',
        body: workoutJson,
        token: token,
      );
      print('API Response: $data');
      return WorkoutModel.fromJson(data['workout'] as Map<String, dynamic>);
    } catch (e, stackTrace) {
      print('ERROR in createWorkout: $e');
      print('Stack trace: $stackTrace');
      throw ServerException();
    }
  }

  @override
  Future<WorkoutModel> updateWorkout(String id, WorkoutModel workout) async {
    try {
      final token = _getToken();
      if (token == null) throw ServerException();

      final data = await apiClient.put(
        '/workouts/$id',
        body: workout.toJson(),
        token: token,
      );
      return WorkoutModel.fromJson(data['workout'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    try {
      final token = _getToken();
      if (token == null) throw ServerException();

      await apiClient.delete('/workouts/$id', token: token);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<WorkoutLogModel>> getWorkoutLogs({
    String? workoutId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final token = _getToken();
      if (token == null) throw ServerException();

      final queryParams = <String, String>{};
      if (workoutId != null) queryParams['workoutId'] = workoutId;
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final data = await apiClient.get(
        '/workouts/logs/all',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        token: token,
      );

      final logsList = data['logs'] as List<dynamic>;
      return logsList
          .map((json) => WorkoutLogModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<Map<String, dynamic>> getTodayWorkoutLogs() async {
    try {
      final token = _getToken();
      if (token == null) throw ServerException();

      final data = await apiClient.get(
        '/workouts/logs/today',
        token: token,
      );

      return {
        'totalDuration': data['totalDuration'] as int,
        'count': data['count'] as int,
      };
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<WorkoutLogModel> createWorkoutLog(WorkoutLogModel log) async {
    try {
      final token = _getToken();
      if (token == null) throw ServerException();

      final data = await apiClient.post(
        '/workouts/logs',
        body: log.toJson(),
        token: token,
      );
      return WorkoutLogModel.fromJson(data['log'] as Map<String, dynamic>);
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<void> deleteWorkoutLog(String id) async {
    try {
      final token = _getToken();
      if (token == null) throw ServerException();

      await apiClient.delete('/workouts/logs/$id', token: token);
    } catch (e) {
      throw ServerException();
    }
  }
}
