import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';


class BiometricService {
  static final LocalAuthentication auth = LocalAuthentication();

  static Future<bool> authenticateUser() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        return false;
      }

      return await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        biometricOnly: true,
      );
    } on PlatformException catch (e) {
      print("Biometric PlatformException: ${e.code}");
      return false;
    } catch (e) {
      print("Biometric error: $e");
      return false;
    }
  }

  static Future<bool> checkAndAuthenticateOnOpen(context) async {
    final prefs = await SharedPreferences.getInstance();
    bool enabled = prefs.getBool("biometric_enabled") ?? false;

    if (!enabled) return true; // If disabled → allow app usage

    bool success = await authenticateUser();
    return success;
  }
}