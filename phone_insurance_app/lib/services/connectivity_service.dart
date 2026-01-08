// lib/services/connectivity_service.dart
// Service to check internet connectivity

import 'dart:async';
import 'dart:io';

class ConnectivityService {
  // Check if device has internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }

  // Try to reach specific server
  static Future<bool> canReachServer(String host) async {
    try {
      final uri = Uri.parse(host);
      final result = await InternetAddress.lookup(uri.host)
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
