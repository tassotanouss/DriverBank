class FormValidators {
  static String _translate(
    String value,
    String Function(String value)? translate,
  ) {
    return translate?.call(value) ?? value;
  }

  static final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  static final RegExp _decimalRegex = RegExp(r'^-?\d+(\.\d+)?$');
  static final RegExp _timeRegex = RegExp(r'^\d{1,2}:\d{2}$');

  static String normalizeEmail(String value) {
    return value.trim().toLowerCase();
  }

  static bool isValidEmail(String value) {
    return _emailRegex.hasMatch(normalizeEmail(value));
  }

  static String? validateEmail(
    String? value, {
    String Function(String value)? translate,
  }) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return _translate('Informe um e-mail para continuar.', translate);
    }
    if (!isValidEmail(email)) {
      return _translate('Digite um e-mail válido.', translate);
    }
    return null;
  }

  static String? validateStrongPassword(
    String? value, {
    String Function(String value)? translate,
  }) {
    if (value == null || value.isEmpty) {
      return _translate('Crie uma senha para proteger sua conta.', translate);
    }
    if (value.length < 8) {
      return _translate('Use pelo menos 8 caracteres.', translate);
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return _translate('Inclua ao menos uma letra maiúscula.', translate);
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return _translate('Inclua ao menos uma letra minúscula.', translate);
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return _translate('Inclua ao menos um número.', translate);
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=/\\]').hasMatch(value)) {
      return _translate('Inclua ao menos um caractere especial.', translate);
    }
    if (RegExp(r'\s').hasMatch(value)) {
      return _translate('Não use espaços na senha.', translate);
    }
    return null;
  }

  static double? parseDecimal(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[^\d,.\-]'), '');

    if (sanitized.isEmpty) return null;

    final minusMatches = RegExp(r'-').allMatches(sanitized).length;
    if (minusMatches > 1 ||
        (sanitized.contains('-') && !sanitized.startsWith('-'))) {
      return null;
    }

    final commaCount = RegExp(',').allMatches(sanitized).length;
    final dotCount = RegExp(r'\.').allMatches(sanitized).length;

    if (commaCount > 0 && dotCount > 0) {
      final lastComma = sanitized.lastIndexOf(',');
      final lastDot = sanitized.lastIndexOf('.');
      final decimalSeparator = lastComma > lastDot ? ',' : '.';
      final thousandsSeparator = decimalSeparator == ',' ? '.' : ',';
      final decimalIndex = sanitized.lastIndexOf(decimalSeparator);
      final integerPart = sanitized.substring(0, decimalIndex);
      final decimalPart = sanitized.substring(decimalIndex + 1);

      if (!_isDigitsOnly(decimalPart)) {
        return null;
      }

      if (!_hasValidIntegerPart(integerPart, thousandsSeparator)) {
        return null;
      }

      return _parseNormalizedDecimal(
        '${integerPart.replaceAll(thousandsSeparator, '')}.$decimalPart',
      );
    }

    if (commaCount == 0 && dotCount == 0) {
      return _parseNormalizedDecimal(sanitized);
    }

    final separator = commaCount > 0 ? ',' : '.';
    final separatorCount = commaCount > 0 ? commaCount : dotCount;

    if (separatorCount > 1) {
      if (!_isValidThousandsGrouping(sanitized, separator)) {
        return null;
      }

      return _parseNormalizedDecimal(sanitized.replaceAll(separator, ''));
    }

    final separatorIndex = sanitized.indexOf(separator);
    final integerPart = sanitized.substring(0, separatorIndex);
    final trailingPart = sanitized.substring(separatorIndex + 1);

    if (!_isDigitsOnly(trailingPart)) {
      return null;
    }

    if (trailingPart.length == 3 && _canBeThousandsGroup(integerPart)) {
      return _parseNormalizedDecimal(sanitized.replaceAll(separator, ''));
    }

    return _parseNormalizedDecimal(sanitized.replaceFirst(separator, '.'));
  }

  static bool _isDigitsOnly(String value) {
    return value.isNotEmpty && RegExp(r'^\d+$').hasMatch(value);
  }

  static bool _canBeThousandsGroup(String integerPart) {
    final normalizedIntegerPart = integerPart.startsWith('-')
        ? integerPart.substring(1)
        : integerPart;

    return normalizedIntegerPart.isNotEmpty &&
        RegExp(r'^\d{1,3}$').hasMatch(normalizedIntegerPart);
  }

  static bool _hasValidIntegerPart(String value, String thousandsSeparator) {
    final normalizedValue = value.startsWith('-') ? value.substring(1) : value;

    if (normalizedValue.isEmpty) {
      return false;
    }

    if (normalizedValue.contains(thousandsSeparator)) {
      return _isValidThousandsGrouping(value, thousandsSeparator);
    }

    return RegExp(r'^\d+$').hasMatch(normalizedValue);
  }

  static bool _isValidThousandsGrouping(String value, String separator) {
    final normalizedValue = value.startsWith('-') ? value.substring(1) : value;
    final groups = normalizedValue.split(separator);

    if (groups.isEmpty || groups.any((group) => group.isEmpty)) {
      return false;
    }

    if (!RegExp(r'^\d{1,3}$').hasMatch(groups.first)) {
      return false;
    }

    return groups.skip(1).every((group) => RegExp(r'^\d{3}$').hasMatch(group));
  }

  static double? _parseNormalizedDecimal(String value) {
    if (!_decimalRegex.hasMatch(value)) {
      return null;
    }

    return double.tryParse(value);
  }

  static int? parseInteger(String value) {
    final sanitized = value.trim();
    if (sanitized.isEmpty) return null;
    if (!RegExp(r'^-?\d+$').hasMatch(sanitized)) {
      return null;
    }
    return int.tryParse(sanitized);
  }

  static String? validateNonNegativeNumber(
    String? value, {
    bool required = false,
    String requiredMessage = 'Informe um valor para continuar.',
    String Function(String value)? translate,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return required ? _translate(requiredMessage, translate) : null;
    }

    final number = parseDecimal(text);
    if (number == null) {
      return _translate('Digite um número válido.', translate);
    }
    if (number < 0) {
      return _translate('Use um valor igual ou maior que zero.', translate);
    }
    return null;
  }

  static String? validateNonNegativeInteger(
    String? value, {
    bool required = false,
    String requiredMessage = 'Preencha este campo.',
    String Function(String value)? translate,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return required ? _translate(requiredMessage, translate) : null;
    }

    final number = parseInteger(text);
    if (number == null) {
      return _translate('Digite um número inteiro válido.', translate);
    }
    if (number < 0) {
      return _translate('Use um valor igual ou maior que zero.', translate);
    }
    return null;
  }

  static int? parseDurationInMinutes(String value) {
    final text = value.trim();
    if (!_timeRegex.hasMatch(text)) {
      return null;
    }

    final parts = text.split(':');
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);

    if (hours == null || minutes == null) {
      return null;
    }
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
      return null;
    }

    return (hours * 60) + minutes;
  }

  static String? validateDuration(
    String? value, {
    String Function(String value)? translate,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return _translate('Informe quanto tempo você trabalhou.', translate);
    }
    if (parseDurationInMinutes(text) == null) {
      return _translate('Use um horário válido no formato hh:mm.', translate);
    }
    return null;
  }
}
