import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {
  Future<bool> launchURL(String url) async {
    try {
      String finalUrl = url.trim();
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'https://$finalUrl';
      }
      final uri = Uri.parse(finalUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> launchEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    try {
      final Map<String, String> queryParameters = {};
      if (subject != null && subject.isNotEmpty) {
        queryParameters['subject'] = subject;
      }
      if (body != null && body.isNotEmpty) {
        queryParameters['body'] = body;
      }

      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<bool> launchWhatsApp(String phone, {String? message}) async {
    try {
      // Clean non-digit characters
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

      // Specifically handle Egyptian mobile numbers (11 digits starting with 01)
      if (cleanPhone.startsWith('01') && cleanPhone.length == 11) {
        cleanPhone = '2$cleanPhone'; // Convert 01... to 201...
      } else if (cleanPhone.startsWith('1') && cleanPhone.length == 10) {
        cleanPhone = '20$cleanPhone'; // Convert 1... to 201...
      }

      final uri = Uri.parse(
        'https://wa.me/$cleanPhone${message != null ? '?text=${Uri.encodeComponent(message)}' : ''}',
      );
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  Future<bool> makePhoneCall(String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> launchSMS(String phone, {String? message}) async {
    try {
      final uri = Uri(
        scheme: 'sms',
        path: phone,
        queryParameters: message != null ? {'body': message} : null,
      );
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }

  Future<bool> launchFacebook(String url) async {
    try {
      String finalUrl = url.trim();
      if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
        finalUrl = 'https://$finalUrl';
      }
      final mobileUrl = finalUrl.replaceAll('www.facebook.com', 'm.facebook.com');
      final uri = Uri.parse(mobileUrl);

      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
