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
            
