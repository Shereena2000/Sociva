class CompanyModel {
  final String id;
  final String companyName;
  final String website;
  final String industry;
  final String companySize;
  final int foundedYear;
  final String companyType;
  final String contactPerson;
  final String contactTitle;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String aboutCompany;
  final String missionStatement;
  final String companyCulture;
  final String businessLicenseNumber;
  final String businessLicenseUrl;
  final String taxId;
  final String companyLogoUrl;
  final String userId; // Firebase Auth user ID
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanyModel({
    required this.id,
    required this.companyName,
    required this.website,
    required this.industry,
    required this.companySize,
    required this.foundedYear,
    required this.companyType,
    required this.contactPerson,
    required this.contactTitle,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.aboutCompany,
    required this.missionStatement,
    required this.companyCulture,
    required this.businessLicenseNumber,
    required this.businessLicenseUrl,
    required this.taxId,
    required this.companyLogoUrl,
    required this.userId,
    this.isVerified = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'website': website,
      'industry': industry,
      'companySize': companySize,
      'foundedYear': foundedYear,
      'companyType': companyType,
      'contactPerson': contactPerson,
      'contactTitle': contactTitle,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'aboutCompany': aboutCompany,
      'missionStatement': missionStatement,
      'companyCulture': companyCulture,
      'businessLicenseNumber': businessLicenseNumber,
      'businessLicenseUrl': businessLicenseUrl,
      'taxId': taxId,
      'companyLogoUrl': companyLogoUrl,
      'userId': userId,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (Firebase)
  factory CompanyModel.fromMap(Map<String, dynamic> map) {
    // Handle Timestamp objects from Firestore
    DateTime parseDateTime(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        // Handle Firestore Timestamp
        try {
          return dateValue.toDate();
        } catch (e) {
          print('Error parsing date in CompanyModel: $e');
          return DateTime.now();
        }
      }
    }

    return CompanyModel(
      id: map['id'] ?? '',
      companyName: map['companyName'] ?? '',
      website: map['website'] ?? '',
      industry: map['industry'] ?? '',
      companySize: map['companySize'] ?? '',
      foundedYear: map['foundedYear'] ?? 0,
      companyType: map['companyType'] ?? '',
      contactPerson: map['contactPerson'] ?? '',
      contactTitle: map['contactTitle'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      country: map['country'] ?? '',
      postalCode: map['postalCode'] ?? '',
      aboutCompany: map['aboutCompany'] ?? '',
      missionStatement: map['missionStatement'] ?? '',
      companyCulture: map['companyCulture'] ?? '',
      businessLicenseNumber: map['businessLicenseNumber'] ?? '',
      businessLicenseUrl: map['businessLicenseUrl'] ?? '',
      taxId: map['taxId'] ?? '',
      companyLogoUrl: map['companyLogoUrl'] ?? '',
      userId: map['userId'] ?? '',
      isVerified: map['isVerified'] ?? false,
      isActive: map['isActive'] ?? true,
      createdAt: parseDateTime(map['createdAt']),
      updatedAt: parseDateTime(map['updatedAt']),
    );
  }

  // Copy with method for updates
  CompanyModel copyWith({
    String? id,
    String? companyName,
    String? website,
    String? industry,
    String? companySize,
    int? foundedYear,
    String? companyType,
    String? contactPerson,
    String? contactTitle,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? aboutCompany,
    String? missionStatement,
    String? companyCulture,
    String? businessLicenseNumber,
    String? businessLicenseUrl,
    String? taxId,
    String? companyLogoUrl,
    String? userId,
    bool? isVerified,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyModel(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      website: website ?? this.website,
      industry: industry ?? this.industry,
      companySize: companySize ?? this.companySize,
      foundedYear: foundedYear ?? this.foundedYear,
      companyType: companyType ?? this.companyType,
      contactPerson: contactPerson ?? this.contactPerson,
      contactTitle: contactTitle ?? this.contactTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      aboutCompany: aboutCompany ?? this.aboutCompany,
      missionStatement: missionStatement ?? this.missionStatement,
      companyCulture: companyCulture ?? this.companyCulture,
      businessLicenseNumber: businessLicenseNumber ?? this.businessLicenseNumber,
      businessLicenseUrl: businessLicenseUrl ?? this.businessLicenseUrl,
      taxId: taxId ?? this.taxId,
      companyLogoUrl: companyLogoUrl ?? this.companyLogoUrl,
      userId: userId ?? this.userId,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
