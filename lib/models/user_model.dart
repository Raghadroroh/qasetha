import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String? email;
  final String? phone;
  final String name;
  final String? profileImage;
  final bool emailVerified;
  final bool phoneVerified;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String authMethod; // email, phone, or combined
  final Map<String, dynamic> additionalData;

  UserModel({
    required this.id,
    this.email,
    this.phone,
    required this.name,
    this.profileImage,
    required this.emailVerified,
    required this.phoneVerified,
    required this.createdAt,
    required this.lastLogin,
    this.authMethod = 'email',
    this.additionalData = const {},
  });

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'name': name,
      'profileImage': profileImage,
      'emailVerified': emailVerified,
      'phoneVerified': phoneVerified,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'authMethod': authMethod,
      'additionalData': additionalData,
    };
  }

  // Create from map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'],
      phone: map['phone'],
      name: map['name'] ?? '',
      profileImage: map['profileImage'],
      emailVerified: map['emailVerified'] ?? false,
      phoneVerified: map['phoneVerified'] ?? false,
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: map['lastLogin'] is String
          ? DateTime.parse(map['lastLogin'])
          : (map['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
      authMethod: map['authMethod'] ?? 'email',
      additionalData: Map<String, dynamic>.from(map['additionalData'] ?? {}),
    );
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap({...data, 'id': doc.id});
  }

  // Copy with modifications
  UserModel copyWith({
    String? id,
    String? email,
    String? phone,
    String? name,
    String? profileImage,
    bool? emailVerified,
    bool? phoneVerified,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? authMethod,
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      authMethod: authMethod ?? this.authMethod,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // Check if user is fully verified
  bool get isFullyVerified {
    if (authMethod == 'email') return emailVerified;
    if (authMethod == 'phone') return phoneVerified;
    return emailVerified && phoneVerified;
  }

  // Get display name
  String get displayName {
    if (name.isNotEmpty) return name;
    if (email != null) return email!.split('@')[0];
    if (phone != null) return phone!;
    return 'مستخدم';
  }

  // Get primary contact
  String get primaryContact {
    if (email != null && email!.isNotEmpty) return email!;
    if (phone != null && phone!.isNotEmpty) return phone!;
    return 'لا يوجد';
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, phone: $phone, name: $name, emailVerified: $emailVerified, phoneVerified: $phoneVerified)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.phone == phone &&
        other.name == name &&
        other.emailVerified == emailVerified &&
        other.phoneVerified == phoneVerified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        name.hashCode ^
        emailVerified.hashCode ^
        phoneVerified.hashCode;
  }
}

class ProfileCompletion {
  final double percentage;
  final List<String> missingFields;
  final bool hasSeenWelcomeModal;
  final DateTime? lastPromptDate;
  final bool isBasicInfoComplete;
  final bool isEmploymentInfoComplete;
  final bool isAddressInfoComplete;
  final bool hasProfileImage;

  ProfileCompletion({
    required this.percentage,
    required this.missingFields,
    required this.hasSeenWelcomeModal,
    this.lastPromptDate,
    required this.isBasicInfoComplete,
    required this.isEmploymentInfoComplete,
    required this.isAddressInfoComplete,
    required this.hasProfileImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'percentage': percentage,
      'missingFields': missingFields,
      'hasSeenWelcomeModal': hasSeenWelcomeModal,
      'lastPromptDate': lastPromptDate,
      'isBasicInfoComplete': isBasicInfoComplete,
      'isEmploymentInfoComplete': isEmploymentInfoComplete,
      'isAddressInfoComplete': isAddressInfoComplete,
      'hasProfileImage': hasProfileImage,
    };
  }

  factory ProfileCompletion.fromMap(Map<String, dynamic> map) {
    return ProfileCompletion(
      percentage: (map['percentage'] as num? ?? 0).toDouble(),
      missingFields: List<String>.from(map['missingFields'] ?? []),
      hasSeenWelcomeModal: map['hasSeenWelcomeModal'] ?? false,
      lastPromptDate: map['lastPromptDate'] is Timestamp
          ? (map['lastPromptDate'] as Timestamp).toDate()
          : null,
      isBasicInfoComplete: map['isBasicInfoComplete'] ?? false,
      isEmploymentInfoComplete: map['isEmploymentInfoComplete'] ?? false,
      isAddressInfoComplete: map['isAddressInfoComplete'] ?? false,
      hasProfileImage: map['hasProfileImage'] ?? false,
    );
  }

