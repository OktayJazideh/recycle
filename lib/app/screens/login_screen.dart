import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/domain_models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      body: state.isBootstrapping
          ? const DashboardShimmer()
          : state.bootstrapError != null
              ? Center(child: Text(state.bootstrapError!))
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[AppPalette.forestDark, AppPalette.forest, AppPalette.clay],
                    ),
                  ),
                  child: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: <Widget>[
                        const SizedBox(height: 28),
                        Container(
                          width: 96,
                          height: 96,
                          margin: const EdgeInsets.only(bottom: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: const Icon(Icons.recycling_rounded, color: AppPalette.forest, size: 52),
                        ),
                        const Text(
                          'RecycleLink',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'UI/UX overhaul demo',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Text(
                                'Demo access',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppPalette.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Admin phone: 09120000000 · Demo OTP: 1234',
                                style: TextStyle(color: AppPalette.textSecondary),
                              ),
                              const SizedBox(height: 18),
                              _loginTile(
                                context,
                                title: 'Seller flow',
                                subtitle: 'Create request + safe area compliant submit action',
                                icon: Icons.storefront_rounded,
                                color: AppPalette.forest,
                                onTap: () => context.read<AppState>().loginAs(AppUserRole.seller),
                              ),
                              const SizedBox(height: 12),
                              _loginTile(
                                context,
                                title: 'Collector flow',
                                subtitle: 'Muted header, dynamic category colors, friendly greeting',
                                icon: Icons.local_shipping_rounded,
                                color: AppPalette.clay,
                                onTap: () => context.read<AppState>().loginAs(AppUserRole.buyer),
                              ),
                              const SizedBox(height: 12),
                              _loginTile(
                                context,
                                title: 'Admin panel',
                                subtitle: 'Editable prices, protected categories, safe CSV/report area',
                                icon: Icons.admin_panel_settings_rounded,
                                color: AppPalette.info,
                                onTap: () => context.read<AppState>().loginAs(AppUserRole.admin),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _loginTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.16)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppPalette.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppPalette.textSecondary),
          ],
        ),
      ),
    );
  }
}
