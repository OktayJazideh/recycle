import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'shared_screens.dart';

class BuyerShell extends StatefulWidget {
  const BuyerShell({super.key});

  @override
  State<BuyerShell> createState() => _BuyerShellState();
}

class _BuyerShellState extends State<BuyerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const BuyerDashboardPage(),
      const OrdersPlaceholderScreen(title: 'سفارش‌های جمع‌آور'),
      const ArticlesPlaceholderScreen(),
      const SupportTicketsScreen(title: 'تیکت‌های پشتیبانی', asAdmin: false),
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

class BuyerDashboardPage extends StatelessWidget {
  const BuyerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final buyer = state.buyerDemo;
    final accent = state.categoryById(buyer.preferredCategoryId);
    final nearbyRequests = state.buyerNearbyRequests;

    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: GradientHeader(
            title: '👋 سلام ${buyer.name}',
            subtitle: 'رنگ هدر از نارنجی تند به طیف سبز/قهوه‌ای ملایم تغییر کرد و رنگ المان‌ها از دسته‌بندی انتخابی تبعیت می‌کند.',
            backgroundColor: accent.color,
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
                        label: 'امتیاز',
                        value: buyer.rating.toStringAsFixed(1),
                        icon: Icons.star_rounded,
                        color: AppPalette.gold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        label: 'سفارش فعال',
                        value: '3',
                        icon: Icons.loop_rounded,
                        color: AppPalette.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        label: 'درخواست نزدیک',
                        value: '${nearbyRequests.length}',
                        icon: Icons.location_on_rounded,
                        color: accent.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const ScreenSectionTitle(title: 'درخواست‌های نزدیک شما'),
                const SizedBox(height: 10),
                ...nearbyRequests.map(
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
