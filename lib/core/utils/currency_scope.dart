import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_preferences.dart';

class CurrencyConfig {
  const CurrencyConfig({
    required this.code,
    required this.label,
    required this.symbol,
    required this.locale,
  });

  final String code;
  final String label;
  final String symbol;
  final String locale;

  String format(double value) {
    return NumberFormat.currency(locale: locale, symbol: symbol).format(value);
  }

  String get inputPrefix => '$symbol ';

  String formatInput(num value, {int decimalDigits = 2}) {
    final formatter = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = decimalDigits
      ..maximumFractionDigits = decimalDigits;

    return formatter.format(value);
  }

  String inputExample(num value, {int decimalDigits = 2}) {
    return 'Ex.: ${formatInput(value, decimalDigits: decimalDigits)}';
  }
}

class CurrencyController extends ValueNotifier<CurrencyConfig> {
  CurrencyController(super.value);

  static const List<CurrencyConfig> supportedCurrencies = [
    CurrencyConfig(
      code: 'BRL',
      label: 'Real brasileiro',
      symbol: 'R\$',
      locale: 'pt_BR',
    ),
    CurrencyConfig(
      code: 'USD',
      label: 'Dolar americano',
      symbol: 'US\$',
      locale: 'en_US',
    ),
    CurrencyConfig(code: 'EUR', label: 'Euro', symbol: 'EUR', locale: 'de_DE'),
  ];

  static CurrencyConfig fromCode(String? code) {
    return supportedCurrencies.firstWhere(
      (currency) => currency.code == code,
      orElse: () => supportedCurrencies.first,
    );
  }

  static Future<CurrencyController> load() async {
    final prefs = await AppPreferences.load();
    final code = await _loadStoredCurrencyCode(prefs);
    return CurrencyController(fromCode(code));
  }

  Future<void> reloadForCurrentUser() async {
    final prefs = await AppPreferences.load();
    value = fromCode(await _loadStoredCurrencyCode(prefs));
  }

  Future<void> setCurrency(String code) async {
    final nextCurrency = fromCode(code);

    if (value.code == nextCurrency.code) {
      return;
    }

    value = nextCurrency;

    final prefs = await AppPreferences.load();
    await prefs.setString('userCurrency', nextCurrency.code);

    final legacyPrefs = await SharedPreferences.getInstance();
    await legacyPrefs.setString('userCurrency', nextCurrency.code);
  }

  static Future<String?> _loadStoredCurrencyCode(AppPreferences prefs) async {
    final scopedCode = prefs.getString('userCurrency');
    final legacyPrefs = await SharedPreferences.getInstance();
    final legacyCode = legacyPrefs.getString('userCurrency');
    final normalizedScopedCode = scopedCode == null
        ? null
        : fromCode(scopedCode).code;
    final normalizedLegacyCode = legacyCode == null
        ? null
        : fromCode(legacyCode).code;

    if (normalizedLegacyCode != null &&
        normalizedLegacyCode != normalizedScopedCode) {
      await prefs.setString('userCurrency', normalizedLegacyCode);
      return normalizedLegacyCode;
    }

    return normalizedScopedCode ?? normalizedLegacyCode;
  }
}

class CurrencyScope extends InheritedNotifier<CurrencyController> {
  const CurrencyScope({
    super.key,
    required CurrencyController controller,
    required super.child,
  }) : super(notifier: controller);

  static CurrencyController controllerOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<CurrencyScope>();
    assert(scope != null, 'CurrencyScope not found in widget tree.');
    return scope!.notifier!;
  }

  static CurrencyConfig of(BuildContext context) {
    return controllerOf(context).value;
  }
}
