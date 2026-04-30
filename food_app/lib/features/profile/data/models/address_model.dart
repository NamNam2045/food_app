class AddressModel {
  AddressModel({
    required this.id,
    required this.label,
    required this.streetLine1,
    required this.streetLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.countryCode,
    required this.latitude,
    required this.longitude,
    required this.defaultAddress,
  });

  final int id;
  final String label;
  final String streetLine1;
  final String? streetLine2;
  final String city;
  final String state;
  final String postalCode;
  final String countryCode;
  final double? latitude;
  final double? longitude;
  final bool defaultAddress;

  String get shortText {
    final parts = <String>[
      streetLine1,
      if ((streetLine2 ?? '').isNotEmpty) streetLine2!,
      city,
    ];
    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: (json['label'] ?? '').toString(),
      streetLine1: (json['streetLine1'] ?? '').toString(),
      streetLine2: json['streetLine2']?.toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      postalCode: (json['postalCode'] ?? '').toString(),
      countryCode: (json['countryCode'] ?? 'VN').toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      defaultAddress:
          json['defaultAddress'] == true || json['isDefault'] == true,
    );
  }
}
