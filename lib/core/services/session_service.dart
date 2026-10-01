import '../constants/constants.dart';
import '../helpers/shared_pref_helper.dart';

/// Minimal session helper for logged-in vs guest routing.
///
/// - Logged-in session is identified by a non-empty [SharedPrefKeys.medicardCardNo].
/// - Guest session is identified by [SharedPrefKeys.medicardIsGuest] == true.
/// - Logged-in always wins: if a card number exists we treat the user as
///   logged-in even if the guest flag is still set.
class SessionService {
  SessionService._();

  static Future<bool> isGuest() async {
    return SharedPrefHelper.getBool(SharedPrefKeys.medicardIsGuest);
  }

  static Future<void> enterGuest() async {
    await SharedPrefHelper.setData(SharedPrefKeys.medicardIsGuest, true);
  }

  static Future<void> exitGuest() async {
    await SharedPrefHelper.removeData(SharedPrefKeys.medicardIsGuest);
  }

  /// Clears local session state on logout.
  static Future<void> clearAll() async {
    await SharedPrefHelper.removeData(SharedPrefKeys.medicardCardNo);
    await SharedPrefHelper.removeData(SharedPrefKeys.medicardIsGuest);
    await SharedPrefHelper.clearAllSecuredData();
  }

  /// Pure 3-way (plus both) splash routing decision, extracted for tests.
  /// - cardNo non-empty (with or without guest flag) -> logged-in home.
  /// - guest only -> guest home (no cardNo query param).
  /// - neither -> selection.
  static String resolveSplashRoute({
    required String cardNo,
    required bool isGuest,
  }) {
    if (cardNo.isNotEmpty) {
      return '/medicard-home?cardNo=$cardNo';
    }
    if (isGuest) {
      return '/medicard-home';
    }
    return '/medicard';
  }
}
