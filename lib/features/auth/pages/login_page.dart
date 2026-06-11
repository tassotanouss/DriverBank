import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
import 'forgot_password_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = const AuthService();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool ocultarSenha = true;
  bool tentouEnviar = false;
  bool enviando = false;
  FormFeedbackType? feedbackType;
  String? feedbackTitle;
  String? feedbackMessage;

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

  Future<void> entrar() async {
    final l = AppLocalizations.of(context);
    final tr = l.text;
    final navigator = Navigator.of(context);
    final currencyController = CurrencyScope.controllerOf(context);

    setState(() {
      tentouEnviar = true;
      enviando = true;
    });

    if (!_formKey.currentState!.validate()) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Revise seus dados'),
        message: tr('Confira o e-mail e a senha antes de continuar.'),
      );
      setState(() {
        enviando = false;
      });
      return;
    }

    final email = FormValidators.normalizeEmail(emailController.text);
    final senha = senhaController.text;

    try {
      final credential = await _authService.signIn(
        email: email,
        password: senha,
      );
      final prefs = await AppPreferences.load(userId: credential.user?.uid);
      final currentUser = _authService.currentUserOrNull;

      await prefs.setString('userEmail', currentUser?.email ?? email);

      final savedName = prefs.getString('userName')?.trim() ?? '';
      final displayName = currentUser?.displayName?.trim() ?? '';
      if (savedName.isEmpty && displayName.isNotEmpty) {
        await prefs.setString('userName', displayName);
      }

      final startDate = prefs.getString('userStartDate')?.trim() ?? '';
      if (startDate.isEmpty) {
        await prefs.setString(
          'userStartDate',
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );
      }

      if (!mounted) {
        return;
      }

      await currencyController.reloadForCurrentUser();
      if (!mounted) {
        return;
      }

      mostrarFeedback(
        type: FormFeedbackType.success,
        title: tr('Login realizado com sucesso.'),
        message: tr('Sua sessão foi restaurada com segurança neste aparelho.'),
      );
      navigator.popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (error) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Acesso não autorizado'),
        message: mapAuthErrorMessage(exception: error, translate: tr),
      );
    } catch (_) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Não foi possível entrar'),
        message: tr('Tente novamente em alguns instantes.'),
      );
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tr = l.text;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Entrar')), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (feedbackType != null &&
                  feedbackTitle != null &&
                  feedbackMessage != null)
                FormFeedbackBanner(
                  title: feedbackTitle!,
                  message: feedbackMessage!,
                  type: feedbackType!,
                ),
              DriverBankHeroCard(
                label: tr('Bem-vindo de volta'),
                value: 'DriveProfit',
                icon: Icons.local_taxi_rounded,
                description: tr(
                  'Entre para acompanhar faturamento, custos e lucro real da sua rotina.',
                ),
              ),
              const SizedBox(height: 18),
              FormSectionCard(
                title: tr('Idioma do aplicativo'),
                subtitle: tr('Você pode trocar o idioma antes de entrar.'),
                icon: Icons.language_outlined,
                child: const LanguageSelectorField(),
              ),
              FormSectionCard(
                title: tr('Acesse sua conta'),
                subtitle: tr(
                  'Use seu e-mail e sua senha cadastrados para continuar.',
                ),
                icon: Icons.login_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: tr('E-mail de acesso'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      hint: tr('nome@exemplo.com'),
                      helperText: tr('Digite o e-mail usado no cadastro.'),
                      isFormField: true,
                      autovalidateMode: tentouEnviar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      validator: (value) =>
                          FormValidators.validateEmail(value, translate: tr),
                    ),
                    AppTextField(
                      label: tr('Senha'),
                      controller: senhaController,
                      obscureText: ocultarSenha,
                      hint: tr('Sua senha de acesso'),
                      autovalidateMode: tentouEnviar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      isFormField: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr('Informe sua senha para entrar.');
                        }
                        return null;
                      },
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
                    const SizedBox(height: 10),
                    AppButton(
                      label: enviando
                          ? tr('Entrando...')
                          : tr('Entrar no aplicativo'),
                      onPressed: enviando ? null : entrar,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: enviando
                            ? null
                            : () {
                                final normalizedEmail =
                                    FormValidators.normalizeEmail(
                                      emailController.text,
                                    );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ForgotPasswordPage(
                                      initialEmail: normalizedEmail,
                                    ),
                                  ),
                                );
                              },
                        child: Text(tr('Esqueci minha senha')),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tr('Ainda não tem conta?')),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignupPage()),
                      );
                    },
                    child: Text(tr('Criar conta')),
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
