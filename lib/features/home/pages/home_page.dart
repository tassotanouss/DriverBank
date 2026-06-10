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
          DashboardPage(
            onAddLancamento: () => setState(() => currentIndex = 1),
          ),
          LancamentosPage(),
          RelatoriosPage(),
          MetasPage(),
          ProfilePage(),
        ];

        return Scaffold(
          body: IndexedStack(index: currentIndex, children: pages),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomSafeArea),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140F2418),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  _BottomNavItem(
                    label: tr('Dashboard'),
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    selected: currentIndex == 0,
                    onTap: () => setState(() => currentIndex = 0),
                  ),
                  _BottomNavItem(
                    label: tr('Lan\u00E7amentos'),
                    icon: Icons.receipt_long_outlined,
                    selectedIcon: Icons.receipt_long_rounded,
                    selected: currentIndex == 1,
                    onTap: () => setState(() => currentIndex = 1),
                  ),
                  _BottomNavItem(
                    label: tr('Relat\u00F3rios'),
                    icon: Icons.bar_chart_outlined,
                    selectedIcon: Icons.bar_chart_rounded,
                    selected: currentIndex == 2,
                    onTap: () => setState(() => currentIndex = 2),
                  ),
                  _BottomNavItem(
                    label: tr('Metas'),
                    icon: Icons.flag_outlined,
                    selectedIcon: Icons.flag_rounded,
                    selected: currentIndex == 3,
                    onTap: () => setState(() => currentIndex = 3),
                  ),
                  _BottomNavItem(
                    label: tr('Perfil'),
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    selected: currentIndex == 4,
                    onTap: () => setState(() => currentIndex = 4),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? DriveProfitTheme.primaryColor
        : context.driveProfitPalette.subtitle;

    return Expanded(
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
          decoration: BoxDecoration(
            color: selected
                ? context.driveProfitPalette.cardTint
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: 4),
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerUp: (_) => onTap(),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
