// lib/services/notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';

class NotificationService {
  // Ganti URL sesuai dengan alamat server Django Anda
  // Gunakan 10.0.2.2 untuk emulator Android, atau IP untuk device fisik
  static const String baseUrl = 'http://192.168.100.4:8000/api/notifications';

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get all notifications
  Future<List<AppNotification>> getNotifications() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/'),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => AppNotification.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  // Get unread notification count
  Future<int> getUnreadCount() async {
    final token = await _getToken();
    if (token == null) {
      print('❌ No token found');
      return 0;
    }

    try {
      print('🔔 Fetching unread count from: $baseUrl/unread_count/');
      final response = await http.get(
        Uri.parse('$baseUrl/unread_count/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final count = data['unread_count'] ?? 0;
        print('✅ Unread count: $count');
        return count;
      } else {
        print('⚠️ API returned status ${response.statusCode}');
        return 0;
      }
    } catch (e) {
      print('❌ Error getting unread count: $e');
      return 0;
    }
  }

  // Mark single notification as read
  Future<bool> markAsRead(String notificationId) async {
    final token = await _getToken();
    if (token == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$notificationId/mark_as_read/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    final token = await _getToken();
    if (token == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/mark_all_as_read/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error marking all notifications as read: $e');
      return false;
    }
  }
}
