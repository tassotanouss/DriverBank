import 'package:app/core/localization/app_locale_scope.dart';
import 'package:app/core/localization/app_localizations.dart';
import 'package:app/core/theme/drive_profit_theme.dart';
import 'package:app/core/utils/currency_scope.dart';
import 'package:app/features/auth/pages/signup_page.dart';
import 'package:app/features/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('abre cadastro com os campos principais no mobile', (
    tester,
  ) async {
    final localeController = AppLocaleController(const Locale('pt', 'BR'));
    final currencyController = CurrencyController(
      CurrencyController.fromCode('BRL'),
    );

    await tester.pumpWidget(
      AppLocaleScope(
        controller: localeController,
        child: CurrencyScope(
          controller: currencyController,
          child: MaterialApp(
            theme: DriveProfitTheme.lightTheme(),
            locale: localeController.value,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const SignupPage(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Criar conta'), findsOneWidget);
    expect(find.text('Criar conta e entrar'), findsOneWidget);
    expect(find.text('Data de nascimento'), findsOneWidget);
  });

  testWidgets(
    'atualiza hints monetarios nas abas apos trocar a moeda no perfil',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'isLoggedIn': true,
        'hasRegisteredUser': true,
        'userName': 'Motorista Teste',
        'userEmail': 'teste@driveprofit.app',
        'userPhone': '(11) 99999-9999',
        'userCurrency': 'BRL',
      });

      final currencyController = await CurrencyController.load();
      final localeController = await AppLocaleController.load();

      await tester.pumpWidget(
        AppLocaleScope(
          controller: localeController,
          child: CurrencyScope(
            controller: currencyController,
            child: MaterialApp(
              theme: DriveProfitTheme.lightTheme(),
              locale: localeController.value,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const HomePage(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      final currencyField = find.byType(DropdownButtonFormField<String>).last;
      await tester.scrollUntilVisible(
        currencyField,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(currencyField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dolar americano (US\$)').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byIcon(Icons.save_outlined));
      await tester.tap(find.byIcon(Icons.save_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Metas'));
      await tester.pumpAndSettle();

      expect(find.text('Ex.: 250.00'), findsOneWidget);
      expect(find.text('Ex.: 1,750.00'), findsOneWidget);
      expect(find.text('Ex.: 8,000.00'), findsOneWidget);
    },
  );
}
