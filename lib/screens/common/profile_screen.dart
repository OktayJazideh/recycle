import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/app_data_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _ds = AppDataService();
  bool _editing = false;
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    final u = _ds.currentUser!;
    _nameCtrl = TextEditingController(text: u.name);
    _phoneCtrl = TextEditingController(text: u.phone);
    _addressCtrl = TextEditingController(text: u.address);
  }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); _addressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final user = _ds.currentUser!;
    final orders = _ds.getUserOrders(user.id);
    final ratings = _ds.getUserRatings(user.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('پروفایل'),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_editing) {
                final idx = _ds.users.indexWhere((u) => u.id == user.id);
                if (idx >= 0) {
                  _ds.users[idx] = _ds.users[idx].copyWith(name: _nameCtrl.text, phone: _phoneCtrl.text, address: _addressCtrl.text);
                  _ds.currentUser = _ds.users[idx];
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text('پروفایل بروزرسانی شد', textDirection: TextDirection.rtl), backgroundColor: AppColors.primaryGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                );
              }
              setState(() => _editing = !_editing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Avatar
          CircleAvatar(
            radius: 50,
            backgroundColor: user.role == UserRole.seller ? AppColors.primaryGreen : AppColors.orange,
            child: Text(user.name.isNotEmpty ? user.name[0] : '?', style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          if (!_editing) ...[
            Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(user.role == UserRole.seller ? 'فروشنده' : 'جمع\u200cآوری\u200cکننده', style: const TextStyle(color: AppColors.textSecondary)),
          ],
          const SizedBox(height: 20),
          // Stats row
          Row(children: [
            _stat('سفارش\u200cها', '${orders.length}', Icons.receipt_long, AppColors.blue),
            const SizedBox(width: 12),
            _stat('امتیاز', user.ratingAvg.toStringAsFixed(1), Icons.star, AppColors.gold),
            const SizedBox(width: 12),
            _stat('نظرات', '${ratings.length}', Icons.comment, AppColors.purple),
          ]),
          const SizedBox(height: 24),
          if (_editing) ...[
            TextField(controller: _nameCtrl, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'نام', prefixIcon: Icon(Icons.person))),
            const SizedBox(height: 12),
            TextField(controller: _phoneCtrl, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'شماره تلفن', prefixIcon: Icon(Icons.phone))),
            const SizedBox(height: 12),
            TextField(controller: _addressCtrl, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'آدرس', prefixIcon: Icon(Icons.location_on))),
          ] else ...[
            _profileItem(Icons.phone, 'شماره تلفن', user.phone),
            _profileItem(Icons.location_on, 'آدرس', user.address.isNotEmpty ? user.address : 'ثبت نشده'),
            if (user.vehicleInfo != null) _profileItem(Icons.local_shipping, 'وسیله نقلیه', user.vehicleInfo!),
            if (user.workingHours != null) _profileItem(Icons.schedule, 'ساعت کاری', user.workingHours!),
            _profileItem(Icons.verified, 'وضعیت تأیید', user.isVerified ? 'تأیید شده' : 'تأیید نشده'),
          ],
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.red)),
            onPressed: () {
              _ds.currentUser = null;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            icon: const Icon(Icons.logout),
            label: const Text('خروج از حساب'),
          )),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _stat(String label, String value, IconData icon, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 8)]),
      child: Column(children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ),
  );

  Widget _profileItem(IconData icon, String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(icon, size: 20, color: AppColors.primaryGreen),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      const Spacer(),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
    ]),
  );
}
