class ExtractedContact {
  String name;
  String phone;
  String? email;
  String? address;
  String? website;

  ExtractedContact({
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.website,
  });

  factory ExtractedContact.fromJson(Map<String, dynamic> json) {
    return ExtractedContact(
      name: (json['name'] as String? ?? '').trim(),
      phone: (json['phone'] as String? ?? '').trim(),
      email: _nullIfEmpty(json['email'] as String?),
      address: _nullIfEmpty(json['address'] as String?),
      website: _nullIfEmpty(json['website'] as String?),
    );
  }

  static String? _nullIfEmpty(String? s) {
    if (s == null) return null;
    final t = s.trim();
    return t.isEmpty ? null : t;
  }

  bool get isValid => name.isNotEmpty && phone.isNotEmpty;
}
