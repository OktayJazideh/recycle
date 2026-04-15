import 'package:uuid/uuid.dart';

enum OfferStatus { pending, accepted, rejected, expired }

class OfferModel {
  final String id;
  final String requestId;
  final String buyerId;
  final String buyerName;
  final double offeredPrice;
  final String message;
  final OfferStatus status;
  final double buyerRating;
  final int buyerCompletedOrders;
  final double distance;
  final DateTime createdAt;

  OfferModel({
    String? id,
    required this.requestId,
    required this.buyerId,
    required this.buyerName,
    required this.offeredPrice,
    this.message = '',
    this.status = OfferStatus.pending,
    this.buyerRating = 0.0,
    this.buyerCompletedOrders = 0,
    this.distance = 0.0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'requestId': requestId, 'buyerId': buyerId,
    'buyerName': buyerName, 'offeredPrice': offeredPrice,
    'message': message, 'status': status.name,
    'buyerRating': buyerRating,
    'buyerCompletedOrders': buyerCompletedOrders,
    'distance': distance,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OfferModel.fromMap(Map<String, dynamic> map) => OfferModel(
    id: map['id'], requestId: map['requestId'] ?? '',
    buyerId: map['buyerId'] ?? '', buyerName: map['buyerName'] ?? '',
    offeredPrice: (map['offeredPrice'] as num?)?.toDouble() ?? 0.0,
    message: map['message'] ?? '',
    status: OfferStatus.values.firstWhere((e) => e.name == map['status'], orElse: () => OfferStatus.pending),
    buyerRating: (map['buyerRating'] as num?)?.toDouble() ?? 0.0,
    buyerCompletedOrders: map['buyerCompletedOrders'] ?? 0,
    distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
    createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
  );

  OfferModel copyWith({OfferStatus? status}) => OfferModel(
    id: id, requestId: requestId, buyerId: buyerId,
    buyerName: buyerName, offeredPrice: offeredPrice,
    message: message, status: status ?? this.status,
    buyerRating: buyerRating, buyerCompletedOrders: buyerCompletedOrders,
    distance: distance, createdAt: createdAt,
  );
}
