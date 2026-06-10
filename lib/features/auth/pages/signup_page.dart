import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../core/utils/currency_scope.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/driverbank_visuals.dart';
import '../../../core/widgets/form_feedback_banner.dart';
import '../../../core/widgets/form_section_card.dart';
import '../../../core/widgets/language_selector_field.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class _DateTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final truncated = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();

    for (var i = 0; i < truncated.length; i++) {
      buffer.write(truncated[i]);
      if ((i == 1 || i == 3) && i != truncated.length - 1) {
        buffer.write('/');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _authService = const AuthService();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final celularController = TextEditingController();
  final nascimentoController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool ocultarSenha = true;
  bool ocultarConfirmarSenha = true;
  bool tentouEnviar = false;
  bool cadastrando = false;
  String? generoSelecionado;
  FormFeedbackType? feedbackType;
  String? feedbackTitle;
  String? feedbackMessage;
  String? _birthDateLanguageCode;

  bool _usesAmericanBirthDateFormat(String languageCode) =>
      languageCode == 'en';

  String _birthDatePattern(String languageCode) {
    return _usesAmericanBirthDateFormat(languageCode)
        ? 'MM/dd/yyyy'
        : 'dd/MM/yyyy';
  }

  String _birthDateHint(AppLocalizations l, String languageCode) {
    return _usesAmericanBirthDateFormat(languageCode)
        ? 'MM/DD/YYYY'
        : l.text('DD/MM/AAAA');
  }

  String _birthDateFormatMessage(AppLocalizations l, String languageCode) {
    if (_usesAmericanBirthDateFormat(languageCode)) {
      return 'Use the ${_birthDateHint(l, languageCode)} format.';
    }

    return l.text('Use o formato DD/MM/AAAA.');
  }

  String _birthDateRequiredMessage(AppLocalizations l, String languageCode) {
    if (_usesAmericanBirthDateFormat(languageCode)) {
      return 'Enter your birth date.';
    }

    return l.text('Informe sua data de nascimento.');
  }

  String _birthDateInvalidMessage(AppLocalizations l, String languageCode) {
    if (_usesAmericanBirthDateFormat(languageCode)) {
      return 'Enter a valid date.';
    }

    return l.text('Digite uma data válida.');
  }

  String _birthDateFutureMessage(AppLocalizations l, String languageCode) {
    if (_usesAmericanBirthDateFormat(languageCode)) {
      return 'The date cannot be in the future.';
    }

    return l.text('A data não pode ser
