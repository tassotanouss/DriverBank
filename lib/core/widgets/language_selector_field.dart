import 'package:flutter/material.dart';

import '../localization/app_locale_scope.dart';
import '../localization/app_localizations.dart';

class LanguageSelectorField extends StatelessWidget {
  const LanguageSelectorField({
    super.key,
    this.onChanged,
  });

  final ValueChanged<Locale>? onChanged;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final controller = AppLocaleScope.controllerOf(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<Locale>(
        initialValue: controller.value,
        decoration: InputDecoration(
          labelText: localizations.text('Idioma do aplicativo'),
          helperText:
              localizations.text('Escolha o idioma usado em todas as telas do app.'),
        ),
        items: AppLocaleController.supportedLocales
            .map(
              (locale) => DropdownMenuItem(
                value: locale,
                child: Text(AppLocalizations.languageLabel(locale)),
              ),
            )
            .toList(),
        onChanged: (locale) async {
          if (locale == null) return;
          await controller.setLocale(locale);
          onChanged?.call(locale);
        },
      ),
    );
  }
}
