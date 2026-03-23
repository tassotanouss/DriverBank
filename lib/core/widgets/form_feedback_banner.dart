import 'package:flutter/material.dart';

import '../theme/drive_profit_theme.dart';

enum FormFeedbackType { success, error, info }

class FormFeedbackBanner extends StatelessWidget {
  const FormFeedbackBanner({
    super.key,
    required this.title,
    required this.message,
    required this.type,
  });

  final String title;
  final String message;
  final FormFeedbackType type;

  @override
  Widget build(BuildContext context) {
    final palette = context.driveProfitPalette;

    final Color backgroundColor;
    final Color iconColor;
    final IconData icon;

    switch (type) {
      case FormFeedbackType.success:
        backgroundColor = const Color(0xFFE7F5EC);
        iconColor = palette.profit;
        icon = Icons.check_circle_outline;
      case FormFeedbackType.error:
        backgroundColor = const Color(0xFFFBEAEA);
        iconColor = palette.loss;
        icon = Icons.error_outline;
      case FormFeedbackType.info:
        backgroundColor = const Color(0xFFEAF2FB);
        iconColor = const Color(0xFF2F6DA8);
        icon = Icons.info_outline;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: palette.title),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
