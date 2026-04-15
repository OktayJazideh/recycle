import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/recycle_market_app.dart';
import 'app/repositories/marketplace_repository.dart';
import 'app/state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = HybridMarketplaceRepository(
    apiBaseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://10.0.2.2:8080',
    ),
  );

  final appState = AppState(repository)..bootstrap();

  runApp(
    ChangeNotifierProvider<AppState>.value(
      value: appState,
      child: const RecycleMarketApp(),
    ),
  );
}
