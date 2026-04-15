import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/domain_models.dart';
import 'screens/admin_shell.dart';
import 'screens/buyer_shell.dart';
import 'screens/login_screen.dart';
import 'screens/seller_shell.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

class RecycleMarketApp extends StatelessWidget {
  const RecycleMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RecycleLink Refactor',
      theme: AppTheme.light,
      locale: const Locale('fa', 'IR'),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Consumer<AppState>(
        builder: (context, state, _) {
          if (state.currentUser == null) {
            return const LoginScreen();
          }
          switch (state.currentUser!.role) {
            case AppUserRole.seller:
              return const SellerShell();
            case AppUserRole.buyer:
              return const BuyerShell();
            case AppUserRole.admin:
              return const AdminShell();
          }
        },
      ),
    );
  }
}
