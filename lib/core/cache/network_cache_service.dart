import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Network cache service - handles caching for network feature data
class NetworkCacheService {
  // Network Categories Cache (rarely change)
  static const String _networkCategoriesDataKey = 'network_categories_data';
  static const String _networkCategoriesLastUpdateKey = 'network_categories_last_update';
  static const int _networkCategoriesCacheExpiryHours = 24; // 24 hours

  // Network Governments Cache (rarely change)
  static const String _networkGovernmentsDataKey = 'network_governments_data';
  static const String _networkGovernmentsLastUpdateKey = 'network_governments_last_update';
  static const int _networkGovernmentsCacheExpiryHours = 24; // 24 hours

  // Network Cities Cache (changes with government selection)
  static const String _networkCitiesDataKey = 'network_cities_data';
  static const String _networkCitiesLastUpdateKey = 'network_cities_last_update';
  static const int _networkCitiesCacheExpiryHours = 12; // 12 hours

  // Support Contacts Cache
  static const String _supportContactsDataKey = 'support_contacts_data';
  static const String _supportContactsLastUpdateKey = 'support_contacts_last_update';
  static const int _supportContactsCacheExpiryHours = 48; // 48 hours

  // Cache Network Categories
  static Future<void> cacheNetworkCategoriesData(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString(_networkCategoriesDataKey, jsonString);
    await prefs.setInt(
      _networkCategoriesLastUpdateKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<dynamic> getCachedNetworkCategoriesData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_networkCategoriesDataKey);
    final lastUpdate = prefs.getInt(_networkCategoriesLastUpdateKey);

    if (jsonString == null || lastUpdate == null) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = now - lastUpdate;
    final cacheExpiryMs = _networkCategoriesCacheExpiryHours * 60 * 60 * 1000;

    if (cacheAge > cacheExpiryMs) {
      await clearNetworkCategoriesCache();
      return null;
    }

    try {
      return jsonDecode(jsonString);
    } catch (e) {
      await clearNetworkCategoriesCache();
      return null;
    }
  }

  static Future<void> clearNetworkCategoriesCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_networkCategoriesDataKey);
    await prefs.remove(_networkCategoriesLastUpdateKey);
  }

  // Cache Network Governments
  static Future<void> cacheNetworkGovernmentsData(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString(_networkGovernmentsDataKey, jsonString);
    await prefs.setInt(
      _networkGovernmentsLastUpdateKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<dynamic> getCachedNetworkGovernmentsData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_networkGovernmentsDataKey);
    final lastUpdate = prefs.getInt(_networkGovernmentsLastUpdateKey);

    if (jsonString == null || lastUpdate == null) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = now - lastUpdate;
    final cacheExpiryMs = _networkGovernmentsCacheExpiryHours * 60 * 60 * 1000;

    if (cacheAge > cacheExpiryMs) {
      await clearNetworkGovernmentsCache();
      return null;
    }

    try {
      return jsonDecode(jsonString);
    } catch (e) {
      await clearNetworkGovernmentsCache();
      return null;
    }
  }

  static Future<void> clearNetworkGovernmentsCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_networkGovernmentsDataKey);
    await prefs.remove(_networkGovernmentsLastUpdateKey);
  }

  // Cache Network Cities by government ID
  static Future<void> cacheNetworkCitiesData(int governmentId, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString('${_networkCitiesDataKey}_$governmentId', jsonString);
    await prefs.setInt(
      '${_networkCitiesLastUpdateKey}_$governmentId',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<dynamic> getCachedNetworkCitiesData(int governmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_networkCitiesDataKey}_$governmentId');
    final lastUpdate = prefs.getInt('${_networkCitiesLastUpdateKey}_$governmentId');

    if (jsonString == null || lastUpdate == null) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = now - lastUpdate;
    final cacheExpiryMs = _networkCitiesCacheExpiryHours * 60 * 60 * 1000;

    if (cacheAge > cacheExpiryMs) {
      await clearNetworkCitiesCache(governmentId);
      return null;
    }

    try {
      return jsonDecode(jsonString);
    } catch (e) {
      await clearNetworkCitiesCache(governmentId);
      return null;
    }
  }

  static Future<void> clearNetworkCitiesCache(int governmentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${_networkCitiesDataKey}_$governmentId');
    await prefs.remove('${_networkCitiesLastUpdateKey}_$governmentId');
  }

  static Future<void> clearAllNetworkCitiesCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_networkCitiesDataKey) ||
          key.startsWith(_networkCitiesLastUpdateKey)) {
        await prefs.remove(key);
      }
    }
  }

  // Support Contacts Cache Methods
  static Future<void> cacheSupportContactsData(dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data);
    await prefs.setString(_supportContactsDataKey, jsonString);
    await prefs.setInt(
      _supportContactsLastUpdateKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  static Future<dynamic> getCachedSupportContactsData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_supportContactsDataKey);
    final lastUpdate = prefs.getInt(_supportContactsLastUpdateKey);

    if (jsonString == null || lastUpdate == null) {
      return null;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = now - lastUpdate;
    final cacheExpiryMs = _supportContactsCacheExpiryHours * 60 * 60 * 1000;

    if (cacheAge > cacheExpiryMs) {
      await clearSupportContactsCache();
      return null;
    }

    try {
      return jsonDecode(jsonString);
    } catch (e) {
      await clearSupportContactsCache();
      return null;
    }
  }

  static Future<void> clearSupportContactsCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_supportContactsDataKey);
    await prefs.remove(_supportContactsLastUpdateKey);
  }
}

