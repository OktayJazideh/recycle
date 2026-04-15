import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/app_data_service.dart';
import '../seller/seller_home_screen.dart';
import '../buyer/buyer_home_screen.dart';
import '../admin/admin_home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  bool _otpSent = false;
  UserRole _selectedRole = UserRole.seller;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeInOut);
    _animController.forward();
  }

  @override
  void dispose() { _animController.dispose(); _phoneController.dispose(); _otpController.dispose(); _nameController.dispose(); super.dispose(); }

  void _sendOtp() {
    if (_phoneController.text.length < 10) {
      _showSnack('لطفا شماره موبایل معتبر وارد کنید');
      return;
    }
    setState(() { _isLoading = true; });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() { _isLoading = false; _otpSent = true; });
      _showSnack('کد تأیید: 1234 (حالت آزمایشی)');
    });
  }

  void _verifyOtp() {
    if (_otpController.text != '1234') {
      _showSnack('کد تأیید اشتباه است. کد صحیح: 1234');
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      final ds = AppDataService();
      if (_isLogin) {
        final user = ds.users.firstWhere(
          (u) => u.phone == _phoneController.text,
          orElse: () => ds.users.firstWhere((u) => u.role == UserRole.seller),
        );
        ds.currentUser = user;
        _navigateToHome(user.role);
      } else {
        if (_nameController.text.isEmpty) {
          setState(() => _isLoading = false);
          _showSnack('لطفا نام خود را وارد کنید');
          return;
        }
        final newUser = UserModel(name: _nameController.text, phone: _phoneController.text, role: _selectedRole);
        ds.users.add(newUser);
        ds.currentUser = newUser;
        _navigateToHome(_selectedRole);
      }
    });
  }

  void _quickLogin(UserRole role) {
    final ds = AppDataService();
    final user = ds.users.firstWhere((u) => u.role == role);
    ds.currentUser = user;
    _navigateToHome(role);
  }

  void _navigateToHome(UserRole role) {
    setState(() => _isLoading = false);
    Widget screen;
    switch (role) {
      case UserRole.seller: screen = const SellerHomeScreen();
      case UserRole.buyer: screen = const BuyerHomeScreen();
      case UserRole.admin: screen = const AdminHomeScreen();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg, textDirection: TextDirection.rtl), backgroundColor: AppColors.primaryGreen, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.darkGreen, AppColors.primaryGreen, Color(0xFF43A047)]),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(height: 32),
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)]),
                  child: const Icon(Icons.recycling, size: 56, color: AppColors.primaryGreen),
                ),
                const SizedBox(height: 16),
                const Text('RecycleLink', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
                const SizedBox(height: 4),
                const Text('بازار بازیافت', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 6),
                Text('ضایعاتت رو بفروش، درآمد کسب کن', style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      Expanded(child: _tabButton('ورود', _isLogin, () => setState(() { _isLogin = true; _otpSent = false; }))),
                      const SizedBox(width: 12),
                      Expanded(child: _tabButton('ثبت نام', !_isLogin, () => setState(() { _isLogin = false; _otpSent = false; }))),
                    ]),
                    const SizedBox(height: 20),
                    if (!_isLogin && !_otpSent) ...[
                      TextField(controller: _nameController, textDirection: TextDirection.rtl, decoration: const InputDecoration(labelText: 'نام و نام خانوادگی', prefixIcon: Icon(Icons.person_outline))),
                      const SizedBox(height: 14),
                    ],
                    if (!_otpSent) ...[
                      TextField(controller: _phoneController, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'شماره موبایل', prefixIcon: Icon(Icons.phone_outlined), hintText: '09XX XXX XXXX')),
                      if (!_isLogin) ...[
                        const SizedBox(height: 14),
                        const Text('نقش من:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(child: _roleChip('فروشنده ضایعات', Icons.sell, UserRole.seller)),
                          const SizedBox(width: 8),
                          Expanded(child: _roleChip('جمع\u200cآوری\u200cکننده', Icons.local_shipping, UserRole.buyer)),
                        ]),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(height: 50, child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('دریافت کد تأیید', style: TextStyle(fontSize: 16)),
                      )),
                    ],
                    if (_otpSent) ...[
                      Row(children: [
                        const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Text('کد تأیید به ${_phoneController.text} ارسال شد', style: const TextStyle(fontSize: 13, color: AppColors.primaryGreen)),
                      ]),
                      const SizedBox(height: 14),
                      TextField(controller: _otpController, keyboardType: TextInputType.number, textDirection: TextDirection.ltr, maxLength: 4, decoration: const InputDecoration(labelText: 'کد تأیید (1234)', prefixIcon: Icon(Icons.lock_outline), counterText: '')),
                      const SizedBox(height: 16),
                      SizedBox(height: 50, child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyOtp,
                        child: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_isLogin ? 'ورود' : 'ثبت نام', style: const TextStyle(fontSize: 16)),
                      )),
                      const SizedBox(height: 8),
                      TextButton(onPressed: () => setState(() { _otpSent = false; _otpController.clear(); }), child: const Text('تغییر شماره موبایل')),
                    ],
                  ]),
                ),
                const SizedBox(height: 28),
                Text('ورود سریع (دمو)', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _quickAccessBtn('دمو فروشنده', Icons.sell, () => _quickLogin(UserRole.seller)),
                  const SizedBox(width: 10),
                  _quickAccessBtn('دمو جمع\u200cآوری', Icons.local_shipping, () => _quickLogin(UserRole.buyer)),
                  const SizedBox(width: 10),
                  _quickAccessBtn('مدیر', Icons.admin_panel_settings, () => _quickLogin(UserRole.admin)),
                ]),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(color: active ? AppColors.primaryGreen : AppColors.backgroundGreen, borderRadius: BorderRadius.circular(12)),
      child: Center(child: Text(text, style: TextStyle(color: active ? Colors.white : AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 15))),
    ),
  );

  Widget _roleChip(String label, IconData icon, UserRole role) {
    final selected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(color: selected ? AppColors.primaryGreen : AppColors.backgroundGreen, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.divider)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: selected ? Colors.white : AppColors.primaryGreen),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.primaryGreen, fontWeight: FontWeight.w600, fontSize: 12), overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  Widget _quickAccessBtn(String label, IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.4))),
      child: Row(children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 11)),
      ]),
    ),
  );
}
