import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppUserRole { seller, buyer, admin }

enum RequestUrgency { normal, urgent }

enum SupportTicketStatus { open, inProgress, closed }

class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.address,
    required this.rating,
    required this.completedOrders,
    required this.preferredCategoryId,
    this.vehicleInfo,
    this.workingHours,
    this.portfolioImages = const [],
    this.points = 0,
  });

  final String id;
  final String name;
  final String phone;
  final AppUserRole role;
  final String address;
  final double rating;
  final int completedOrders;
  final String preferredCategoryId;
  final String? vehicleInfo;
  final String? workingHours;
  final List<String> portfolioImages;
  final int points;

  AppUser copyWith({
    String? name,
    String? phone,
    String? address,
    String? preferredCategoryId,
    int? points,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role,
      address: address ?? this.address,
      rating: rating,
      completedOrders: completedOrders,
      preferredCategoryId: preferredCategoryId ?? this.preferredCategoryId,
      vehicleInfo: vehicleInfo,
      workingHours: workingHours,
      portfolioImages: portfolioImages,
      points: points ?? this.points,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'phone': phone,
        'role': role.name,
        'address': address,
        'rating': rating,
        'completedOrders': completedOrders,
        'preferredCategoryId': preferredCategoryId,
        'vehicleInfo': vehicleInfo,
        'workingHours': workingHours,
        'portfolioImages': portfolioImages,
        'points': points,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: map['name'] as String,
      phone: map['phone'] as String,
      role: AppUserRole.values.firstWhere(
        (role) => role.name == map['role'],
        orElse: () => AppUserRole.seller,
      ),
      address: map['address'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      completedOrders: map['completedOrders'] as int? ?? 0,
      preferredCategoryId: map['preferredCategoryId'] as String? ?? 'paper',
      vehicleInfo: map['vehicleInfo'] as String?,
      workingHours: map['workingHours'] as String?,
      portfolioImages: List<String>.from(map['portfolioImages'] ?? const []),
      points: map['points'] as int? ?? 0,
    );
  }
}

class WasteCategoryConfig {
  WasteCategoryConfig({
    required this.id,
    required this.title,
    required this.iconName,
    required this.colorHex,
    required this.pricePerKg,
    required this.isProtected,
  });

  final String id;
  final String title;
  final String iconName;
  final String colorHex;
  final int pricePerKg;
  final bool isProtected;

  Color get color => colorHex.toColor();

  WasteCategoryConfig copyWith({
    String? title,
    String? colorHex,
    int? pricePerKg,
    bool? isProtected,
  }) {
    return WasteCategoryConfig(
      id: id,
      title: title ?? this.title,
      iconName: iconName,
      colorHex: colorHex ?? this.colorHex,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      isProtected: isProtected ?? this.isProtected,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'iconName': iconName,
        'colorHex': colorHex,
        'pricePerKg': pricePerKg,
        'isProtected': isProtected,
      };

  factory WasteCategoryConfig.fromMap(Map<String, dynamic> map) {
    return WasteCategoryConfig(
      id: map['id'] as String,
      title: map['title'] as String,
      iconName: map['iconName'] as String,
      colorHex: map['colorHex'] as String,
      pricePerKg: map['pricePerKg'] as int? ?? 0,
      isProtected: map['isProtected'] as bool? ?? false,
    );
  }
}

class QuantityOption {
  QuantityOption({
    required this.id,
    required this.label,
    required this.sortOrder,
  });

  final String id;
  final String label;
  final int sortOrder;

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'sortOrder': sortOrder,
      };

  factory QuantityOption.fromMap(Map<String, dynamic> map) {
    return QuantityOption(
      id: map['id'] as String,
      label: map['label'] as String,
      sortOrder: map['sortOrder'] as int? ?? 0,
    );
  }
}

class AdminSettings {
  AdminSettings({
    required this.commissionPercent,
    required this.maxDistanceKm,
    required this.demoModeEnabled,
  });

