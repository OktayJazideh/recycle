import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/app_data_service.dart';
import '../../models/order_model.dart';
import '../../models/waste_category.dart';
import '../../models/user_model.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _ds = AppDataService();
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final user = _ds.currentUser!;
    var orders = _ds.getUserOrders(user.id);
    if (_filter != 'all') {
      orders = orders.where((o) => o.orderStatus.name == _filter).toList();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('سفارش\u200cها')),
      body: Column(children: [
        SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              _chip('همه', 'all'),
              _chip('تأیید شده', 'confirmed'),
              _chip('در مسیر', 'buyerOnWay'),
              _chip('تکمیل', 'completed'),
              _chip('لغو', 'cancelled'),
            ],
          ),
        ),
        Expanded(
          child: orders.isEmpty
            ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.receipt_long_outlined, size: 56, color: AppColors.divider),
                SizedBox(height: 12),
                Text('سفارشی یافت نشد', style: TextStyle(color: AppColors.textSecondary)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (_, i) => _orderCard(orders[i], user),
              ),
        ),
      ]),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: AppColors.primaryGreen,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 12),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  Widget _orderCard(OrderModel order, UserModel user) {
    final cat = WasteCategory.getById(order.wasteType);
    final isBuyer = user.role == UserRole.buyer;
    final otherName = isBuyer ? order.sellerName : order.buyerName;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))).then((_) => setState(() {})),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${cat.name} - ${order.quantity}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(isBuyer ? 'فروشنده: $otherName' : 'جمع\u200cآوری: $otherName', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ])),
              _statusBadge(order.orderStatus),
            ]),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [
                const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(order.address, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
              ]),
              Text('${(order.finalPrice / 1000).toStringAsFixed(0)} هزار تومان', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 13)),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _statusBadge(OrderStatus s) {
    Color color; String label;
    switch (s) {
      case OrderStatus.pending: color = AppColors.textSecondary; label = 'در انتظار';
      case OrderStatus.confirmed: color = AppColors.blue; label = 'تأیید شده';
      case OrderStatus.buyerOnWay: color = AppColors.orange; label = 'در مسیر';
      case OrderStatus.arrived: color = AppColors.purple; label = 'رسیدم';
      case OrderStatus.weighing: color = AppColors.darkOrange; label = 'توزین';
      case OrderStatus.completed: color = AppColors.primaryGreen; label = 'تکمیل';
      case OrderStatus.disputed: color = AppColors.red; label = 'اختلاف';
      case OrderStatus.cancelled: color = AppColors.red; label = 'لغو';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