  ProfileCompletion copyWith({
    double? percentage,
    List<String>? missingFields,
    bool? hasSeenWelcomeModal,
    DateTime? lastPromptDate,
    bool? isBasicInfoComplete,
    bool? isEmploymentInfoComplete,
    bool? isAddressInfoComplete,
    bool? hasProfileImage,
  }) {
    return ProfileCompletion(
      percentage: percentage ?? this.percentage,
      missingFields: missingFields ?? this.missingFields,
      hasSeenWelcomeModal: hasSeenWelcomeModal ?? this.hasSeenWelcomeModal,
      lastPromptDate: lastPromptDate ?? this.lastPromptDate,
      isBasicInfoComplete: isBasicInfoComplete ?? this.isBasicInfoComplete,
      isEmploymentInfoComplete:
          isEmploymentInfoComplete ?? this.isEmploymentInfoComplete,
      isAddressInfoComplete:
          isAddressInfoComplete ?? this.isAddressInfoComplete,
      hasProfileImage: hasProfileImage ?? this.hasProfileImage,
    );
  }
}

class Employment {
  final bool isEmployed;
  final String sector; // public/private/none
  final String employerName;
  final String jobTitle;
  final String? employeeId;

  Employment({
    required this.isEmployed,
    required this.sector,
    required this.employerName,
    required this.jobTitle,
    this.employeeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'isEmployed': isEmployed,
      'sector': sector,
      'employerName': employerName,
      'jobTitle': jobTitle,
      'employeeId': employeeId,
    };
  }

  factory Employment.fromMap(Map<String, dynamic> map) {
    return Employment(
      isEmployed: map['isEmployed'] ?? false,
      sector: map['sector'] ?? 'none',
      employerName: map['employerName'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      employeeId: map['employeeId'],
    );
  }
}

class Address {
  final String street;
  final String city;
  final String governorate;
  final String postalCode;

  Address({
    required this.street,
    required this.city,
    required this.governorate,
    this.postalCode = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'city': city,
      'governorate': governorate,
      'postalCode': postalCode,
    };
  }

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      street: map['street'] ?? '',
      city: map['city'] ?? '',
      governorate: map['governorate'] ?? '',
      postalCode: map['postalCode'] ?? '',
    );
  }
}

class UserProfile {
  final String userId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String? profileImage;
  final String userType; // customer/store_owner/admin
  final String nationalId;
  final Employment employment;
  final Address address;
  final double creditLimit;
  final double availableCredit;
  final double totalDebt;
  final double rating;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProfileCompletion profileCompletion;

  UserProfile({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    this.profileImage,
    required this.userType,
    required this.nationalId,
    required this.employment,
    required this.address,
    required this.creditLimit,
    required this.availableCredit,
    required this.totalDebt,
    required this.rating,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    required this.profileCompletion,
  });

  double get usedCredit => creditLimit - availableCredit;
  double get creditUsagePercentage =>
      creditLimit > 0 ? (usedCredit / creditLimit) * 100 : 0;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'userType': userType,
      'nationalId': nationalId,
      'employment': employment.toMap(),
      'address': address.toMap(),
      'creditLimit': creditLimit,
      'availableCredit': availableCredit,
      'totalDebt': totalDebt,
      'rating': rating,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'profileCompletion': profileCompletion.toMap(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImage: map['profileImage'],
      userType: map['userType'] ?? 'customer',
      nationalId: map['nationalId'] ?? '',
      employment: Employment.fromMap(map['employment'] ?? {}),
      address: Address.fromMap(map['address'] ?? {}),
      creditLimit: (map['creditLimit'] as num? ?? 0).toDouble(),
      availableCredit: (map['availableCredit'] as num? ?? 0).toDouble(),
      totalDebt: (map['totalDebt'] as num? ?? 0).toDouble(),
      rating: (map['rating'] as num? ?? 0).toDouble(),
      isVerified: map['isVerified'] ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      profileCompletion: ProfileCompletion.fromMap(
        map['profileCompletion'] ?? {},
      ),
    );
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap({...data, 'userId': doc.id});
  }

  UserProfile copyWith({
    String? userId,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    String? userType,
    String? nationalId,
    Employment? employment,
    Address? address,
    double? creditLimit,
    double? availableCredit,
    double? totalDebt,
    double? rating,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProfileCompletion? profileCompletion,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      userType: userType ?? this.userType,
      nationalId: nationalId ?? this.nationalId,
      employment: employment ?? this.employment,
      address: address ?? this.address,
      creditLimit: creditLimit ?? this.creditLimit,
      availableCredit: availableCredit ?? this.availableCredit,
      totalDebt: totalDebt ?? this.totalDebt,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileCompletion: profileCompletion ?? this.profileCompletion,
    );
  }
}

class CreditHistoryEntry {
  final String id;
  final double amount;
  final String type; // usage/payment/adjustment
  final String description;
  final DateTime date;
  final double balanceAfter;

  CreditHistoryEntry({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
    required this.balanceAfter,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'description': description,
      'date': date,
      'balanceAfter': balanceAfter,
    };
  }

  factory CreditHistoryEntry.fromMap(Map<String, dynamic> map) {
    return CreditHistoryEntry(
      id: map['id'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      type: map['type'] ?? 'usage',
      description: map['description'] ?? '',
      date: map['date'] is Timestamp
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      balanceAfter: (map['balanceAfter'] ?? 0).toDouble(),
    );
  }
}
