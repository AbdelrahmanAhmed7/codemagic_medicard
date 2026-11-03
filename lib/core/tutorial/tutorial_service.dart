import 'package:shared_preferences/shared_preferences.dart';

import '../constants/constants.dart';

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

  /// Clears the completion flag for the current customer.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForCustomer(prefs));
  }
}
