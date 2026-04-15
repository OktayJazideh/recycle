import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/app_data_service.dart';
import '../../models/scrap_request.dart';
import '../../models/offer_model.dart';
import '../../models/waste_category.dart';
import 'nearby_requests_screen.dart';
import '../common/orders_screen.dart';
import '../common/profile_screen.dart';
import '../common/notifications_screen.dart';
import '../articles/articles_screen.dart';
import '../support/support_screen.dart';
import '../auth/login_screen.dart';

class BuyerHomeScreen extends StatefulWidget {
  const BuyerHomeScreen({super.key});
  @override
  State<BuyerHomeScreen> createState() => _BuyerHomeScreenState();
}

class _BuyerHomeScreenState extends State<BuyerHomeScreen> {
  int _currentIndex = 0;
  final _ds = AppDataService();

  @override
  Widget build(BuildContext context) {
    final pages = [_buildHome(), const OrdersScreen(), const ArticlesScreen(), const SupportScreen(), const ProfileScreen()];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'خانه'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'سفارش\u200cها'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'مقالات'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_outlined), activeIcon: Icon(Icons.support_agent), label: 'پشتیبانی'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'پروفایل'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    final user = _ds.currentUser!;
    final nearby = _ds.getNearbyRequests(user.latitude, user.longitude);
    final myOrders = _ds.getUserOrders(user.id);
    final unreadCount = _ds.getUnreadCount(user.id);

    return CustomScrollView(slivers: [
      SliverAppBar(
        expandedHeight: 140, pinned: true,
        backgroundColor: AppColors.orange,
        leading: IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
        actions: [
          Stack(children: [
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())).then((_) => setState(() {}))),
            if (unreadCount > 0) Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle), child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10)))),
          ]),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.darkOrange, AppColors.orange])),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('سلام ${user.name}!', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${user.completedOrders} سفارش تکمیل شده | امتیاز: ${user.ratingAvg.toStringAsFixed(1)}', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
              ]),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _statCard('درخواست نزدیک', '${nearby.length}', Icons.location_on, AppColors.orange),
            const SizedBox(width: 12),
            _statCard('سفارش فعال', '${myOrders.where((o) => o.orderStatus.name != 'completed' && o.orderStatus.name != 'cancelled').length}', Icons.pending, AppColors.blue),
            const SizedBox(width: 12),
            _statCard('امتیاز', user.ratingAvg.toStringAsFixed(1), Icons.star, AppColors.gold),
          ]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('درخواست\u200cهای نزدیک شما', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            TextButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NearbyRequestsScreen())).then((_) => setState(() {})),
              icon: const Icon(Icons.map, size: 18), label: const Text('نقشه'),
            ),
          ]),
          const SizedBox(height: 8),
          if (nearby.isEmpty)
            _emptyState('درخواستی در نزدیکی شما نیست', 'صبر کنید تا درخواست جدیدی ثبت شود')
          else
            ...nearby.take(8).map((r) => _requestCard(r)),
        ]),
      )),
    ]);
  }

  Widget _statCard(String label, String value, IconData icon, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)]),
      child: Column(children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
      ]),
    ),
  );

  Widget _requestCard(ScrapRequest r) {
    final cat = WasteCategory.getById(r.wasteType);
    final user = _ds.currentUser!;
    final dist = _calcDistance(r.latitude, r.longitude, user.latitude, user.longitude);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showOfferDialog(r),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(cat.icon, color: cat.color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                if (r.urgency == UrgencyType.urgent) Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Text('فوری', style: TextStyle(fontSize: 10, color: AppColors.red, fontWeight: FontWeight.bold)),
                ),
              ]),
              Text('${r.quantity} | ${r.sellerName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              Text(r.address, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${dist.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.orange, fontSize: 13)),
              if (r.estimatedPrice != null) Text('~${(r.estimatedPrice! / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.divider),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showOfferDialog(ScrapRequest r) {
    final priceController = TextEditingController(text: ((r.estimatedPrice ?? 100000) / 1000).toStringAsFixed(0));
    final msgController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('ارسال پیشنهاد برای ${r.sellerName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          TextField(controller: priceController, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'قیمت پیشنهادی (هزار تومان)', prefixIcon: Icon(Icons.monetization_on_outlined), suffixText: 'هزار تومان')),
          const SizedBox(height: 12),
          TextField(controller: msgController, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'پیام (اختیاری)', prefixIcon: Icon(Icons.message_outlined))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange),
            onPressed: () {
              final price = double.tryParse(priceController.text) ?? 0;
              if (price <= 0) return;
              final user = _ds.currentUser!;
              _ds.addOffer(OfferModel(
                requestId: r.id, buyerId: user.id, buyerName: user.name,
                offeredPrice: price * 1000,
                message: msgController.text.isNotEmpty ? msgController.text : 'آماده جمع\u200cآوری هستم',
                buyerRating: user.ratingAvg,
                buyerCompletedOrders: user.completedOrders,
                distance: _calcDistance(r.latitude, r.longitude, user.latitude, user.longitude),
              ));
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('پیشنهاد ارسال شد!', textDirection: TextDirection.rtl), backgroundColor: AppColors.orange, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              );
            },
            icon: const Icon(Icons.send),
            label: const Text('ارسال پیشنهاد'),
          )),
        ]),
      ),
    );
  }

  double _calcDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 - (((lat2 - lat1) * p).cos()) / 2 + (lat1 * p).cos() * (lat2 * p).cos() * (1 - ((lon2 - lon1) * p).cos()) / 2;
    return 12742 * a.asin();
  }

  Widget _emptyState(String title, String subtitle) => Container(
    padding: const EdgeInsets.all(32),
    child: Column(children: [
      Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade300),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
      Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]),
  );
}

extension on double {
  double cos() => _cos(this);
  double asin() => _asin(this);
}

double _cos(double x) {
  double sum = 1.0;
  double term = 1.0;
  for (int i = 1; i <= 20; i++) {
    term *= -x * x / ((2 * i - 1) * (2 * i));
    sum += term;
  }
  return sum;
}

double _asin(double x) {
  if (x.abs() > 1) return x > 0 ? 1.5707963 : -1.5707963;
  double sum = x;
  double term = x;
  for (int i = 1; i <= 20; i++) {
    term *= x * x * (2 * i - 1) * (2 * i - 1) / ((2 * i) * (2 * i + 1));
    sum += term;
  }
  return sum;
}
