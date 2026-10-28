/// Payloads cannot select an account or navigate to arbitrary external URLs.
String notificationDestination(Map<String, dynamic> data) {
  const fallback = '/medicard-home';
  const allowed = {
    fallback,
    '/medicard-network',
    '/medicard-invoices',
    '/medicard-invoices/history',
    '/medicard-support',
  };
  final value = data['route'];
  if (value is! String) return fallback;
  final uri = Uri.tryParse(value.trim());
  if (uri == null ||
      uri.hasScheme ||
      uri.hasAuthority ||
      !allowed.contains(uri.path)) {
    return fallback;
  }
  return uri.path;
}
