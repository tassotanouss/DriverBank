import 'package:flutter/material.dart';

import '../theme/drive_profit_theme.dart';

class DriverBankHeroCard extends StatelessWidget {
  const DriverBankHeroCard({
    super.key,
    required this.label,
    required this.value,
    required this.description,
    this.icon = Icons.trending_up_rounded,
    this.actions = const [],
  });

  final String label;
  final String value;
  final String description;
  final IconData icon;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F5F43), DriveProfitTheme.secondaryColor],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33246B86),
            blurRadius: 28,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xDFFFFFFF),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xD9FFFFFF),
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }
}

class DriverBankMetricCard extends StatelessWidget {
  const DriverBankMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.hint,
    this.valueColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? hint;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: DriveProfitTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.driveProfitPalette.cardTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontSize: 22, color: valueColor),
          ),
          if (hint != null) ...[
            const SizedBox(height: 7),
            Text(hint!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class DriverBankQuickAction extends StatelessWidget {
  const DriverBankQuickAction({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(label),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
      backgroundColor: Colors.white.withValues(alpha: 0.14),
      onPressed: onTap,
    );
  }
}

class DriverBankBarChart extends StatelessWidget {
  const DriverBankBarChart({super.key, required this.items, this.height = 220});

  final List<DriverBankBarItem> items;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxAbs = items
        .map((item) => item.value.abs())
        .fold<double>(
          0,
          (previous, current) => current > previous ? current : previous,
        );
    final maxValue = maxAbs == 0 ? 1.0 : maxAbs;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: items.map((item) {
          final positive = item.value >= 0;
          final barHeight = ((item.value.abs() / maxValue) * (height - 58))
              .clamp(8.0, height - 58);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item.valueLabel,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: positive
                          ? context.driveProfitPalette.profit
                          : context.driveProfitPalette.loss,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      color: positive
                          ? context.driveProfitPalette.profit
                          : context.driveProfitPalette.loss,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DriverBankBarItem {
  const DriverBankBarItem({
    required this.label,
    required this.value,
    required this.valueLabel,
  });

  final String label;
  final double value;
  final String valueLabel;
}
