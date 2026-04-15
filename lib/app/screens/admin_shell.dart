import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'shared_screens.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: GradientHeader(
              title: 'پنل مدیریت',
              subtitle: 'لیست پایین، تنظیمات و خروجی‌ها با SafeArea بازطراحی شدند تا هیچ دکمه‌ای با نوار سیستم هم‌پوشانی نداشته باشد.',
              leading: IconButton(
                onPressed: () => context.read<AppState>().logout(),
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: <Widget>[
                      StatTile(label: 'کاربران فعال', value: state.adminStats['کاربران فعال']!, icon: Icons.people_alt_rounded, color: AppPalette.forest),
                      StatTile(label: 'درخواست‌های فعال', value: state.adminStats['درخواست‌های فعال']!, icon: Icons.inventory_2_rounded, color: AppPalette.info),
                      StatTile(label: 'تیکت باز', value: state.adminStats['تیکت باز']!, icon: Icons.support_agent_rounded, color: AppPalette.warning),
                      StatTile(label: 'گردش مالی', value: state.adminStats['گردش مالی']!, icon: Icons.paid_rounded, color: AppPalette.clay),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const ScreenSectionTitle(title: 'بخش‌ها'),
                  const SizedBox(height: 10),
                  _menuTile(
                    context,
                    title: 'مدیریت کاربران',
                    icon: Icons.group_rounded,
                    color: AppPalette.forest,
                    onTap: () => _openSimplePage(context, 'مدیریت کاربران'),
                  ),
                  _menuTile(
                    context,
                    title: 'مدیریت سفارش‌ها',
                    icon: Icons.receipt_long_rounded,
                    color: AppPalette.info,
                    onTap: () => _openSimplePage(context, 'مدیریت سفارش‌ها'),
                  ),
                  _menuTile(
                    context,
                    title: 'کامنت‌های مخفی',
                    icon: Icons.comment_bank_rounded,
                    color: AppPalette.clay,
                    onTap: () => _openSimplePage(context, 'کامنت‌های مخفی'),
                  ),
                  _menuTile(
                    context,
                    title: 'مدیریت مقالات',
                    icon: Icons.article_rounded,
                    color: AppPalette.moss,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ArticlesPlaceholderScreen())),
                  ),
                  _menuTile(
                    context,
                    title: 'مدیریت تیکت‌ها',
                    icon: Icons.support_agent_rounded,
                    color: AppPalette.warning,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SupportTicketsScreen(title: 'مدیریت تیکت‌ها', asAdmin: true))),
                  ),
                  _menuTile(
                    context,
                    title: 'تنظیمات',
                    icon: Icons.settings_rounded,
                    color: AppPalette.textSecondary,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AdminSettingsScreen())),
                  ),
                  _menuTile(
                    context,
                    title: 'گزارش‌گیری (CSV)',
                    icon: Icons.download_rounded,
                    color: AppPalette.forestDark,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AdminReportsScreen())),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  void _openSimplePage(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => OrdersPlaceholderScreen(title: title),
      ),
    );
  }
}

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _priceControllers = <String, TextEditingController>{};
  late TextEditingController _commissionController;
  late TextEditingController _distanceController;
  bool _demoMode = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    for (final category in state.categories) {
      _priceControllers[category.id] = TextEditingController(text: category.pricePerKg.toString());
    }
    _commissionController = TextEditingController(text: state.settings.commissionPercent.toStringAsFixed(1));
    _distanceController = TextEditingController(text: state.settings.maxDistanceKm.toStringAsFixed(0));
    _demoMode = state.settings.demoModeEnabled;
  }

  @override
  void dispose() {
    for (final controller in _priceControllers.values) {
      controller.dispose();
    }
    _commissionController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: <Color>[AppPalette.forest, AppPalette.clay]),
          ),
        ),
      ),
      bottomNavigationBar: ActionBottomBar(
        child: ElevatedButton.icon(
          onPressed: state.isSavingSettings
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  final prices = <String, int>{
                    for (final entry in _priceControllers.entries)
                      entry.key: int.tryParse(entry.value.text.trim()) ?? 0,
                  };
                  final success = await context.read<AppState>().saveAdminSettings(
                        commissionPercent: double.tryParse(_commissionController.text.trim()) ?? 0,
                        maxDistanceKm: double.tryParse(_distanceController.text.trim()) ?? 10,
                        demoModeEnabled: _demoMode,
                        categoryPrices: prices,
                      );
                  if (!mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success ? 'تنظیمات ذخیره شد.' : 'ذخیره تنظیمات ناموفق بود.')),
                  );
                },
          icon: state.isSavingSettings
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_rounded),
          label: Text(state.isSavingSettings ? 'در حال ذخیره...' : 'ذخیره تنظیمات'),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: <Widget>[
              TextFormField(
                controller: _commissionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'کارمزد تراکنش (%)',
                  prefixIcon: Icon(Icons.percent_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _distanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'حداکثر فاصله (کیلومتر)',
                  prefixIcon: Icon(Icons.social_distance_rounded),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: _demoMode,
                onChanged: (value) => setState(() => _demoMode = value),
                title: const Text('حالت دمو'),
                subtitle: const Text('برای تست نمایشی بدون نیاز به سرویس بیرونی'),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),
              const ScreenSectionTitle(title: 'قیمت پایه ضایعات (تومان / کیلو)'),
              const SizedBox(height: 10),
              ...state.categories.map((category) {
                final controller = _priceControllers[category.id]!;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'این فیلد را تکمیل کنید';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: category.title,
                      prefixIcon: Icon(iconFromName(category.iconName), color: category.color),
                      helperText: category.isProtected ? 'دسته‌بندی محافظت‌شده: قابل حذف نیست.' : 'قابل ویرایش و همگام‌سازی با API',
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('گزارش‌گیری', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: <Color>[AppPalette.forest, AppPalette.clay]),
          ),
        ),
      ),
      bottomNavigationBar: const ActionBottomBar(
        child: ElevatedButton.icon(
          onPressed: null,
          icon: Icon(Icons.file_download_done_rounded),
          label: Text('خروجی CSV در نسخه سرور فعال می‌شود'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: const <Widget>[
          EmptyStateCard(
            title: 'بخش گزارش‌گیری از نوار سیستم فاصله گرفت',
            subtitle: 'خروجی CSV به‌صورت یک اکشن چسبان ولی ایمن در پایین صفحه قرار گرفته است.',
            icon: Icons.assessment_rounded,
          ),
        ],
      ),
    );
  }
}
