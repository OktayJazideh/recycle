import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/app_data_service.dart';
import 'admin_users_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_comments_screen.dart';
import 'admin_articles_screen.dart';
import 'admin_tickets_screen.dart';
import 'admin_settings_screen.dart';
import 'admin_reports_screen.dart';
import '../auth/login_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _ds = AppDataService();

  @override
  Widget build(BuildContext context) {
    final stats = _ds.getStats();

    return Scaffold(
      appBar: AppBar(
        title: const Text('پنل مدیریت'),
        backgroundColor: AppColors.darkGreen,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: () {
            _ds.currentUser = null;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('داشبورد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          // Stats grid
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _statCard('فروشندگان', '${stats['totalSellers']}', Icons.people, AppColors.primaryGreen),
              _statCard('جمع\u200cآوری\u200cکنندگان', '${stats['totalBuyers']}', Icons.local_shipping, AppColors.orange),
              _statCard('سفارش امروز', '${stats['ordersToday']}', Icons.today, AppColors.blue),
              _statCard('سفارش هفته', '${stats['ordersWeek']}', Icons.date_range, AppColors.purple),
              _statCard('تکمیل شده', '${stats['completedOrders']}', Icons.check_circle, AppColors.darkGreen),
              _statCard('تیکت باز', '${stats['openTickets']}', Icons.support, AppColors.red),
              _statCard('درخواست فعال', '${stats['pendingRequests']}', Icons.pending_actions, AppColors.darkOrange),
              _statCard('تراکنش کل', '${((stats['totalTransactions'] as double) / 1000000).toStringAsFixed(1)}M', Icons.monetization_on, AppColors.gold),
            ],
          ),
          const SizedBox(height: 28),
          const Text('بخش\u200cها', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _menuItem('مدیریت کاربران', Icons.people, AppColors.primaryGreen, () => _navigate(const AdminUsersScreen())),
          _menuItem('مدیریت سفارش\u200cها', Icons.receipt_long, AppColors.blue, () => _navigate(const AdminOrdersScreen())),
          _menuItem('کامنت\u200cهای مخفی', Icons.comment, AppColors.purple, () => _navigate(const AdminCommentsScreen())),
          _menuItem('مدیریت مقالات', Icons.article, AppColors.orange, () => _navigate(const AdminArticlesScreen())),
          _menuItem('تیکت\u200cهای پشتیبانی', Icons.support_agent, AppColors.red, () => _navigate(const AdminTicketsScreen())),
          _menuItem('تنظیمات', Icons.settings, AppColors.textSecondary, () => _navigate(const AdminSettingsScreen())),
          _menuItem('گزارش\u200cگیری (CSV)', Icons.download, AppColors.darkGreen, () => _navigate(const AdminReportsScreen())),
        ]),
      ),
    );
  }

  void _navigate(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)).then((_) => setState(() {}));

  Widget _statCard(String label, String value, IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)]),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, color: color, size: 28),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), textAlign: TextAlign.center),
    ]),
  );

  Widget _menuItem(String label, IconData icon, Color color, VoidCallback onTap) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.divider),
      onTap: onTap,
    ),
  );
}
