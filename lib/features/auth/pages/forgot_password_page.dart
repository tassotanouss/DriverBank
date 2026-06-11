import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/driverbank_visuals.dart';
import '../../../core/widgets/form_feedback_banner.dart';
import '../../../core/widgets/form_section_card.dart';
import '../services/auth_service.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _authService = const AuthService();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool tentouEnviar = false;
  bool enviando = false;
  FormFeedbackType? feedbackType;
  String? feedbackTitle;
  String? feedbackMessage;

  @override
  void initState() {
    super.initState();
    emailController.text = FormValidators.normalizeEmail(
      widget.initialEmail ?? '',
    );
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

  Future<void> enviarLink() async {
    final tr = AppLocalizations.of(context).text;
    final normalizedEmail = FormValidators.normalizeEmail(emailController.text);

    setState(() {
      tentouEnviar = true;
      enviando = true;
    });

    if (!_formKey.currentState!.validate()) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Revise seus dados'),
        message: tr('Informe um e-mail válido para recuperar a senha.'),
      );
      setState(() {
        enviando = false;
      });
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email: normalizedEmail);

      if (!mounted) {
        return;
      }

      mostrarFeedback(
        type: FormFeedbackType.success,
        title: tr('Link enviado'),
        message: tr(
          'Se existir uma conta com o e-mail {email}, você receberá as instruções de redefinição. Confira também Spam, Lixeira e Promoções.',
          params: {'email': normalizedEmail},
        ),
      );
    } on FirebaseAuthException catch (error) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Não foi possível enviar o link'),
        message: mapAuthErrorMessage(exception: error, translate: tr),
      );
    } catch (_) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Não foi possível enviar o link'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context).text;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Recuperar senha')), centerTitle: true),
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
              DriverBankHeroCard(
                label: tr('Recuperar acesso'),
                value: tr('Senha'),
                icon: Icons.lock_reset_rounded,
                description: tr(
                  'Receba um link seguro para voltar a acessar seus dados financeiros.',
                ),
              ),
              const SizedBox(height: 18),
              FormSectionCard(
                title: tr('Recuperação de acesso'),
                subtitle: tr(
                  'Informe o e-mail da conta para receber o link de redefinição.',
                ),
                icon: Icons.mark_email_read_outlined,
                child: Column(
                  children: [
                    AppTextField(
                      label: tr('E-mail de acesso'),
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      hint: tr('nome@exemplo.com'),
                      helperText: tr(
                        'Use exatamente o mesmo e-mail cadastrado. Se a mensagem não chegar, confira Spam, Lixeira e Promoções.',
                      ),
                      isFormField: true,
                      autovalidateMode: tentouEnviar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      validator: (value) =>
                          FormValidators.validateEmail(value, translate: tr),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: enviando
                          ? tr('Enviando...')
                          : tr('Enviar link de recuperação'),
                      onPressed: enviando ? null : enviarLink,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
