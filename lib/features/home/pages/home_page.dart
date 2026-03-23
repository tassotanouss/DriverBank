import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/drive_profit_theme.dart';
import '../../../core/utils/currency_scope.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../lancamentos/pages/lancamentos_page.dart';
import '../../metas/pages/metas_page.dart';
import '../../profile/pages/profile_page.dart';
import '../../relatorios/pages/relatorios_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context).text;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final currencyController = CurrencyScope.controllerOf(context);

    return ValueListenableBuilder<CurrencyConfig>(
      valueListenable: currencyController,
      builder: (context, _, _) {
        final pages = [
          DashboardPage(),
          LancamentosPage(),
          RelatoriosPage(),
          MetasPage(),
          ProfilePage(),
        ];

        return Scaffold(
          body: IndexedStack(index: currentIndex, children: pages),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomSafeArea),
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140F2418),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
                borderRadius: BorderRadius.circular(28),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: NavigationBar(
                  selectedIndex: currentIndex,
                  backgroundColor: Colors.white,
                  indicatorColor: context.driveProfitPalette.cardTint,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.dashboard_outlined),
                      selectedIcon: const Icon(Icons.dashboard_rounded),
                      label: tr('Dashboard'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.receipt_long_outlined),
                      selectedIcon: const Icon(Icons.receipt_long_rounded),
                      label: tr('Lan\u00E7amentos'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.bar_chart_outlined),
                      selectedIcon: const Icon(Icons.bar_chart_rounded),
                      label: tr('Relat\u00F3rios'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.flag_outlined),
                      selectedIcon: const Icon(Icons.flag_rounded),
                      label: tr('Metas'),
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.person_outline_rounded),
                      selectedIcon: const Icon(Icons.person_rounded),
                      label: tr('Perfil'),
                    ),
                  ],
                  onDestinationSelected: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