  final double commissionPercent;
  final double maxDistanceKm;
  final bool demoModeEnabled;

  AdminSettings copyWith({
    double? commissionPercent,
    double? maxDistanceKm,
    bool? demoModeEnabled,
  }) {
    return AdminSettings(
      commissionPercent: commissionPercent ?? this.commissionPercent,
      maxDistanceKm: maxDistanceKm ?? this.maxDistanceKm,
      demoModeEnabled: demoModeEnabled ?? this.demoModeEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'commissionPercent': commissionPercent,
        'maxDistanceKm': maxDistanceKm,
        'demoModeEnabled': demoModeEnabled,
      };

  factory AdminSettings.fromMap(Map<String, dynamic> map) {
    return AdminSettings(
      commissionPercent: (map['commissionPercent'] as num?)?.toDouble() ?? 0,
      maxDistanceKm: (map['maxDistanceKm'] as num?)?.toDouble() ?? 10,
      demoModeEnabled: map['demoModeEnabled'] as bool? ?? true,
    );
  }
}

class RecycleRequest {
  RecycleRequest({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.categoryId,
    required this.quantityId,
    required this.quantityLabel,
    required this.address,
    required this.description,
    required this.estimatedPrice,
    required this.urgent,
    required this.statusLabel,
    required this.distanceKm,
  });

  final String id;
  final String sellerId;
  final String sellerName;
  final String categoryId;
  final String quantityId;
  final String quantityLabel;
  final String address;
  final String description;
  final int estimatedPrice;
  final bool urgent;
  final String statusLabel;
  final double distanceKm;

