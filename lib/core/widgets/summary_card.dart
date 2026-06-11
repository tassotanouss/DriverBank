import 'package:flutter/material.dart';

import '../theme/drive_profit_theme.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.valueColor,
    this.compact = false,
    this.expanded = false,
  });

  final String title;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool compact;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: expanded ? null : double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: expanded ? 4 : 0,
      ).copyWith(bottom: expanded ? 0 : 12),
      padding: EdgeInsets.all(compact ? 14 : 16),
      decoration: compact
          ? DriveProfitTheme.cardDecoration(context)
          : DriveProfitTheme.tintedCardDecoration(context),
      child: icon == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: compact ? 18 : 22,
                    fontWeight: FontWeight.w900,
                    color: valueColor,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: valueColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );

    return expanded ? Expanded(child: card) : card;
  }
}
