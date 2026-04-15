import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/domain_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class OrdersPlaceholderScreen extends StatelessWidget {
  const OrdersPlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: <Color>[AppPalette.forest, AppPalette.clay]),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          EmptyStateCard(
            title: 'ماژول سفارش‌ها آماده توسعه سمت API است',
            subtitle: 'لیست، فیلتر وضعیت، جزئیات و وضعیت پرداخت در این ساختار به‌صورت ماژولار قابل اتصال هستند.',
            icon: Icons.receipt_long_rounded,
          ),
        ],
      ),
    );
  }
}

class ArticlesPlaceholderScreen extends StatelessWidget {
  const ArticlesPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مقالات', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: <Color>[AppPalette.forest, AppPalette.clay]),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const <Widget>[
          EmptyStateCard(
            title: 'کتابخانه محتوایی به ساختار جدید منتقل شد',
            subtitle: 'در نسخه بعدی می‌توانید مقاله‌ها را از پنل مدیریت منتشر و زمان‌بندی کنید.',
            icon: Icons.article_outlined,
          ),
        ],
      ),
    );
  }
}

class CommonProfileScreen extends StatefulWidget {
  const CommonProfileScreen({super.key});

  @override
  State<CommonProfileScreen> createState() => _CommonProfileScreenState();
}

class _CommonProfileScreenState extends State<CommonProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppState>().currentUser!;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentUser!;
    final category = state.categoryById(user.preferredCategoryId);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: GradientHeader(
              title: 'پروفایل من',
              subtitle: 'بخش امتیاز، تصویر و خروج حساب جمع‌وجور شد تا صفحه بالاتر و تمیزتر دیده شود.',
              backgroundColor: category.color,
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              ),
              trailing: IconButton(
                onPressed: () => setState(() => _editing = !_editing),
                icon: Icon(
                  _editing ? Icons.check_rounded : Icons.edit_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                <Widget>[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppPalette.border),
                    ),
                    child: Column(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppPalette.lightGreenAvatar,
                          child: Text(
                            user.name.characters.first,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: category.color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.role == AppUserRole.buyer ? 'جمع‌آور تأییدشده' : 'فروشنده فعال',
                          style: const TextStyle(color: AppPalette.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: StatTile(
                                label: 'امتیاز',
                                value: user.rating.toStringAsFixed(1),
                                icon: Icons.star_rounded,
                                color: AppPalette.gold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatTile(
                                label: 'سفارش تکمیل‌شده',
                                value: '${user.completedOrders}',
                                icon: Icons.receipt_long_rounded,
                                color: AppPalette.info,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatTile(
                                label: 'امتیاز وفاداری',
                                value: '${user.points}',
                                icon: Icons.workspace_premium_rounded,
                                color: category.color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_editing) ...<Widget>[
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'نام'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(labelText: 'شماره موبایل'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'آدرس'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AppState>().updateCurrentUserProfile(
                              name: _nameController.text.trim(),
                              phone: _phoneController.text.trim(),
                              address: _addressController.text.trim(),
                            );
                        setState(() => _editing = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('اطلاعات پروفایل ذخیره شد.')),
                        );
                      },
                      child: const Text('ذخیره اطلاعات'),
                    ),
                  ] else ...<Widget>[
                    _profileItem(Icons.phone_rounded, 'شماره تماس', user.phone),
                    _profileItem(Icons.location_on_rounded, 'آدرس', user.address),
                    if (user.vehicleInfo != null)
                      _profileItem(Icons.local_shipping_rounded, 'وسیله نقلیه', user.vehicleInfo!),
                    if (user.workingHours != null)
                      _profileItem(Icons.schedule_rounded, 'ساعت کاری', user.workingHours!),
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppPalette.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const ScreenSectionTitle(title: 'نمونه‌کار و قبل / بعد'),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: user.portfolioImages.isEmpty
                                ? const <Widget>[
                                    Chip(label: Text('assets/images/portfolio_placeholder.png')),
                                  ]
                                : user.portfolioImages
                                    .map((item) => Chip(label: Text(item)))
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => context.read<AppState>().logout(),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('خروج از حساب'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, color: AppPalette.forest),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppPalette.textSecondary)),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({
    super.key,
    required this.title,
    required this.asAdmin,
  });

  final String title;
  final bool asAdmin;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.tickets;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: <Color>[AppPalette.forest, AppPalette.clay]),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ticket = items[index];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(ticket.title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(ticket.preview, style: const TextStyle(color: AppPalette.textSecondary)),
              ),
              trailing: TicketStatusChip(status: ticket.status),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TicketThreadScreen(ticketId: ticket.id, asAdmin: asAdmin),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TicketThreadScreen extends StatefulWidget {
  const TicketThreadScreen({
    super.key,
    required this.ticketId,
    required this.asAdmin,
  });

  final String ticketId;
  final bool asAdmin;

  @override
  State<TicketThreadScreen> createState() => _TicketThreadScreenState();
}

class _TicketThreadScreenState extends State<TicketThreadScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final ticket = state.tickets.firstWhere((item) => item.id == widget.ticketId);
    final media = MediaQuery.of(context);
    final composerBottomPadding = media.viewInsets.bottom > 0
        ? media.viewInsets.bottom + 8
        : math.max(12, media.padding.bottom + 8);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(ticket.title, style: const TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: <Color>[AppPalette.forest, AppPalette.clay]),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: <Widget>[
                  TicketStatusChip(status: ticket.status),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ورودی پیام و دکمه ارسال کاملاً بالای کیبورد و نوار ناوبری نگه داشته می‌شود.',
                      style: const TextStyle(fontSize: 12, color: AppPalette.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: ticket.messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final message = ticket.messages[index];
                  final mine = widget.asAdmin ? message.isAdmin : !message.isAdmin;
                  return Align(
                    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: media.size.width * 0.78),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: mine ? AppPalette.sage : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppPalette.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            message.senderName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppPalette.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(message.body),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.fromLTRB(12, 8, 12, composerBottomPadding),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'پیام خود را بنویسید',
                        prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _sending
                          ? null
                          : () async {
                              final text = _controller.text.trim();
                              if (text.isEmpty) {
                                return;
                              }
                              setState(() => _sending = true);
                              await context.read<AppState>().sendTicketReply(
                                    ticketId: ticket.id,
                                    text: text,
                                    isAdmin: widget.asAdmin,
                                  );
                              _controller.clear();
                              if (mounted) {
                                setState(() => _sending = false);
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (_scrollController.hasClients) {
                                    _scrollController.animateTo(
                                      _scrollController.position.maxScrollExtent + 80,
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: _sending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
