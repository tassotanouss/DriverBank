import 'package:flutter/material.dart';

class DriveProfitTheme {
  static const Color primaryColor = Color(0xFF1F8A5B);
  static const Color backgroundColor = Color(0xFFF4F7F3);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color cardTintColor = Color(0xFFE8F3EC);
  static const Color profitColor = Color(0xFF1F8A5B);
  static const Color lossColor = Color(0xFFD04F4F);
  static const Color titleColor = Color(0xFF163828);
  static const Color subtitleColor = Color(0xFF647067);
  static const Color borderColor = Color(0xFFD7E4DB);

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      surface: cardColor,
    ).copyWith(
      secondary: const Color(0xFF6FB792),
      error: lossColor,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Segoe UI',
    );

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: titleColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: titleColor,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: titleColor,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          color: subtitleColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        hintStyle: const TextStyle(color: subtitleColor),
        labelStyle: const TextStyle(
          color: subtitleColor,
          fontWeight: FontWeight.w500,
        ),
        helperStyle: const TextStyle(
          color: subtitleColor,
          fontSize: 12,
        ),
        errorStyle: const TextStyle(
          color: lossColor,
          fontWeight: FontWeight.w600,
        ),
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lossColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: lossColor,
            width: 1.4,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(55),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(55),
          side: const BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: titleColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: borderColor),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: titleColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        height: 78,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? primaryColor : subtitleColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primaryColor : subtitleColor,
            size: 24,
          );
        }),
      ),
      dividerColor: borderColor,
      extensions: const [
        DriveProfitPalette(),
      ],
    );
  }

  static BoxDecoration cardDecoration(BuildContext context) {
    return BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor),
      boxShadow: const [
        BoxShadow(
          color: Color(0x140F2418),
          blurRadius: 18,
          offset: Offset(0, 10),
        ),
      ],
    );
  }

  static BoxDecoration tintedCardDecoration(
    BuildContext context, {
    Color? tint,
  }) {
    return BoxDecoration(
      color: tint ?? cardTintColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: borderColor),
      boxShadow: const [
        BoxShadow(
          color: Color(0x120F2418),
          blurRadius: 16,
          offset: Offset(0, 8),
        ),
      ],
    );
  }
}

class DriveProfitPalette extends ThemeExtension<DriveProfitPalette> {
  const DriveProfitPalette({
    this.profit = DriveProfitTheme.profitColor,
    this.loss = DriveProfitTheme.lossColor,
    this.cardTint = DriveProfitTheme.cardTintColor,
    this.title = DriveProfitTheme.titleColor,
    this.subtitle = DriveProfitTheme.subtitleColor,
    this.border = DriveProfitTheme.borderColor,
  });

  final Color profit;
  final Color loss;
  final Color cardTint;
  final Color title;
  final Color subtitle;
  final Color border;

  @override
  DriveProfitPalette copyWith({
    Color? profit,
    Color? loss,
    Color? cardTint,
    Color? title,
    Color? subtitle,
    Color? border,
  }) {
    return DriveProfitPalette(
      profit: profit ?? this.profit,
      loss: loss ?? this.loss,
      cardTint: cardTint ?? this.cardTint,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      border: border ?? this.border,
    );
  }

  @override
  ThemeExtension<DriveProfitPalette> lerp(
    covariant ThemeExtension<DriveProfitPalette>? other,
    double t,
  ) {
    if (other is! DriveProfitPalette) {
      return this;
    }

    return DriveProfitPalette(
      profit: Color.lerp(profit, other.profit, t) ?? profit,
      loss: Color.lerp(loss, other.loss, t) ?? loss,
      cardTint: Color.lerp(cardTint, other.cardTint, t) ?? cardTint,
      title: Color.lerp(title, other.title, t) ?? title,
      subtitle: Color.lerp(subtitle, other.subtitle, t) ?? subtitle,
      border: Color.lerp(border, other.border, t) ?? border,
    );
  }
}

extension DriveProfitThemeContext on BuildContext {
  DriveProfitPalette get driveProfitPalette =>
      Theme.of(this).extension<DriveProfitPalette>()!;
}
