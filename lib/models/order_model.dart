import 'package:uuid/uuid.dart';

enum OrderStatus { pending, confirmed, buyerOnWay, arrived, weighing, completed, disputed, cancelled }
enum PaymentStatus { pending, paid, confirmed, refunded }

class OrderModel {
  final String id;
  final String requestId;
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;
  final String wasteType;
  final String quantity;
  final double finalPrice;
  final String paymentType;
  final PaymentStatus paymentStatus;
  final OrderStatus orderStatus;
  final String address;
  final DateTime scheduledTime;
  final DateTime createdAt;
  final DateTime? completedAt;

  OrderModel({
    String? id,
    required this.requestId,
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    required this.wasteType,
    required this.quantity,
    required this.finalPrice,
    required this.paymentType,
    this.paymentStatus = PaymentStatus.pending,
    this.orderStatus = OrderStatus.pending,
    required this.address,
    required this.scheduledTime,
    DateTime? createdAt,
    this.completedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
    'id': id, 'requestId': requestId, 'sellerId': sellerId,
    'sellerName': sellerName, 'buyerId': buyerId,
    'buyerName': buyerName, 'wasteType': wasteType,
    'quantity': quantity, 'finalPrice': finalPrice,
    'paymentType': paymentType, 'paymentStatus': paymentStatus.name,
    'orderStatus': orderStatus.name, 'address': address,
    'scheduledTime': scheduledTime.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
    id: map['id'], requestId: map['requestId'] ?? '',
    sellerId: map['sellerId'] ?? '', sellerName: map['sellerName'] ?? '',
    buyerId: map['buyerId'] ?? '', buyerName: map['buyerName'] ?? '',
    wasteType: map['wasteType'] ?? '', quantity: map['quantity'] ?? '',
    finalPrice: (map['finalPrice'] as num?)?.toDouble() ?? 0.0,
    paymentType: map['paymentType'] ?? 'cash',
    paymentStatus: PaymentStatus.values.firstWhere((e) => e.name == map['paymentStatus'], orElse: () => PaymentStatus.pending),
    orderStatus: OrderStatus.values.firstWhere((e) => e.name == map['orderStatus'], orElse: () => OrderStatus.pending),
    address: map['address'] ?? '',
    scheduledTime: DateTime.parse(map['scheduledTime']),
    createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    completedAt: map['completedAt'] != null ? DateTime.parse(map['completedAt']) : null,
  );

  OrderModel copyWith({
    OrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
    DateTime? completedAt,
  }) => OrderModel(
    id: id, requestId: requestId, sellerId: sellerId,
    sellerName: sellerName, buyerId: buyerId, buyerName: buyerName,
    wasteType: wasteType, quantity: quantity, finalPrice: finalPrice,
    paymentType: paymentType,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    orderStatus: orderStatus ?? this.orderStatus,
    address: address, scheduledTime: scheduledTime,
    createdAt: createdAt, completedAt: completedAt ?? this.completedAt,
  );
}
