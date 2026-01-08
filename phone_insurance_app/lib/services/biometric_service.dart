// lib/services/biometric_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Check if device supports biometric
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      print('Error checking device support: $e');
      return false;
    }
  }

  // Check if biometric is available and enrolled
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      print('Error checking biometrics: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }

  // Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await isDeviceSupported();
      final canCheck = await canCheckBiometrics();
      final availableBiometrics = await getAvailableBiometrics();
      
      return isSupported && canCheck && availableBiometrics.isNotEmpty;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }

  // Authenticate with biometric
  Future<bool> authenticate({
    String reason = 'Gunakan fingerprint untuk login',
  }) async {
    try {
      // Check if biometric is available
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('Biometric not available');
        return false;
      }

      // Authenticate
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep auth dialog until user dismisses
          biometricOnly: true, // Only use biometric, no PIN/pattern
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      print('Error during authentication: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      print('Unknown error during authentication: $e');
      return false;
    }
  }

  // Stop authentication (cancel dialog)
  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();
    } catch (e) {
      print('Error stopping authentication: $e');
    }
  }

  // Get friendly biometric type name
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
      default:
        return 'Biometric';
    }
  }

  // Get icon for biometric type
  String getBiometricIcon(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return '👤';
      case BiometricType.fingerprint:
        return '👆';
      case BiometricType.iris:
        return '👁️';
      default:
        return '🔐';
    }
  }
}
