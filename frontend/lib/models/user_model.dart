class AddressModel {
  final String id;
  final String fullName;
  final String phone;
  final String street;
  final String landmark;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final bool isDefault;
  final String addressType;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.street,
    this.landmark = '',
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    this.isDefault = false,
    this.addressType = 'HOME',
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phone: json['phone'] ?? '',
      street: json['street'] ?? '',
      landmark: json['landmark'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? 'India',
      isDefault: json['isDefault'] ?? false,
      addressType: json['addressType'] ?? 'HOME',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'street': street,
    'landmark': landmark,
    'city': city,
    'state': state,
    'postalCode': postalCode,
    'country': country,
    'isDefault': isDefault,
    'addressType': addressType,
  };
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String avatarUrl;
  final List<AddressModel> addresses;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'CUSTOMER',
    this.phone = '',
    this.avatarUrl = '',
    this.addresses = const [],
    this.isActive = true,
  });

  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    List<AddressModel> addrList = [];
    if (json['addresses'] is List) {
      addrList = (json['addresses'] as List)
          .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    String avatar = '';
    if (json['avatar'] is Map && json['avatar']['url'] != null) {
      avatar = json['avatar']['url'].toString();
    } else if (json['avatar'] is String) {
      avatar = json['avatar'];
    }

    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'CUSTOMER',
      phone: json['phone'] ?? '',
      avatarUrl: avatar,
      addresses: addrList,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'phone': phone,
    'avatar': {'url': avatarUrl},
    'addresses': addresses.map((e) => e.toJson()).toList(),
    'isActive': isActive,
  };
}
