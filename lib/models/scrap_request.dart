import 'package:uuid/uuid.dart';

enum RequestStatus { pending, active, accepted, inProgress, completed, cancelled }
enum PaymentType { cash, online, both }
enum UrgencyType { normal, urgent }
enum WasteCondition { clean, compressed, mixed, separated, needsPickup }

class ScrapRequest {
  final String id;
  final String sellerId;
  final String sellerName;
  final String wasteType;
  final List<String> wasteTypes;
  final String quantity;
  final String description;
  final List<String> images;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime requestedTime;
  final PaymentType paymentType;
  final UrgencyType urgency;
  final WasteCondition condition;
  final RequestStatus status;
  final double? estimatedPrice;
  final String? acceptedBuyerId;
  final DateTime createdAt;

  ScrapRequest({
    String? id,
    required this.sellerId,
    required this.sellerName,
    required this.wasteType,
    this.wasteTypes = const [],
    required this.quantity,
    this.description = '',
    this.images = const [],
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.requestedTime,
    this.paymentType = PaymentType.cash,
    this.urgency = UrgencyType.normal,
    this.condition = WasteCondition.mixed,
    this.status = RequestStatus.pending,
    this.estimatedPrice,
    this.acceptedBuyerId,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'sellerId': sellerId, 'sellerName': sellerName,
    'wasteType': wasteType, 'wasteTypes': wasteTypes,
    'quantity': quantity, 'description': description,
    'images': images, 'latitude': latitude, 'longitude': longitude,
    'address': address, 'requestedTime': requestedTime.toIso8601String(),
    'paymentType': paymentType.name, 'urgency': urgency.name,
    'condition': condition.name, 'status': status.name,
    'estimatedPrice': estimatedPrice, 'acceptedBuyerId': acceptedBuyerId,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ScrapRequest.fromMap(Map<String, dynamic> map) => ScrapRequest(
    id: map['id'], sellerId: map['sellerId'] ?? '',
    sellerName: map['sellerName'] ?? '',
    wasteType: map['wasteType'] ?? '',
    wasteTypes: List<String>.from(map['wasteTypes'] ?? []),
    quantity: map['quantity'] ?? '',
    description: map['description'] ?? '',
    images: List<String>.from(map['images'] ?? []),
    latitude: (map['latitude'] as num?)?.toDouble() ?? 35.6892,
    longitude: (map['longitude'] as num?)?.toDouble() ?? 51.3890,
    address: map['address'] ?? '',
    requestedTime: DateTime.parse(map['requestedTime']),
    paymentType: PaymentType.values.firstWhere((e) => e.name == map['paymentType'], orElse: () => PaymentType.cash),
    urgency: UrgencyType.values.firstWhere((e) => e.name == map['urgency'], orElse: () => UrgencyType.normal),
    condition: WasteCondition.values.firstWhere((e) => e.name == map['condition'], orElse: () => WasteCondition.mixed),
    status: RequestStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => RequestStatus.pending),
    estimatedPrice: (map['estimatedPrice'] as num?)?.toDouble(),
    acceptedBuyerId: map['acceptedBuyerId'],
    createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
  );

  ScrapRequest copyWith({
    RequestStatus? status,
    String? acceptedBuyerId,
    double? estimatedPrice,
  }) => ScrapRequest(
    id: id, sellerId: sellerId, sellerName: sellerName,
    wasteType: wasteType, wasteTypes: wasteTypes,
    quantity: quantity, description: description,
    images: images, latitude: latitude, longitude: longitude,
    address: address, requestedTime: requestedTime,
    paymentType: paymentType, urgency: urgency,
    condition: condition,
    status: status ?? this.status,
    estimatedPrice: estimatedPrice ?? this.estimatedPrice,
    acceptedBuyerId: acceptedBuyerId ?? this.acceptedBuyerId,
    createdAt: createdAt,
  );
}
