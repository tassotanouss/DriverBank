import 'package:app/core/utils/app_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppPreferences', () {
    test('migra dados legados apenas para a primeira conta', () async {
      SharedPreferences.setMockInitialValues({
        'userName': 'Motorista legado',
        'metaDiaria': 250.0,
        'lancamentos': ['{"data":"09/06/2026"}'],
      });

      final firstUser = await AppPreferences.load(userId: 'user-a');
      final secondUser = await AppPreferences.load(userId: 'user-b');

      expect(firstUser.getString('userName'), 'Motorista legado');
      expect(firstUser.getDouble('metaDiaria'), 250.0);
      expect(firstUser.getStringList('lancamentos'), ['{"data":"09/06/2026"}']);
      expect(secondUser.getString('userName'), isNull);
      expect(secondUser.getDouble('metaDiaria'), isNull);
      expect(secondUser.getStringList('lancamentos'), isNull);
    });

    test('nao sobrescreve dados que ja pertencem ao usuario', () async {
      SharedPreferences.setMockInitialValues({
        'userName': 'Nome legado',
        'user:user-a:userName': 'Nome atual',
      });

      final prefs = await AppPreferences.load(userId: 'user-a');

      expect(prefs.getString('userName'), 'Nome atual');
    });
  });
}
