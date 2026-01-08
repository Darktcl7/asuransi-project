// lib/services/cache_service.dart
// Simple caching service for offline mode support

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _policiesKey = 'cached_policies';
  static const String _userProfileKey = 'cached_user_profile';
  static const String _claimsKey = 'cached_claims';
  static const String _lastSyncKey = 'last_sync_timestamp';

  // Save policies to cache
  static Future<void> cachePolicies(List<dynamic> policies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_policiesKey, jsonEncode(policies));
    await _updateLastSync();
  }

  // Get cached policies
  static Future<List<dynamic>?> getCachedPolicies() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_policiesKey);
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  // Save user profile to cache
  static Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile));
  }

  // Get cached user profile
  static Future<Map<String, dynamic>?> getCachedUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userProfileKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  // Save claims to cache
  static Future<void> cacheClaims(List<dynamic> claims) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claimsKey, jsonEncode(claims));
  }

  // Get cached claims
  static Future<List<dynamic>?> getCachedClaims() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_claimsKey);
    if (data != null) {
      return jsonDecode(data) as List<dynamic>;
    }
    return null;
  }

  // Update last sync timestamp
  static Future<void> _updateLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  // Get last sync time
  static Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  // Check if cache is stale (older than specified hours)
  static Future<bool> isCacheStale({int maxHours = 24}) async {
    final lastSync = await getLastSyncTime();
    if (lastSync == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastSync).inHours;
    return difference >= maxHours;
  }

  // Clear all cache
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_policiesKey);
    await prefs.remove(_userProfileKey);
    await prefs.remove(_claimsKey);
    await prefs.remove(_lastSyncKey);
  }
}
