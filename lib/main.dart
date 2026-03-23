import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/localization/app_locale_scope.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/drive_profit_theme.dart';
import 'core/utils/currency_scope.dart';
import 'features/auth/services/firebase_bootstrap.dart';
import 'features/auth/widgets/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final firebaseBootstrap = await FirebaseBootstrapResult.initialize();
  final currencyController = await CurrencyController.load();
  final localeController = await AppLocaleController.load();

  runApp(
    DriveProfitApp(
      currencyController: currencyController,
      localeController: localeController,
      firebaseBootstrap: firebaseBootstrap,
    ),
  );
}

class DriveProfitApp extends StatelessWidget {
  const DriveProfitApp({
    super.key,
    required this.currencyController,
    required this.localeController,
    required this.firebaseBootstrap,
  });

  final CurrencyController currencyController;
  final AppLocaleController localeController;
  final FirebaseBootstrapResult firebaseBootstrap;

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      controller: localeController,
      child: CurrencyScope(
        controller: currencyController,
        child: ValueListenableBuilder<Locale>(
          valueListenable: localeController,
          builder: (context, locale, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'DriveProfit',
              theme: DriveProfitTheme.lightTheme(),
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: AuthGate(
                bootstrap: firebaseBootstrap,
                currencyController: currencyController,
              ),
            );
          },
        ),
      ),
    );
  }
}
