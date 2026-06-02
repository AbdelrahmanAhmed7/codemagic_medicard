import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  SharedPrefHelper._();

  // ====================== SharedPreferences ======================

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> setData(String key, dynamic value) async {
    final prefs = await _getPrefs();
    if (kDebugMode) {
      debugPrint("SharedPrefHelper : setData key=$key value=$value");
    }

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else {
      if (kDebugMode) {
        debugPrint("⚠️ Unsupported type: ${value.runtimeType}");
      }
      throw UnsupportedError('Type ${value.runtimeType} is not supported');
    }
  }

  static Future<String> getString(String key) async {
    final prefs = await _getPrefs();
    if (kDebugMode) debugPrint("SharedPrefHelper : getString key=$key");
    return prefs.getString(key) ?? '';
  }

  static Future<bool> getBool(String key) async {
    final prefs = await _getPrefs();
    if (kDebugMode) debugPrint("SharedPrefHelper : getBool key=$key");
    return prefs.getBool(key) ?? false;
  }

  static Future<int> getInt(String key) async {
    final prefs = await _getPrefs();
    if (kDebugMode) debugPrint("SharedPrefHelper : getInt key=$key");
    return prefs.getInt(key) ?? 0;
  }

  static Future<double> getDouble(String key) async {
    final prefs = await _getPrefs();
    if (kDebugMode) debugPrint("SharedPrefHelper : getDouble key=$key");
    return prefs.getDouble(key) ?? 0.0;
  }

  static Future<void> removeData(String key) async {
    final prefs = await _getPrefs();
    await prefs.remove(key);
  }

  static Future<void> clearAllData() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }

  // ====================== Secure Storage ======================

  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(resetOnError: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ---------------------- Write ----------------------

  static Future<void> setSecuredString(String key, String value) async {
    if (kDebugMode) debugPrint("SecureStorage : set $key");

    try {
      await _secureStorage.write(key: key, value: value);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint("SecureStorage write failed (${e.code}): ${e.message}");
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("SecureStorage unexpected error: $e");
      }
      rethrow;
    }
  }

  // ---------------------- Read ----------------------

  static Future<String> getSecuredString(String key) async {
    if (kDebugMode) debugPrint("SecureStorage : get $key");

    try {
      return await _secureStorage.read(key: key) ?? '';
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint("SecureStorage read failed (${e.code}): ${e.message}");
      }
      rethrow;
    } catch (e) {
      if (kDebugMode) {
        debugPrint("SecureStorage unexpected error: $e");
      }
      rethrow;
    }
  }

  // ---------------------- Clear ----------------------

  static Future<void> clearAllSecuredData() async {
    if (kDebugMode) debugPrint("SecureStorage : cleared all");

    try {
      await _secureStorage.deleteAll();
    } catch (e) {
      if (kDebugMode) {
        debugPrint("SecureStorage clear failed: $e");
      }
      rethrow;
    }
  }
}
