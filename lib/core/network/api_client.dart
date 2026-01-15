import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _getHeaders({String? token}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    String? token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final uriWithQuery = queryParameters != null
        ? uri.replace(queryParameters: queryParameters)
        : uri;

    try {
      final response = await _client
          .get(
            uriWithQuery,
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    print('=== API POST REQUEST ===');
    print('Full URL: $uri');
    print('Endpoint: $endpoint');
    print('Base URL: ${ApiConfig.baseUrl}');
    print('Body: ${jsonEncode(body)}');
    print('Headers: ${_getHeaders(token: token)}');

    try {
      final response = await _client
          .post(
            uri,
            headers: _getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      print('=== API POST ERROR ===');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client
          .put(
            uri,
            headers: _getHeaders(token: token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? token,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');

    try {
      final response = await _client
          .delete(
            uri,
            headers: _getHeaders(token: token),
          )
          .timeout(const Duration(milliseconds: ApiConfig.connectionTimeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('=== API RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      print('Decoded JSON: $decoded');
      return decoded;
    } else if (response.statusCode == 401) {
      throw Exception('401: Unauthorized');
    } else if (response.statusCode == 400) {
      throw Exception('400: Bad Request - ${response.body}');
    } else {
      throw Exception('${response.statusCode}: ${response.body}');
    }
  }

  void dispose() {
    _client.close();
  }
}
