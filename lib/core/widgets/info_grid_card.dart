import 'package:flutter/material.dart';

import '../theme/drive_profit_theme.dart';

class InfoGridCard extends StatelessWidget {
  const InfoGridCard({
    super.key,
    required this.title,
    required this.value,
    this.height = 95,
  });

  final String title;
  final String value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: DriveProfitTheme.cardDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
