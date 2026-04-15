import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/domain_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'shared_screens.dart';

class SellerShell extends StatefulWidget {
  const SellerShell({super.key});

  @override
  State<SellerShell> createState() => _SellerShellState();
}

class _SellerShellState extends State<SellerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const SellerDashboardPage(),
      const OrdersPlaceholderScreen(title: 'سفارش‌های فروشنده'),
      const ArticlesPlaceholderScreen(),
      const SupportTicketsScreen(title: 'پشتیبانی', asAdmin: false),
      const CommonProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const <NavigationDestination>[
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'خانه'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long_rounded), label: 'سفارش‌ها'),
            NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article_rounded), label: 'مقالات'),
            NavigationDestination(icon: Icon(Icons.support_agent_outlined), selectedIcon: Icon(Icons.support_agent_rounded), label: 'پشتیبانی'),
            NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'پروفایل'),
          ],
        ),
      ),
    );
  }
}

class SellerDashboardPage extends StatelessWidget {
  const SellerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final seller = state.sellerDemo;
    final sellerRequests = state.sellerRequests;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: GradientHeader(
            title: '👋 سلام ${seller.name}',
            subtitle: 'هدر فشرده شد، رنگ‌ها ملایم شدند و دکمه اصلی ثبت درخواست از حالت FAB به اکشن مرکزی منتقل شد.',
            leading: IconButton(
              onPressed: () => context.read<AppState>().logout(),
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: StatTile(
                        label: 'درخواست فعال',
                        value: '${sellerRequests.length}',
                        icon: Icons.inventory_2_rounded,
                        color: AppPalette.clay,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        label: 'امتیاز',
                        value: seller.rating.toStringAsFixed(1),
                        icon: Icons.star_rounded,
                        color: AppPalette.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        label: 'تکمیل‌شده',
                        value: '${seller.completedOrders}',
                        icon: Icons.check_circle_rounded,
                        color: AppPalette.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const ScreenSectionTitle(title: 'اقدام اصلی'),
                      const SizedBox(height: 8),
                      const Text(
                        'به‌جای FAB شناور، دکمه ثبت درخواست در مرکز محتوا قرار گرفت تا با نوار پایین تداخل نداشته باشد.',
                        style: TextStyle(color: AppPalette.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const CreateRequestScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        label: const Text('ثبت درخواست جدید'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const ScreenSectionTitle(title: 'آخرین درخواست‌ها'),
                const SizedBox(height: 10),
                if (sellerRequests.isEmpty)
                  const EmptyStateCard(
                    title: 'درخواستی ثبت نشده است',
                    subtitle: 'برای شروع، از دکمه اصلی بالا استفاده کنید.',
                  )
                else
                  ...sellerRequests.map(
                    (request) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RequestCard(
                        request: request,
                        category: state.categoryById(request.categoryId),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _localImages = <String>[];
  String? _selectedCategoryId;
  String? _selectedQuantityId;
  bool _urgent = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _addressController.text = state.sellerDemo.address;
    if (state.categories.isNotEmpty) {
      _selectedCategoryId = state.categories.first.id;
    }
    if (state.quantityOptions.isNotEmpty) {
      _selectedQuantityId = state.quantityOptions.first.id;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ثبت درخواست جدید', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: <Color>[AppPalette.forest, AppPalette.clay]),
          ),
        ),
      ),
      bottomNavigationBar: ActionBottomBar(
        child: ElevatedButton.icon(
          onPressed: state.isSubmittingRequest
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  if (_selectedCategoryId == null || _selectedQuantityId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('دسته‌بندی و مقدار تقریبی را انتخاب کنید.')),
                    );
                    return;
                  }
                  final success = await context.read<AppState>().submitRecycleRequest(
                        categoryId: _selectedCategoryId!,
                        quantityId: _selectedQuantityId!,
                        address: _addressController.text.trim(),
                        description: _descriptionController.text.trim(),
                        urgent: _urgent,
                      );
                  if (!mounted) {
                    return;
                  }
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('درخواست با موفقیت ثبت شد.')),
                    );
                    Navigator.of(context).pop();
                  }
                },
          icon: state.isSubmittingRequest
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_rounded),
          label: Text(state.isSubmittingRequest ? 'در حال ثبت...' : 'ثبت درخواست'),
        ),
      ),
      body: SafeArea(
        child: state.categories.isEmpty || state.quantityOptions.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: const <Widget>[
                  EmptyStateCard(
                    title: 'داده پیکربندی یافت نشد',
                    subtitle: 'اگر API پاسخ ندهد، ساختار فرم باید از بک‌اند بارگذاری شود.',
                  ),
                ],
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  children: <Widget>[
                    const ScreenSectionTitle(title: 'نوع ضایعات'),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 520 ? 3 : 2;
                        return GridView.builder(
                          itemCount: state.categories.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: 1.35,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemBuilder: (context, index) {
                            final category = state.categories[index];
                            final selected = _selectedCategoryId == category.id;
                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => setState(() => _selectedCategoryId = category.id),
                              child: Ink(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: selected ? category.color.withOpacity(0.14) : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected ? category.color : AppPalette.border,
                                    width: selected ? 1.8 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(iconFromName(category.iconName), color: category.color, size: 28),
                                    const SizedBox(height: 10),
                                    Text(
                                      category.title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: selected ? category.color : AppPalette.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const ScreenSectionTitle(title: 'مقدار تقریبی'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.quantityOptions.map((option) {
                        final selected = _selectedQuantityId == option.id;
                        return ChoiceChip(
                          label: Text(option.label),
                          selected: selected,
                          labelStyle: TextStyle(color: selected ? Colors.white : AppPalette.textPrimary),
                          onSelected: (_) => setState(() => _selectedQuantityId = option.id),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: SwitchListTile.adaptive(
                            value: _urgent,
                            onChanged: (value) => setState(() => _urgent = value),
                            title: const Text('اولویت فوری'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      validator: (value) => value == null || value.trim().isEmpty ? 'آدرس را وارد کنید' : null,
                      decoration: const InputDecoration(
                        labelText: 'آدرس محل',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'توضیحات تکمیلی',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ScreenSectionTitle(title: 'تصاویر (اختیاری)'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            if (_localImages.length >= 3) {
                              return;
                            }
                            setState(() => _localImages.add('assets/images/request_placeholder_${_localImages.length + 1}.png'));
                          },
                          child: Ink(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: AppPalette.sage,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppPalette.border),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.camera_alt_outlined, color: AppPalette.forest),
                                SizedBox(height: 4),
                                Text('افزودن عکس', style: TextStyle(fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        ..._localImages.map(
                          (item) => Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppPalette.border),
                            ),
                            child: Stack(
                              children: <Widget>[
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Text(item, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10)),
                                  ),
                                ),
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: InkWell(
                                    onTap: () => setState(() => _localImages.remove(item)),
                                    child: Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        color: AppPalette.danger,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
