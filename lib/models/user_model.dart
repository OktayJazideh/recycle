import 'package:uuid/uuid.dart';

enum UserRole { seller, buyer, admin }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final double ratingAvg;
  final int ratingCount;
  final String address;
  final double latitude;
  final double longitude;
  final bool isActive;
  final bool isVerified;
  final String? profileImage;
  final String? vehicleInfo;
  final List<String> wasteTypes;
  final String? workingHours;
  final int completedOrders;
  final DateTime createdAt;

  UserModel({
    String? id,
    required this.name,
    required this.phone,
    required this.role,
    this.ratingAvg = 0.0,
    this.ratingCount = 0,
    this.address = '',
    this.latitude = 35.6892,
    this.longitude = 51.3890,
    this.isActive = true,
    this.isVerified = false,
    this.profileImage,
    this.vehicleInfo,
    this.wasteTypes = const [],
    this.workingHours,
    this.completedOrders = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone,
    'role': role.name, 'ratingAvg': ratingAvg,
    'ratingCount': ratingCount, 'address': address,
    'latitude': latitude, 'longitude': longitude,
    'isActive': isActive, 'isVerified': isVerified,
    'profileImage': profileImage, 'vehicleInfo': vehicleInfo,
    'wasteTypes': wasteTypes, 'workingHours': workingHours,
    'completedOrders': completedOrders,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'], name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    role: UserRole.values.firstWhere((e) => e.name == map['role'], orElse: () => UserRole.seller),
    ratingAvg: (map['ratingAvg'] as num?)?.toDouble() ?? 0.0,
    ratingCount: map['ratingCount'] ?? 0,
    address: map['address'] ?? '',
    latitude: (map['latitude'] as num?)?.toDouble() ?? 35.6892,
    longitude: (map['longitude'] as num?)?.toDouble() ?? 51.3890,
    isActive: map['isActive'] ?? true,
    isVerified: map['isVerified'] ?? false,
    profileImage: map['profileImage'],
    vehicleInfo: map['vehicleInfo'],
    wasteTypes: List<String>.from(map['wasteTypes'] ?? []),
    workingHours: map['workingHours'],
    completedOrders: map['completedOrders'] ?? 0,
    createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
  );

  UserModel copyWith({
    String? name, String? phone, UserRole? role,
    double? ratingAvg, int? ratingCount, String? address,
    double? latitude, double? longitude, bool? isActive,
    bool? isVerified, String? profileImage, String? vehicleInfo,
    List<String>? wasteTypes, String? workingHours, int? completedOrders,
  }) => UserModel(
    id: id, name: name ?? this.name, phone: phone ?? this.phone,
    role: role ?? this.role, ratingAvg: ratingAvg ?? this.ratingAvg,
    ratingCount: ratingCount ?? this.ratingCount,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    isActive: isActive ?? this.isActive,
    isVerified: isVerified ?? this.isVerified,
    profileImage: profileImage ?? this.profileImage,
    vehicleInfo: vehicleInfo ?? this.vehicleInfo,
    wasteTypes: wasteTypes ?? this.wasteTypes,
    workingHours: workingHours ?? this.workingHours,
    completedOrders: completedOrders ?? this.completedOrders,
    createdAt: createdAt,
  );
}
