import 'package:app/core/utils/form_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FormValidators', () {
    test('aceita e normaliza email valido', () {
      expect(
        FormValidators.normalizeEmail('  User@Test.COM '),
        'user@test.com',
      );
      expect(FormValidators.validateEmail('user@test.com'), isNull);
    });

    test('recusa email invalido', () {
      expect(
        FormValidators.validateEmail('email-invalido'),
        'Digite um e-mail válido.',
      );
    });

    test('recusa senha fraca e aceita senha forte', () {
      expect(
        FormValidators.validateStrongPassword('abc123'),
        'Use pelo menos 8 caracteres.',
      );
      expect(
        FormValidators.validateStrongPassword('Senha Forte1!'),
        'Não use espaços na senha.',
      );
      expect(FormValidators.validateStrongPassword('SenhaForte1!'), isNull);
    });

    test('converte moeda pt-BR sem perder milhares', () {
      expect(FormValidators.parseDecimal('1.750,50'), 1750.50);
      expect(FormValidators.parseDecimal('R\$ 99,90'), 99.90);
      expect(FormValidators.parseDecimal('12.34.56'), isNull);
    });

    test('converte moeda em formatos USD e EUR', () {
      expect(FormValidators.parseDecimal('US\$ 1,750.50'), 1750.50);
      expect(FormValidators.parseDecimal('EUR 1.750,50'), 1750.50);
      expect(FormValidators.parseDecimal('45.000'), 45000);
      expect(FormValidators.parseDecimal('45,000'), 45000);
    });

    test('recusa numero negativo e texto invalido', () {
      expect(
        FormValidators.validateNonNegativeNumber('-1'),
        'Use um valor igual ou maior que zero.',
      );
      expect(
        FormValidators.validateNonNegativeNumber('abc'),
        'Digite um número válido.',
      );
    });

    test('valida tempo trabalhado no formato hh:mm', () {
      expect(FormValidators.validateDuration('08:30'), isNull);
      expect(
        FormValidators.validateDuration('24:00'),
        'Use um horário válido no formato hh:mm.',
      );
      expect(
        FormValidators.validateDuration('08:99'),
        'Use um horário válido no formato hh:mm.',
      );
    });
  });
}
