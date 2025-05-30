import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visitstracker/core/network/api_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:visitstracker/core/services/snackbar_service.dart';

class CacheService {
  final ApiClient _apiClient;
  late final SharedPreferences _prefs;
  static const String _queueKey = 'operation_queue';
  static const String _lastSyncKey = 'last_sync';
  final Connectivity _connectivity = Connectivity();
  bool _isMonitoring = false;
  BuildContext? _context;
  List<Map<String, dynamic>> _notificationQueue = [];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  CacheService(this._apiClient);

  void setContext(BuildContext context) {
    _context = context;
    _processNotificationQueue();
  }

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;
    _isMonitoring = true;

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        developer.log('Internet connection available, syncing queue...');
        _showNotification('Syncing offline changes...', SnackBarType.info);
        forceSync();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _isMonitoring = false;
  }

  void _showNotification(String message, SnackBarType type) {
    if (_context != null) {
      try {
        SnackbarService.show(
          context: _context!,
          message: message,
          type: type,
        );
      } catch (e) {
        developer.log('Error showing snackbar: $e');
        // Queue the notification for later
        _notificationQueue.add({
          'message': message,
          'type': type,
        });
      }
    } else {
      // Queue the notification for when context is available
      _notificationQueue.add({
        'message': message,
        'type': type,
      });
    }
  }

  void _processNotificationQueue() {
    if (_context == null) return;

    for (final notification in _notificationQueue) {
      try {
        SnackbarService.show(
          context: _context!,
          message: notification['message'],
          type: notification['type'],
        );
      } catch (e) {
        developer.log('Error showing queued snackbar: $e');
      }
    }
    _notificationQueue.clear();
  }

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> cacheData(String key, dynamic data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  dynamic getCachedData(String key) {
    final data = _prefs.getString(key);
    if (data == null) return null;
    return jsonDecode(data);
  }

  Future<void> queueOperation({
    required String type,
    required String endpoint,
    required Map<String, dynamic> data,
    String? id,
  }) async {
    final queue = _getQueue();
    queue.add({
      'type': type,
      'endpoint': endpoint,
      'data': data,
      'id': id,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _prefs.setString(_queueKey, jsonEncode(queue));
  }

  List<Map<String, dynamic>> _getQueue() {
    final queueData = _prefs.getString(_queueKey);
    if (queueData == null) return [];
    return List<Map<String, dynamic>>.from(jsonDecode(queueData));
  }

  Future<void> processQueue() async {
    final queue = _getQueue();
    if (queue.isEmpty) return;

    _showNotification('Processing offline changes...', SnackBarType.info);
    int successCount = 0;
    int failureCount = 0;

    for (final operation in queue) {
      try {
        switch (operation['type']) {
          case 'create':
            await _apiClient.post(operation['endpoint'], operation['data']);
            successCount++;
            break;
          case 'update':
            await _apiClient.patch(
              '${operation['endpoint']}?id=eq.${operation['id']}',
              operation['data'],
            );
            successCount++;
            break;
          case 'delete':
            await _apiClient.delete(
              '${operation['endpoint']}?id=eq.${operation['id']}',
            );
            successCount++;
            break;
        }
      } catch (e) {
        developer.log('Error processing queued operation: $e');
        failureCount++;
        // Keep the operation in the queue if it fails
        continue;
      }
    }

    // Clear the queue after successful processing
    await _prefs.remove(_queueKey);
    await _updateLastSync();

    if (successCount > 0) {
      _showNotification(
        'Successfully synced $successCount changes',
        SnackBarType.success,
      );
    }
    if (failureCount > 0) {
      _showNotification(
        'Failed to sync $failureCount changes',
        SnackBarType.error,
      );
    }
  }

  bool needsSync() {
    final lastSync = _prefs.getString(_lastSyncKey);
    if (lastSync == null) return true;

    final lastSyncTime = DateTime.parse(lastSync);
    final now = DateTime.now();
    return now.difference(lastSyncTime).inMinutes >= 5; // Sync every 5 minutes
  }

  Future<void> _updateLastSync() async {
    await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<void> clearCache(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAllCache() async {
    await _prefs.clear();
  }

  Future<void> forceSync() async {
    final queue = _getQueue();
    if (queue.isEmpty) {
      _showNotification('No offline changes to sync', SnackBarType.info);
      return;
    }

    try {
      _showNotification('Starting sync process...', SnackBarType.info);
      await processQueue();
      await _updateLastSync();
    } catch (e) {
      developer.log('Error syncing queue: $e');
      _showNotification('Failed to sync offline changes', SnackBarType.error);
    }
  }
}
