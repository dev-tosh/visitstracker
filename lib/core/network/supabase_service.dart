import 'dart:convert';
import 'package:http/http.dart' as http;

class SupabaseService {
  static const String _baseUrl =
      'https://kqgbftwsodpttpqgqnbh.supabase.co/rest/v1';
  static const String _apiKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZ2JmdHdzb2RwdHRwcWdxbmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5ODk5OTksImV4cCI6MjA2MTU2NTk5OX0.rwJSY4bJaNdB8jDn3YJJu_gKtznzm-dUKQb4OvRtP6c';

  final http.Client _client;

  SupabaseService(this._client);

  Map<String, String> get _headers => {
        'apikey': _apiKey,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  // Customer operations
  Future<List<Map<String, dynamic>>> getCustomers() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/customers'),
      headers: _headers,
    );
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<Map<String, dynamic>> createCustomer(String name) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/customers'),
      headers: _headers,
      body: json.encode({'name': name}),
    );
    return json.decode(response.body)[0];
  }

  Future<Map<String, dynamic>> updateCustomer(int id, String name) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/customers?id=eq.$id'),
      headers: _headers,
      body: json.encode({'name': name}),
    );
    return json.decode(response.body)[0];
  }

  Future<void> deleteCustomer(int id) async {
    await _client.delete(
      Uri.parse('$_baseUrl/customers?id=eq.$id'),
      headers: _headers,
    );
  }

  // Activity operations
  Future<List<Map<String, dynamic>>> getActivities() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/activities'),
      headers: _headers,
    );
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<Map<String, dynamic>> createActivity(String description) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/activities'),
      headers: _headers,
      body: json.encode({'description': description}),
    );
    return json.decode(response.body)[0];
  }

  Future<Map<String, dynamic>> updateActivity(
      int id, String description) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/activities?id=eq.$id'),
      headers: _headers,
      body: json.encode({'description': description}),
    );
    return json.decode(response.body)[0];
  }

  Future<void> deleteActivity(int id) async {
    await _client.delete(
      Uri.parse('$_baseUrl/activities?id=eq.$id'),
      headers: _headers,
    );
  }

  // Visit operations
  Future<List<Map<String, dynamic>>> getVisits() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/visits'),
      headers: _headers,
    );
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<Map<String, dynamic>> createVisit({
    required int customerId,
    required DateTime visitDate,
    required String status,
    required String location,
    String? notes,
    List<String>? activitiesDone,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/visits'),
      headers: _headers,
      body: json.encode({
        'customer_id': customerId,
        'visit_date': visitDate.toIso8601String(),
        'status': status,
        'location': location,
        if (notes != null) 'notes': notes,
        if (activitiesDone != null) 'activities_done': activitiesDone,
      }),
    );
    return json.decode(response.body)[0];
  }

  Future<Map<String, dynamic>> updateVisit({
    required int id,
    int? customerId,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<String>? activitiesDone,
  }) async {
    final response = await _client.patch(
      Uri.parse('$_baseUrl/visits?id=eq.$id'),
      headers: _headers,
      body: json.encode({
        if (customerId != null) 'customer_id': customerId,
        if (visitDate != null) 'visit_date': visitDate.toIso8601String(),
        if (status != null) 'status': status,
        if (location != null) 'location': location,
        if (notes != null) 'notes': notes,
        if (activitiesDone != null) 'activities_done': activitiesDone,
      }),
    );
    return json.decode(response.body)[0];
  }

  Future<void> deleteVisit(int id) async {
    await _client.delete(
      Uri.parse('$_baseUrl/visits?id=eq.$id'),
      headers: _headers,
    );
  }
}
