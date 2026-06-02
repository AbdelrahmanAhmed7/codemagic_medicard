import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

// ─── Result types ─────────────────────────────────────────────────────────────

enum LocationAccessStatus {
  /// Permission granted, GPS on, coordinates available.
  granted,

  /// User denied permission; native dialog can be shown again later.
  denied,

  /// User permanently denied (Android "Don't ask again").
  permanentlyDenied,

  /// App permission granted but device location services (GPS) are off.
  serviceDisabled,

  /// Permission OK but position fetch failed (timeout, error, etc.).
  unavailable,
}

class LocationResult {
  final double? latitude;
  final double? longitude;
  final LocationAccessStatus status;

  const LocationResult({required this.status, this.latitude, this.longitude});

  bool get hasCoordinates => latitude != null && longitude != null;

  factory LocationResult.granted(double lat, double lng) => LocationResult(
        status: LocationAccessStatus.granted,
        latitude: lat,
        longitude: lng,
      );

  factory LocationResult.status(LocationAccessStatus s) =>
      LocationResult(status: s);
}

// ─── LocationService ──────────────────────────────────────────────────────────

/// Centralized location service.
///
/// GPS enabling uses the native Google Play Services resolution dialog
/// (SettingsClient + ResolvableApiException) via a MethodChannel — the user
/// never leaves the app.  No polling, no onResume dependency.
class LocationService {
  static const _channel = MethodChannel('com.khusm.medicard/location');

  static const _positionSettings = LocationSettings(
    accuracy: LocationAccuracy.reduced,
    timeLimit: Duration(seconds: 8),
  );

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Full resolution flow:
  ///   1. Check / request runtime permission.
  ///   2. If GPS is off → invoke native SettingsClient dialog (stays in-app).
  ///   3. Fetch coordinates.
  ///
  /// The API call in the cubit must NOT fire until this Future completes.
  Future<LocationResult> resolveLocation({bool requestIfNeeded = false}) async {
    try {
      // ── Step 1: runtime permission ─────────────────────────────────────────
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        if (!requestIfNeeded) {
          return LocationResult.status(LocationAccessStatus.denied);
        }
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult.status(LocationAccessStatus.denied);
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationResult.status(LocationAccessStatus.permanentlyDenied);
      }

      if (!_isGranted(permission)) {
        return LocationResult.status(LocationAccessStatus.denied);
      }

      // ── Step 2: GPS service ────────────────────────────────────────────────
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Show the native in-app GPS enable dialog via SettingsClient.
        final gpsResult = await _requestGpsEnable();
        if (gpsResult != _GpsEnableResult.enabled) {
          // User rejected or an error occurred — fallback without coordinates.
          return LocationResult.status(LocationAccessStatus.serviceDisabled);
        }
        // GPS is now on — fall through to coordinate fetch.
      }

      // ── Step 3: coordinates ────────────────────────────────────────────────
      return await _fetchCoordinates();
    } catch (e) {
      if (kDebugMode) debugPrint('📍 LocationService.resolveLocation error: $e');
      return LocationResult.status(LocationAccessStatus.unavailable);
    }
  }

  /// Silent check — no permission dialog, no GPS dialog.
  /// Used for pull-to-refresh.
  Future<LocationResult> tryGetLocationSilently() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (!_isGranted(permission)) {
        return LocationResult.status(
          permission == LocationPermission.deniedForever
              ? LocationAccessStatus.permanentlyDenied
              : LocationAccessStatus.denied,
        );
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.status(LocationAccessStatus.serviceDisabled);
      }

      return await _fetchCoordinates();
    } catch (e) {
      return LocationResult.status(LocationAccessStatus.unavailable);
    }
  }

  /// Re-request permission after a prior deny (shows native dialog).
  Future<LocationResult> retryWithPermissionRequest() =>
      resolveLocation(requestIfNeeded: true);

  /// Open app settings (for permanently denied permission).
  Future<bool> openAppSettings() => ph.openAppSettings();

  // ── Private helpers ─────────────────────────────────────────────────────────

  /// Invokes the native SettingsClient GPS resolution dialog via MethodChannel.
  ///
  /// Returns [_GpsEnableResult.enabled]  if the user accepted.
  /// Returns [_GpsEnableResult.rejected] if the user dismissed.
  /// Returns [_GpsEnableResult.error]    if the channel call failed.
  Future<_GpsEnableResult> _requestGpsEnable() async {
    try {
      final String result = await _channel.invokeMethod('requestGpsEnable');
      if (kDebugMode) debugPrint('📍 GPS enable result: $result');
      switch (result) {
        case 'enabled':
          return _GpsEnableResult.enabled;
        case 'rejected':
          return _GpsEnableResult.rejected;
        default:
          return _GpsEnableResult.error;
      }
    } on PlatformException catch (e) {
      if (kDebugMode) debugPrint('📍 GPS channel error: $e');
      return _GpsEnableResult.error;
    } catch (e) {
      if (kDebugMode) debugPrint('📍 GPS enable unexpected error: $e');
      return _GpsEnableResult.error;
    }
  }

  bool _isGranted(LocationPermission p) =>
      p == LocationPermission.always || p == LocationPermission.whileInUse;

  Future<LocationResult> _fetchCoordinates() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: _positionSettings,
      );
      if (kDebugMode) {
        debugPrint(
            '📍 Got position: ${position.latitude}, ${position.longitude}');
      }
      return LocationResult.granted(position.latitude, position.longitude);
    } catch (e) {
      if (kDebugMode) debugPrint('📍 _fetchCoordinates error: $e');
      return LocationResult.status(LocationAccessStatus.unavailable);
    }
  }
}

enum _GpsEnableResult { enabled, rejected, error }
