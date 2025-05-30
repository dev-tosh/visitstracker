import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:visitstracker/core/config/env_config.dart';

class ApiClient {
  final String baseUrl;
  final String apiKey;
  final http.Client _client;

  ApiClient({
    http.Client? client,
    String? baseUrl,
    String? apiKey,
  })  : _client = client ?? http.Client(),
        baseUrl = baseUrl ?? EnvConfig.supabaseUrl,
        apiKey = apiKey ?? EnvConfig.supabaseKey;

  Map<String, String> get _headers => {
        'apikey': apiKey,
        'Content-Type': 'application/json',
      };

  Future<dynamic> get(String endpoint) async {
    developer.log('GET Request to: $baseUrl$endpoint');
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform GET request: $e');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    developer.log('POST Request to: $baseUrl$endpoint');
    developer.log('Request data: $data');
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }

  Future<dynamic> patch(String endpoint, dynamic data) async {
    developer.log('PATCH Request to: $baseUrl$endpoint');
    developer.log('Request data: $data');
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform PATCH request: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    developer.log('DELETE Request to: $baseUrl$endpoint');
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform DELETE request: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      try {
        return json.decode(response.body);
      } catch (e) {
        developer.log('Error decoding response: $e', error: true);
        return null;
      }
    } else {
      throw Exception(
        'API request failed with status code: ${response.statusCode}\nResponse: ${response.body}',
      );
    }
  }
}
