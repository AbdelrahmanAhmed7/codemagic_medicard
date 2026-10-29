import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

const newOrderTutorialReplayResult = 'newOrderTutorialReplay';

/// Controls whether the new-order onboarding tour should be shown.
///
/// Storage is currently **local** (SharedPreferences) and scoped to the
/// signed-in card number so customers sharing a device each see it once.
///
/// TODO(backend-sync): To sync this flag per customer account, inject a
/// remote datasource here (e.g. a UserSettingsRepository that follows the
/// same pattern as the existing UpdateProfileUseCase / profile API).
/// The UI only calls [shouldShow] and [markSeen], so no UI code changes
/// when you add remote persistence.
abstract class TutorialService {
  static const storageKey = 'hasSeenNewOrderTutorial';

  static String _keyForCustomer(SharedPreferences prefs) {
    final cardNo = prefs.getString(SharedPrefKeys.medicardCardNo)?.trim() ?? '';
    return cardNo.isEmpty ? storageKey : '$storageKey:$cardNo';
  }

  /// Returns true when the tour should run.
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_keyForCustomer(prefs)) ?? false);
  }

  /// Marks the tour as done. Call on skip, finish, or early exit.
  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyForCustomer(prefs), true);
  }

  /// Resets the flag so the tour plays again (used by the replay button).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForCustomer(prefs));
  }
}