  RecycleRequest copyWith({String? statusLabel}) {
    return RecycleRequest(
      id: id,
      sellerId: sellerId,
      sellerName: sellerName,
      categoryId: categoryId,
      quantityId: quantityId,
      quantityLabel: quantityLabel,
      address: address,
      description: description,
      estimatedPrice: estimatedPrice,
      urgent: urgent,
      statusLabel: statusLabel ?? this.statusLabel,
      distanceKm: distanceKm,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'sellerId': sellerId,
        'sellerName': sellerName,
        'categoryId': categoryId,
        'quantityId': quantityId,
        'quantityLabel': quantityLabel,
        'address': address,
        'description': description,
        'estimatedPrice': estimatedPrice,
        'urgent': urgent,
        'statusLabel': statusLabel,
        'distanceKm': distanceKm,
      };

  factory RecycleRequest.fromMap(Map<String, dynamic> map) {
    return RecycleRequest(
      id: map['id'] as String,
      sellerId: map['sellerId'] as String,
      sellerName: map['sellerName'] as String,
      categoryId: map['categoryId'] as String,
      quantityId: map['quantityId'] as String,
      quantityLabel: map['quantityLabel'] as String,
      address: map['address'] as String,
      description: map['description'] as String? ?? '',
      estimatedPrice: map['estimatedPrice'] as int? ?? 0,
      urgent: map['urgent'] as bool? ?? false,
      statusLabel: map['statusLabel'] as String? ?? 'در انتظار',
      distanceKm: (map['distanceKm'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TicketMessage {
  TicketMessage({
    required this.id,
    required this.senderName,
    required this.body,
    required this.sentAt,
    required this.isAdmin,
  });

  final String id;
  final String senderName;
  final String body;
  final DateTime sentAt;
  final bool isAdmin;

  Map<String, dynamic> toMap() => {
        'id': id,
        'senderName': senderName,
        'body': body,
        'sentAt': sentAt.toIso8601String(),
        'isAdmin': isAdmin,
      };

  factory TicketMessage.fromMap(Map<String, dynamic> map) {
    return TicketMessage(
      id: map['id'] as String,
      senderName: map['senderName'] as String,
      body: map['body'] as String,
      sentAt: DateTime.tryParse(map['sentAt'] as String? ?? '') ?? DateTime.now(),
      isAdmin: map['isAdmin'] as bool? ?? false,
    );
  }
}

class SupportTicket {
  SupportTicket({
    required this.id,
    required this.title,
    required this.status,
    required this.preview,
    required this.messages,
  });

  final String id;
  final String title;
  final SupportTicketStatus status;
  final String preview;
  final List<TicketMessage> messages;

  SupportTicket copyWith({
    SupportTicketStatus? status,
    String? preview,
    List<TicketMessage>? messages,
  }) {
    return SupportTicket(
      id: id,
      title: title,
      status: status ?? this.status,
      preview: preview ?? this.preview,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'status': status.name,
        'preview': preview,
        'messages': messages.map((message) => message.toMap()).toList(),
      };

  factory SupportTicket.fromMap(Map<String, dynamic> map) {
    return SupportTicket(
      id: map['id'] as String,
      title: map['title'] as String,
      status: SupportTicketStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => SupportTicketStatus.open,
      ),
      preview: map['preview'] as String? ?? '',
      messages: (map['messages'] as List<dynamic>? ?? const [])
          .map((item) => TicketMessage.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class AppBootstrapData {
  AppBootstrapData({
    required this.users,
    required this.categories,
    required this.quantityOptions,
    required this.settings,
    required this.requests,
    required this.tickets,
  });

  final List<AppUser> users;
  final List<WasteCategoryConfig> categories;
  final List<QuantityOption> quantityOptions;
  final AdminSettings settings;
  final List<RecycleRequest> requests;
  final List<SupportTicket> tickets;

  factory AppBootstrapData.fromMap(Map<String, dynamic> map) {
    return AppBootstrapData(
      users: (map['users'] as List<dynamic>? ?? const [])
          .map((item) => AppUser.fromMap(item as Map<String, dynamic>))
          .toList(),
      categories: (map['categories'] as List<dynamic>? ?? const [])
          .map((item) => WasteCategoryConfig.fromMap(item as Map<String, dynamic>))
          .toList(),
      quantityOptions: (map['quantityOptions'] as List<dynamic>? ?? const [])
          .map((item) => QuantityOption.fromMap(item as Map<String, dynamic>))
          .toList(),
      settings: AdminSettings.fromMap(map['settings'] as Map<String, dynamic>? ?? const {}),
      requests: (map['requests'] as List<dynamic>? ?? const [])
          .map((item) => RecycleRequest.fromMap(item as Map<String, dynamic>))
          .toList(),
      tickets: (map['tickets'] as List<dynamic>? ?? const [])
          .map((item) => SupportTicket.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

IconData iconFromName(String iconName) {
  switch (iconName) {
    case 'description':
      return Icons.description_rounded;
    case 'local_drink':
      return Icons.local_drink_rounded;
    case 'precision_manufacturing':
      return Icons.precision_manufacturing_rounded;
    case 'electrical_services':
      return Icons.electrical_services_rounded;
    case 'wine_bar':
      return Icons.wine_bar_rounded;
    case 'devices':
      return Icons.devices_rounded;
    case 'battery':
      return Icons.battery_full_rounded;
    case 'checkroom':
      return Icons.checkroom_rounded;
    default:
      return Icons.recycling_rounded;
  }
}

Color statusColor(SupportTicketStatus status) {
  switch (status) {
    case SupportTicketStatus.open:
      return AppPalette.warning;
    case SupportTicketStatus.inProgress:
      return AppPalette.info;
    case SupportTicketStatus.closed:
      return AppPalette.forest;
  }
}

String statusLabel(SupportTicketStatus status) {
  switch (status) {
    case SupportTicketStatus.open:
      return 'باز';
    case SupportTicketStatus.inProgress:
      return 'در حال پیگیری';
    case SupportTicketStatus.closed:
      return 'بسته شده';
  }
}
