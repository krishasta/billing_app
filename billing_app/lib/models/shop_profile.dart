class ShopProfile {
  final String shopName;
  final String tagline;
  final String phone;
  final String alternatePhone;
  final String address;
  final String gstNumber;
  final String upiId;
  final double defaultDiscountPercent;
  final String termsAndConditions;

  ShopProfile({
    required this.shopName,
    this.tagline = 'Sivakasi · Since 1994 | Direct Factory Price',
    required this.phone,
    this.alternatePhone = '04562 274194',
    required this.address,
    this.gstNumber = '33AABCA1994K1Z8',
    this.upiId = '9842011994@upi',
    this.defaultDiscountPercent = 81.0,
    this.termsAndConditions =
        '1. PESO Licence No. E/HQ/TN/22/1994 (S) - Batch tested under 125 dB limit.\n'
        '2. Light in open ground, one item at a time, never indoors.\n'
        '3. Keep a bucket of sand and water within arm\'s reach.\n'
        '4. Use an agarbatti to light — never a matchstick held close.\n'
        '5. Never return to a failed cracker for 10 minutes, then soak it.\n'
        '6. Children must be supervised on every item including sparklers.\n'
        '7. Crackers once sold cannot be returned or exchanged.\n'
        '8. Wishing you and your family a safe, prosperous & Happy Diwali!',
  });

  Map<String, dynamic> toJson() => {
        'shopName': shopName,
        'tagline': tagline,
        'phone': phone,
        'alternatePhone': alternatePhone,
        'address': address,
        'gstNumber': gstNumber,
        'upiId': upiId,
        'defaultDiscountPercent': defaultDiscountPercent,
        'termsAndConditions': termsAndConditions,
      };

  factory ShopProfile.fromJson(Map<String, dynamic> json) => ShopProfile(
        shopName: json['shopName'] as String? ?? 'Gopi Crackers',
        tagline: json['tagline'] as String? ?? 'Sivakasi · Since 1994 | Direct Factory Price',
        phone: json['phone'] as String? ?? '+91 98420 11994',
        alternatePhone: json['alternatePhone'] as String? ?? '04562 274194',
        address: json['address'] as String? ??
            '14/3 Sattur Main Road, Sivakasi, Virudhunagar District, Tamil Nadu 626123',
        gstNumber: json['gstNumber'] as String? ?? '33AABCA1994K1Z8',
        upiId: json['upiId'] as String? ?? '9842011994@upi',
        defaultDiscountPercent: (json['defaultDiscountPercent'] as num?)?.toDouble() ?? 81.0,
        termsAndConditions: json['termsAndConditions'] as String? ??
            '1. PESO Licence No. E/HQ/TN/22/1994 (S) - Batch tested under 125 dB limit.\n'
            '2. Light in open ground, one item at a time, never indoors.\n'
            '3. Keep a bucket of sand and water within arm\'s reach.\n'
            '4. Use an agarbatti to light — never a matchstick held close.\n'
            '5. Never return to a failed cracker for 10 minutes, then soak it.\n'
            '6. Children must be supervised on every item including sparklers.\n'
            '7. Crackers once sold cannot be returned or exchanged.\n'
            '8. Wishing you and your family a safe, prosperous & Happy Diwali!',
      );

  ShopProfile copyWith({
    String? shopName,
    String? tagline,
    String? phone,
    String? alternatePhone,
    String? address,
    String? gstNumber,
    String? upiId,
    double? defaultDiscountPercent,
    String? termsAndConditions,
  }) {
    return ShopProfile(
      shopName: shopName ?? this.shopName,
      tagline: tagline ?? this.tagline,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      address: address ?? this.address,
      gstNumber: gstNumber ?? this.gstNumber,
      upiId: upiId ?? this.upiId,
      defaultDiscountPercent: defaultDiscountPercent ?? this.defaultDiscountPercent,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
    );
  }
}
