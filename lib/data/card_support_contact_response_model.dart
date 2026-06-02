class CardSupportContactResponseModel {
  final bool success;
  final String timestamp;
  final String message;
  final CardSupportContactData? data;

  const CardSupportContactResponseModel({
    required this.success,
    required this.timestamp,
    required this.message,
    required this.data,
  });

  factory CardSupportContactResponseModel.fromJson(Map<String, dynamic> json) {
    return CardSupportContactResponseModel(
      success: json['success'] == true,
      timestamp: (json['timestamp'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      data: json['data'] is Map<String, dynamic>
          ? CardSupportContactData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'timestamp': timestamp,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CardSupportContactData {
  final String email;
  final String hotLine;
  final String whatsApp;
  final String website;
  final String linkedIn;
  final String facebook;
  final String instagram;

  const CardSupportContactData({
    required this.email,
    required this.hotLine,
    required this.whatsApp,
    required this.website,
    required this.linkedIn,
    required this.facebook,
    required this.instagram,
  });

  factory CardSupportContactData.fromJson(Map<String, dynamic> json) {
    String valueOf(String key) => (json[key] ?? '').toString();
    return CardSupportContactData(
      email: valueOf('email'),
      hotLine: valueOf('hotLine'),
      whatsApp: valueOf('whatsApp'),
      website: valueOf('website'),
      linkedIn: valueOf('linkedIn'),
      facebook: valueOf('facebook'),
      instagram: valueOf('instagram'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'hotLine': hotLine,
      'whatsApp': whatsApp,
      'website': website,
      'linkedIn': linkedIn,
      'facebook': facebook,
      'instagram': instagram,
    };
  }
}
