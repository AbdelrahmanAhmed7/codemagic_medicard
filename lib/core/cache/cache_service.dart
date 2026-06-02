import 'network_cache_service.dart';

class CacheService {
  // ==================== Network Cache ====================

  /// Cache network categories data
  static Future<void> cacheNetworkCategoriesData(dynamic data) async {
    return NetworkCacheService.cacheNetworkCategoriesData(data);
  }

  /// Get cached network categories data
  static Future<dynamic> getCachedNetworkCategoriesData() async {
    return NetworkCacheService.getCachedNetworkCategoriesData();
  }

  /// Clear network categories cache
  static Future<void> clearNetworkCategoriesCache() async {
    return NetworkCacheService.clearNetworkCategoriesCache();
  }

  /// Cache network governments data
  static Future<void> cacheNetworkGovernmentsData(dynamic data) async {
    return NetworkCacheService.cacheNetworkGovernmentsData(data);
  }

  /// Get cached network governments data
  static Future<dynamic> getCachedNetworkGovernmentsData() async {
    return NetworkCacheService.getCachedNetworkGovernmentsData();
  }

  /// Clear network governments cache
  static Future<void> clearNetworkGovernmentsCache() async {
    return NetworkCacheService.clearNetworkGovernmentsCache();
  }

  /// Cache network cities data
  static Future<void> cacheNetworkCitiesData(
    int governmentId,
    dynamic data,
  ) async {
    return NetworkCacheService.cacheNetworkCitiesData(governmentId, data);
  }

  /// Get cached network cities data
  static Future<dynamic> getCachedNetworkCitiesData(int governmentId) async {
    return NetworkCacheService.getCachedNetworkCitiesData(governmentId);
  }

  /// Clear network cities cache for specific government
  static Future<void> clearNetworkCitiesCache(int governmentId) async {
    return NetworkCacheService.clearNetworkCitiesCache(governmentId);
  }

  /// Clear all network cities cache
  static Future<void> clearAllNetworkCitiesCache() async {
    return NetworkCacheService.clearAllNetworkCitiesCache();
  }

  // ==================== Support Contacts Cache ====================

  /// Cache support contacts data
  static Future<void> cacheSupportContactsData(dynamic data) async {
    return NetworkCacheService.cacheSupportContactsData(data);
  }

  /// Get cached support contacts data
  static Future<dynamic> getCachedSupportContactsData() async {
    return NetworkCacheService.getCachedSupportContactsData();
  }

  /// Clear support contacts cache
  static Future<void> clearSupportContactsCache() async {
    return NetworkCacheService.clearSupportContactsCache();
  }
}
