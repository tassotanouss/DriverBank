import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController extends ValueNotifier<Locale> {
  AppLocaleController(super.value);

  static const String _storageKey = 'appLanguageCode';

  static const List<Locale> supportedLocales = [
    Locale('pt', 'BR'),
    Locale('en', 'US'),
    Locale('es', 'ES'),
  ];

  static Future<AppLocaleController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_storageKey);

    return AppLocaleController(_fromLanguageCode(languageCode));
  }

  static Locale _fromLanguageCode(String? languageCode) {
    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => supportedLocales.first,
    );
  }

  Future<void> setLocale(Locale locale) async {
    if (value.languageCode == locale.languageCode) {
      return;
    }

    value = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.languageCode);
  }
}

class AppLocaleScope extends InheritedNotifier<AppLocaleController> {
  const AppLocaleScope({
    super.key,
    required AppLocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppLocaleController controllerOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();
    assert(scope != null, 'AppLocaleScope not found in widget tree.');
    return scope!.notifier!;
  }

  static Locale of(BuildContext context) {
    return controllerOf(context).value;
  }
}
