import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/app_data_service.dart';
import '../../models/scrap_request.dart';
import '../../models/waste_category.dart';
import 'create_request_screen.dart';
import 'request_offers_screen.dart';
import '../common/orders_screen.dart';
import '../common/profile_screen.dart';
import '../common/notifications_screen.dart';
import '../articles/articles_screen.dart';
import '../support/support_screen.dart';
import '../auth/login_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});
  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
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
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateRequestScreen())).then((_) => setState(() {})),
        icon: const Icon(Icons.add),
        label: const Text('ثبت درخواست'),
      ) : null,
    );
  }

  Widget _buildHome() {
    final user = _ds.currentUser!;
    final myRequests = _ds.getSellerRequests(user.id);
    final activeRequests = myRequests.where((r) => r.status != RequestStatus.completed && r.status != RequestStatus.cancelled).toList();
    final unreadCount = _ds.getUnreadCount(user.id);

    return CustomScrollView(slivers: [
      SliverAppBar(
        expandedHeight: 140, pinned: true, floating: false,
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
        actions: [
          Stack(children: [
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())).then((_) => setState(() {}))),
            if (unreadCount > 0) Positioned(right: 8, top: 8, child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle), child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10)))),
          ]),
        ],
        flexibleSpace: FlexibleSpaceBar(
          background: Container(
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.darkGreen, AppColors.primaryGreen])),
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
          // Quick stats
          Row(children: [
            _statCard('درخواست فعال', '${activeRequests.length}', Icons.pending_actions, AppColors.orange),
            const SizedBox(width: 12),
            _statCard('کل سفارش\u200cها', '${myRequests.length}', Icons.receipt_long, AppColors.blue),
            const SizedBox(width: 12),
            _statCard('امتیاز', user.ratingAvg.toStringAsFixed(1), Icons.star, AppColors.gold),
          ]),
          const SizedBox(height: 24),
          const Text('دسته\u200cبندی ضایعات', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: WasteCategory.categories.length,
              itemBuilder: (_, i) {
                final cat = WasteCategory.categories[i];
                return Container(
                  width: 78, margin: const EdgeInsets.only(left: 8),
                  child: Column(children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                      child: Icon(cat.icon, color: cat.color, size: 28),
                    ),
                    const SizedBox(height: 6),
                    Text(cat.name, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ]),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('درخواست\u200cهای اخیر', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            if (myRequests.isNotEmpty) TextButton(onPressed: () => setState(() => _currentIndex = 1), child: const Text('مشاهده همه')),
          ]),
          const SizedBox(height: 8),
          if (myRequests.isEmpty) _emptyState('هنوز درخواستی ثبت نکرده\u200cاید', 'دکمه ثبت درخواست را بزنید'),
          ...myRequests.take(5).map((r) => _requestCard(r)),
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
    final offerCount = _ds.getRequestOffers(r.id).where((o) => o.status.name == 'pending').length;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (r.status == RequestStatus.pending || r.status == RequestStatus.active) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => RequestOffersScreen(request: r))).then((_) => setState(() {}));
          }
        },
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
              Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text('${r.quantity} - ${r.description}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _statusBadge(r.status),
              if (offerCount > 0) Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('$offerCount پیشنهاد', style: const TextStyle(fontSize: 11, color: AppColors.orange, fontWeight: FontWeight.w600)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _statusBadge(RequestStatus s) {
    Color color; String label;
    switch (s) {
      case RequestStatus.pending: color = AppColors.orange; label = 'در انتظار';
      case RequestStatus.active: color = AppColors.blue; label = 'فعال';
      case RequestStatus.accepted: color = AppColors.primaryGreen; label = 'پذیرفته';
      case RequestStatus.inProgress: color = AppColors.purple; label = 'در حال انجام';
      case RequestStatus.completed: color = AppColors.darkGreen; label = 'تکمیل شده';
      case RequestStatus.cancelled: color = AppColors.red; label = 'لغو شده';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
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
