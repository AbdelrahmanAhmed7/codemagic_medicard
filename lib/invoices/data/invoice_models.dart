class InvoicePage<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  const InvoicePage({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory InvoicePage.fromJson(
    Map<String, dynamic> json,
    List<T> Function(List<dynamic>) parseItems,
    String itemsKey,
  ) {
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return InvoicePage<T>(
      items: parseItems(json[itemsKey] as List<dynamic>? ?? const []),
      currentPage: _asInt(pagination['currentPage']),
      totalPages: _asInt(pagination['totalPages']),
      hasNextPage: pagination['hasNextPage'] as bool? ?? false,
    );
  }
}

class InvoiceProvider {
  final int providerId;
  final String providerName;
  final String providerLogo;
  final int categoryId;
  final String categoryName;

  const InvoiceProvider({
    required this.providerId,
    required this.providerName,
    required this.providerLogo,
    required this.categoryId,
    required this.categoryName,
  });

  factory InvoiceProvider.fromJson(Map<String, dynamic> json) =>
      InvoiceProvider(
        providerId: _asInt(json['providerId']),
        providerName: json['providerName'] as String? ?? '',
        providerLogo: json['providerLogo'] as String? ?? '',
        categoryId: _asInt(json['categoryId']),
        categoryName: json['categoryName'] as String? ?? '',
      );
}

class InvoiceBranch {
  final int locationId;
  final int providerId;
  final String branchName;
  final String area;
  final String address;
  final String city;
  final String government;
  final String mobile;
  final double latitude;
  final double longitude;
  final String mapsUrl;

  const InvoiceBranch({
    required this.locationId,
    required this.providerId,
    required this.branchName,
    required this.area,
    required this.address,
    required this.city,
    required this.government,
    required this.mobile,
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
  });

  factory InvoiceBranch.fromJson(Map<String, dynamic> json) => InvoiceBranch(
    locationId: _asInt(json['locationId']),
    providerId: _asInt(json['providerId']),
    branchName: json['branchName'] as String? ?? '',
    area: json['area'] as String? ?? '',
    address: json['address'] as String? ?? '',
    city: json['city'] as String? ?? '',
    government: json['government'] as String? ?? '',
    mobile: json['mobile'] as String? ?? '',
    latitude: _asDouble(json['latitude']),
    longitude: _asDouble(json['longitude']),
    mapsUrl: json['mapsUrl'] as String? ?? '',
  );

  String get displayAddress {
    if (address.trim().isNotEmpty) return address.trim();
    if (branchName.trim().isNotEmpty) return branchName.trim();
    if (area.trim().isNotEmpty) return area.trim();
    return '';
  }
}

class InvoiceRecord {
  final int id;
  final String providerLogo;
  final String providerName;
  final String status;
  final String statusChar;
  final String notes;
  final String attachmentsFolder;
  final String invoicePdfUrl;
  final DateTime? createdAt;
  final int lineCount;
  final double totalAmount;

  const InvoiceRecord({
    required this.id,
    required this.providerLogo,
    required this.providerName,
    required this.status,
    required this.statusChar,
    required this.notes,
    required this.attachmentsFolder,
    required this.invoicePdfUrl,
    required this.createdAt,
    required this.lineCount,
    required this.totalAmount,
  });

  factory InvoiceRecord.fromJson(Map<String, dynamic> json) => InvoiceRecord(
    id: _asInt(json['id']),
    providerLogo: json['providerLogo'] as String? ?? '',
    providerName: json['providerName'] as String? ?? '',
    status: json['status'] as String? ?? '',
    statusChar: json['statusChar'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    attachmentsFolder: json['attachmentsFolder'] as String? ?? '',
    invoicePdfUrl: json['invoicePdfUrl'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    lineCount: _asInt(json['lineCount']),
    totalAmount: _asDouble(json['totalAmount']),
  );
}

class CreatedInvoice {
  final int id;
  final String cardId;
  final int providerId;
  final int providerLocationId;
  final String status;
  final String notes;
  final String attachmentsFolder;
  final DateTime? createdAt;

  const CreatedInvoice({
    required this.id,
    required this.cardId,
    required this.providerId,
    required this.providerLocationId,
    required this.status,
    required this.notes,
    required this.attachmentsFolder,
    required this.createdAt,
  });

  factory CreatedInvoice.fromJson(Map<String, dynamic> json) => CreatedInvoice(
    id: _asInt(json['id']),
    cardId: json['cardId'] as String? ?? '',
    providerId: _asInt(json['providerId']),
    providerLocationId: _asInt(json['providerLocationId']),
    status: json['status'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    attachmentsFolder: json['attachmentsFolder'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
  );
}

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
