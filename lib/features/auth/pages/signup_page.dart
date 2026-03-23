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

    return l.text('A data não pode ser no futuro.');
  }

  DateTime? _parseBirthDate(String value, {String? languageCode}) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return null;
    }

    try {
      return DateFormat(
        _birthDatePattern(
          languageCode ?? Localizations.localeOf(context).languageCode,
        ),
      ).parseStrict(normalized);
    } catch (_) {
      return null;
    }
  }

  void _syncBirthDateWithLocale({
    required String previousLanguageCode,
    required String nextLanguageCode,
  }) {
    final currentValue = nascimentoController.text.trim();
    if (currentValue.isEmpty || previousLanguageCode == nextLanguageCode) {
      return;
    }

    final parsedDate = _parseBirthDate(
      currentValue,
      languageCode: previousLanguageCode,
    );
    if (parsedDate == null) {
      return;
    }

    final formattedDate = DateFormat(
      _birthDatePattern(nextLanguageCode),
    ).format(parsedDate);

    nascimentoController.value = TextEditingValue(
      text: formattedDate,
      selection: TextSelection.collapsed(offset: formattedDate.length),
    );
  }

  String? validarDataNascimento(String? value, AppLocalizations l) {
    final texto = value?.trim() ?? '';
    final languageCode = Localizations.localeOf(context).languageCode;

    if (texto.isEmpty) {
      return _birthDateRequiredMessage(l, languageCode);
    }
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(texto)) {
      return _birthDateFormatMessage(l, languageCode);
    }

    final data = _parseBirthDate(texto, languageCode: languageCode);
    if (data == null) {
      return _birthDateInvalidMessage(l, languageCode);
    }

    final agora = DateTime.now();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    if (data.isAfter(hoje)) {
      return _birthDateFutureMessage(l, languageCode);
    }

    return null;
  }

  void mostrarFeedback({
    required FormFeedbackType type,
    required String title,
    required String message,
  }) {
    setState(() {
      feedbackType = type;
      feedbackTitle = title;
      feedbackMessage = message;
    });
  }

  Future<void> salvarCadastro(String emailNormalizado) async {
    final prefs = await AppPreferences.load();
    final dataInicio = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dataNascimento = _parseBirthDate(nascimentoController.text);
    final currentUser = _authService.currentUserOrNull;

    await prefs.setString('userName', nomeController.text.trim());
    await prefs.setString('userEmail', currentUser?.email ?? emailNormalizado);
    await prefs.setString('userPhone', celularController.text.trim());
    await prefs.setString('userGender', generoSelecionado ?? '');
    await prefs.setString(
      'userBirthDate',
      dataNascimento == null
          ? nascimentoController.text.trim()
          : DateFormat('yyyy-MM-dd').format(dataNascimento),
    );

    if (!prefs.containsKey('userCurrency')) {
      await prefs.setString('userCurrency', 'BRL');
    }

    if (!prefs.containsKey('userStartDate')) {
      await prefs.setString('userStartDate', dataInicio);
    }
  }

  Future<void> cadastrar() async {
    final l = AppLocalizations.of(context);
    final tr = l.text;
    final navigator = Navigator.of(context);
    final currencyController = CurrencyScope.controllerOf(context);

    setState(() {
      tentouEnviar = true;
      cadastrando = true;
    });

    if (!_formKey.currentState!.validate()) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Revise os campos obrigatórios'),
        message: tr(
          'Algumas informações estão faltando ou precisam ser corrigidas antes de criar a conta.',
        ),
      );
      setState(() {
        cadastrando = false;
      });
      return;
    }

    if (senhaController.text != confirmarSenhaController.text) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Senhas diferentes'),
        message: tr('A confirmação precisa ser igual à senha informada acima.'),
      );
      setState(() {
        cadastrando = false;
      });
      return;
    }

    final emailNormalizado = FormValidators.normalizeEmail(
      emailController.text,
    );

    try {
      await _authService.signUp(
        email: emailNormalizado,
        password: senhaController.text,
        displayName: nomeController.text.trim(),
      );
      await salvarCadastro(emailNormalizado);

      if (!mounted) {
        return;
      }

      await currencyController.reloadForCurrentUser();
      if (!mounted) {
        return;
      }

      mostrarFeedback(
        type: FormFeedbackType.success,
        title: l.text('Conta criada com sucesso.'),
        message: l.text('Sua conta já está pronta e a sessão foi iniciada.'),
      );
      navigator.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (error) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Não foi possível criar a conta'),
        message: mapAuthErrorMessage(exception: error, translate: tr),
      );
    } catch (_) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Não foi possível criar a conta'),
        message: tr('Tente novamente em alguns instantes.'),
      );
    } finally {
      if (mounted) {
        setState(() {
          cadastrando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    celularController.dispose();
    nascimentoController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentLanguageCode = Localizations.localeOf(context).languageCode;
    final previousLanguageCode = _birthDateLanguageCode;

    if (previousLanguageCode != null) {
      _syncBirthDateWithLocale(
        previousLanguageCode: previousLanguageCode,
        nextLanguageCode: currentLanguageCode,
      );
    }

    _birthDateLanguageCode = currentLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tr = l.text;
    final languageCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Criar conta')), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (feedbackType != null &&
                  feedbackTitle != null &&
                  feedbackMessage != null)
                FormFeedbackBanner(
                  title: feedbackTitle!,
                  message: feedbackMessage!,
                  type: feedbackType!,
                ),
              FormSectionCard(
                title: tr('Bem-vindo ao DriveProfit'),
                subtitle: tr('Você pode trocar o idioma antes de entrar.'),
                icon: Icons.language_outlined,
                child: const LanguageSelectorField(),
              ),
              FormSectionCard(
                title: tr('Bem-vindo ao DriveProfit'),
                subtitle: tr(
                  'Preencha seus dados de acesso e deixe o cadastro pronto para uso no app.',
                ),
                icon: Icons.person_add_alt_1_outlined,
                child: Column(
                  children: [
                    AppTextField(
                      label: tr('Nome completo'),
                      controller: nomeController,
                      hint: tr('Como você gostaria de ser identificado no app'),
                      autovalidateMode: tentouEnviar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      isFormField: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return tr('Informe seu nome completo.');
                        }
                        if (value.trim().split(' ').length < 2) {
                          return tr(
                            'Digite nome e sobrenome para facilitar a identificação.',
                          );
                        }
                        return null;
                      },
                    ),
                    AppTextField(
                      label: tr('E-mail de acesso'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      hint: tr('nome@exemplo.com'),
                      helperText: tr(
                        'Esse e-mail será usado para entrar na conta.',
                      ),
                      autovalidateMode: tentouEnviar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      isFormField: true,
                      validator: (value) =>
                          FormValidators.validateEmail(value, translate: tr),
                    ),
                    AppTextField(
                      label: tr('Celular com DDD'),
                      controller: celularController,
                      keyboardType: TextInputType.phone,
                      hint: tr('(11) 99999-9999'),
                      helperText: tr(
                        'Use um número que você acompanhe com frequência.',
                      ),
                      autovalidateMode: tentouEnviar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      isFormField: true,
                      validator: (value) {
                        final numeros =
                            value?.replaceAll(RegExp(r'\D'), '') ?? '';
                        if (numeros.isEmpty) {
                          return tr('Informe seu celular com DDD.');
                        }
                        if (numeros.length < 10) {
                          return tr('Digite um número válido com DDD.');
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: DropdownButtonFormField<String>(
                        initialValue: generoSelecionado,
                        autovalidateMode: tentouEnviar
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        decoration: InputDecoration(
                          labelText: tr('Como você se identifica'),
                          helperText: tr(
                            'Campo usado apenas para personalização do perfil.',
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'Feminino',
                            child: Text(tr('Feminino')),
                          ),
                          DropdownMenuItem(
                            value: 'Masculino',
                            child: Text(tr('Masculino')),
                          ),
                          DropdownMenuItem(
                            value: 'Prefiro não informar',
                            child: Text(tr('Prefiro não informar')),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            generoSelecionado = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return tr('Selecione uma opção para continuar.');
                          }
                          return null;
                        },
                      ),
                    ),
                    AppTextField(
                      label: tr('Data de nascimento'),
                      controller: nascimentoController,
                      hint: _birthDateHint(l, languageCode),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _DateTextInputFormatter(),
                      ],
                      autovalidateMode: tentouEnviar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      isFormField: true,
                      validator: (value) => validarDataNascimento(value, l),
                    ),
                  ],
                ),
              ),
              FormSectionCard(
                title: tr('Segurança da conta'),
                subtitle: tr(
                  'Use uma senha forte para proteger seus dados e evitar acessos indevidos.',
                ),
                icon: Icons.lock_outline,
                child: Column(
                  children: [
                    AppTextField(
                      label: tr('Senha'),
                      controller: senhaController,
                      obscureText: ocultarSenha,
                      hint: tr('Crie uma senha forte'),
                      helperText: tr(
                        'Mínimo de 8 caracteres com letras, número e símbolo.',
                      ),
                      autovalidateMode: tentouEnviar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      isFormField: true,
                      validator: (value) =>
                          FormValidators.validateStrongPassword(
                            value,
                            translate: tr,
                          ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            ocultarSenha = !ocultarSenha;
                          });
                        },
                        icon: Icon(
                          ocultarSenha
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    AppTextField(
                      label: tr('Confirmação da senha'),
                      controller: confirmarSenhaController,
                      obscureText: ocultarConfirmarSenha,
                      hint: tr('Repita a senha criada acima'),
                      autovalidateMode: tentouEnviar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      isFormField: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr(
                            'Confirme sua senha para finalizar o cadastro.',
                          );
                        }
                        if (value != senhaController.text) {
                          return tr('A confirmação precisa ser igual à senha.');
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            ocultarConfirmarSenha = !ocultarConfirmarSenha;
                          });
                        },
                        icon: Icon(
                          ocultarConfirmarSenha
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: cadastrando
                          ? tr('Criando conta...')
                          : tr('Criar conta e entrar'),
                      onPressed: cadastrando ? null : cadastrar,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tr('Já tem conta?')),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: Text(tr('Entrar agora')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
