import 'dart:developer' as developer;
import 'package:visitstracker/core/network/api_client.dart';
import 'package:visitstracker/core/services/cache_service.dart';

abstract class BaseRepository {
  final ApiClient _apiClient;
  final CacheService _cacheService;
  final String _endpoint;
  final String _cacheKey;

  BaseRepository(
      this._apiClient, this._cacheService, this._endpoint, this._cacheKey);

  Future<List<dynamic>> getAll() async {
    try {
      final response = await _apiClient.get(_endpoint);
      await _cacheService.cacheData(_cacheKey, response);
      return response;
    } catch (e) {
      developer.log('Error fetching data: $e');
      final cachedData = _cacheService.getCachedData(_cacheKey);
      if (cachedData != null) {
        developer.log('Returning cached data');
        return cachedData;
      }
      rethrow;
    }
  }

  Future<dynamic> create(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post(_endpoint, data);
      await syncCache();
      return response;
    } catch (e) {
      developer.log('Error creating data: $e');
      await _cacheService.queueOperation(
        type: 'create',
        endpoint: _endpoint,
        data: data,
      );
      // Return optimistic response
      return {
        ...data,
        'id': DateTime.now().millisecondsSinceEpoch,
        'created_at': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<dynamic> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.patch(
        '$_endpoint?id=eq.$id',
        data,
      );
      await syncCache();
      return response;
    } catch (e) {
      developer.log('Error updating data: $e');
      await _cacheService.queueOperation(
        type: 'update',
        endpoint: _endpoint,
        data: data,
        id: id,
      );
      // Return optimistic response
      return {
        ...data,
        'id': id,
        'updated_at': DateTime.now().toIso8601String(),
      };
    }
  }

  Future<void> delete(String id) async {
    try {
      await _apiClient.delete('$_endpoint?id=eq.$id');
      await syncCache();
    } catch (e) {
      developer.log('Error deleting data: $e');
      await _cacheService.queueOperation(
        type: 'delete',
        endpoint: _endpoint,
        data: {'id': id},
        id: id,
      );
    }
  }

  Future<void> syncCache() async {
    if (_cacheService.needsSync()) {
      await _cacheService.processQueue();
      await getAll(); // Refresh cache after sync
    }
  }
}
