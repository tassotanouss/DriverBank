import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/drive_profit_theme.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../core/utils/currency_scope.dart';
import '../../../core/utils/custos_fixos_helper.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/driverbank_visuals.dart';
import '../../../core/widgets/form_feedback_banner.dart';
import '../../../core/widgets/form_section_card.dart';
import '../../../core/widgets/language_selector_field.dart';
import '../../auth/services/auth_service.dart';
import '../../custos_fixos/pages/custos_fixos_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _authService = const AuthService();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final celularController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool carregando = true;
  bool tentandoSalvar = false;
  String moedaSelecionada = 'BRL';
  String dataInicioUso = '';
  double totalCustosFixos = 0;
  double custoFixoDiario = 0;
  FormFeedbackType? feedbackType;
  String? feedbackTitle;
  String? feedbackMessage;

  @override
  void initState() {
    super.initState();
    carregarPerfil();
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

  Future<void> carregarPerfil() async {
    try {
      final prefs = await AppPreferences.load();
      final total = CustosFixosHelper.obterTotalMensalDosPrefs(prefs);
      final hoje = DateTime.now();
      final custoDiarioCalculado = CustosFixosHelper.obterCustoDiario(
        hoje,
        total,
      );
      final currentUser = _authService.currentUserOrNull;
      final dataInicioSalva = prefs.getString('userStartDate');

      if (dataInicioSalva == null || dataInicioSalva.trim().isEmpty) {
        await prefs.setString(
          'userStartDate',
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        nomeController.text =
            prefs.getString('userName') ?? currentUser?.displayName ?? '';
        emailController.text =
            currentUser?.email ?? prefs.getString('userEmail') ?? '';
        celularController.text = prefs.getString('userPhone') ?? '';
        moedaSelecionada = prefs.getString('userCurrency') ?? 'BRL';
        dataInicioUso = prefs.getString('userStartDate') ?? '';
        totalCustosFixos = total;
        custoFixoDiario = custoDiarioCalculado;
        carregando = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        carregando = false;
      });
    }
  }

  Future<void> salvarPerfil() async {
    final tr = AppLocalizations.of(context).text;
    final currencyController = CurrencyScope.controllerOf(context);

    setState(() {
      tentandoSalvar = true;
    });

    if (!_formKey.currentState!.validate()) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Revise seus dados'),
        message: tr('Confira nome e celular antes de salvar as configurações.'),
      );
      return;
    }

    try {
      final prefs = await AppPreferences.load();

      await prefs.setString('userName', nomeController.text.trim());
      await prefs.setString('userEmail', emailController.text.trim());
      await prefs.setString('userPhone', celularController.text.trim());
      await _authService.updateDisplayName(nomeController.text.trim());
      await currencyController.setCurrency(moedaSelecionada);

      if (!mounted) {
        return;
      }

      mostrarFeedback(
        type: FormFeedbackType.success,
        title: tr('Configurações salvas'),
        message: tr('Seu perfil foi atualizado com sucesso neste aparelho.'),
      );
    } catch (_) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Não foi possível salvar'),
        message: tr('Tente novamente em alguns instantes.'),
      );
    }
  }

  Future<void> sair() async {
    await _authService.signOut();
  }

  String formatarMoeda(double valor) {
    return CurrencyController.fromCode(moedaSelecionada).format(valor);
  }

  String formatarDataInicio(String value) {
    final tr = AppLocalizations.of(context).text;

    if (value.trim().isEmpty) {
      return tr('Ainda não registrada');
    }

    final data = DateTime.tryParse(value);
    if (data == null) {
      return value;
    }

    final locale = AppLocalizations.dateLocaleOf(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final pattern = languageCode == 'en'
        ? 'MMMM d, yyyy'
        : "d 'de' MMMM 'de' yyyy";

    return DateFormat(pattern, locale).format(data);
  }

  Widget actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final accentColor = destructive
        ? context.driveProfitPalette.loss
        : Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: DriveProfitTheme.tintedCardDecoration(
        context,
        tint: destructive
            ? const Color(0xFFFBEAEA)
            : context.driveProfitPalette.cardTint,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Icon(icon, color: accentColor),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: destructive ? context.driveProfitPalette.loss : null,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right_rounded, color: accentColor),
        onTap: onTap,
      ),
    );
  }

  Widget infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: DriveProfitTheme.tintedCardDecoration(context),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tr = l.text;
    final displayName = nomeController.text.trim().isEmpty
        ? tr('Motorista DriveProfit')
        : nomeController.text.trim();

    if (carregando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Perfil e configurações')),
        centerTitle: true,
      ),
      body: ListView(
        cacheExtent: 1000,
        padding: const EdgeInsets.all(18),
        children: [
          DriverBankHeroCard(
            label: tr('Perfil do motorista'),
            value: displayName,
            icon: Icons.person_rounded,
            description: tr(
              'Organize seus dados, idioma, moeda e custos principais em um só lugar.',
            ),
          ),
          const SizedBox(height: 18),
          FormSectionCard(
            title: tr('Moeda do aplicativo'),
            subtitle: tr(
              'Escolha como os valores financeiros devem aparecer nas telas.',
            ),
            icon: Icons.payments_outlined,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: moedaSelecionada,
                  decoration: InputDecoration(
                    labelText: tr('Moeda'),
                    helperText: tr(
                      'Define a preferência monetária salva para o perfil.',
                    ),
                  ),
                  items: CurrencyController.supportedCurrencies
                      .map(
                        (option) => DropdownMenuItem(
                          value: option.code,
                          child: Text('${tr(option.label)} (${option.symbol})'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      moedaSelecionada = value;
                    });
                  },
                ),
                const SizedBox(height: 10),
                AppButton(
                  label: tr('Salvar configurações'),
                  onPressed: salvarPerfil,
                  icon: Icons.save_outlined,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: DriveProfitTheme.tintedCardDecoration(context),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.text(
                          'Organize seus dados de acesso e suas preferências principais em um só lugar.',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          FormSectionCard(
            title: tr('Idioma do aplicativo'),
            subtitle: tr('Escolha o idioma usado em todas as telas do app.'),
            icon: Icons.language_outlined,
            child: const LanguageSelectorField(),
          ),
          Form(
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
                  title: tr('Dados da conta'),
                  subtitle: tr(
                    'Essas informações ajudam a identificar o usuário e deixam o app mais pronto para uso comercial.',
                  ),
                  icon: Icons.person_outline_rounded,
                  child: Column(
                    children: [
                      AppTextField(
                        label: tr('Nome'),
                        controller: nomeController,
                        hint: tr('Como você quer aparecer no app'),
                        isFormField: true,
                        autovalidateMode: tentandoSalvar
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return tr('Informe o nome do usuário.');
                          }
                          return null;
                        },
                      ),
                      AppTextField(
                        label: tr('E-mail'),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        hint: tr('nome@exemplo.com'),
                        helperText: tr(
                          'O e-mail de login é gerenciado pela autenticação e não pode ser alterado aqui.',
                        ),
                        readOnly: true,
                        isFormField: true,
                        validator: (value) =>
                            FormValidators.validateEmail(value, translate: tr),
                      ),
                      AppTextField(
                        label: tr('Celular'),
                        controller: celularController,
                        keyboardType: TextInputType.phone,
                        hint: tr('(11) 99999-9999'),
                        isFormField: true,
                        autovalidateMode: tentandoSalvar
                            ? AutovalidateMode.onUserInteraction
                            : AutovalidateMode.disabled,
                        validator: (value) {
                          final numeros =
                              value?.replaceAll(RegExp(r'\D'), '') ?? '';
                          if (numeros.isEmpty) {
                            return tr('Informe um celular para contato.');
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
                          initialValue: moedaSelecionada,
                          autovalidateMode: tentandoSalvar
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          decoration: InputDecoration(
                            labelText: tr('Moeda'),
                            helperText: tr(
                              'Define a preferência monetária salva para o perfil.',
                            ),
                          ),
                          items: CurrencyController.supportedCurrencies
                              .map(
                                (option) => DropdownMenuItem(
                                  value: option.code,
                                  child: Text(
                                    '${tr(option.label)} (${option.symbol})',
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              moedaSelecionada = value;
                            });
                          },
                        ),
                      ),
                      infoCard(
                        icon: Icons.event_available_outlined,
                        label: tr('Data de início de uso'),
                        value: formatarDataInicio(dataInicioUso),
                      ),
                      const SizedBox(height: 6),
                      AppButton(
                        label: tr('Salvar configurações'),
                        onPressed: salvarPerfil,
                        icon: Icons.save_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          FormSectionCard(
            title: tr('Custos fixos'),
            subtitle: tr(
              'O app continua com a configuração detalhada na tela própria, mas você consegue acompanhar o resumo daqui.',
            ),
            icon: Icons.account_balance_wallet_outlined,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: DriveProfitTheme.tintedCardDecoration(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.text(
                          'Total mensal: {value}',
                          params: {'value': formatarMoeda(totalCustosFixos)},
                        ),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr(
                          'Custo diário estimado: {value}',
                          params: {'value': formatarMoeda(custoFixoDiario)},
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: tr('Editar custos fixos'),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustosFixosPage(),
                      ),
                    );
                    await carregarPerfil();
                  },
                  icon: Icons.tune_rounded,
                ),
              ],
            ),
          ),
          actionTile(
            icon: Icons.logout_rounded,
            title: tr('Sair da conta'),
            subtitle: tr('Encerrar a sessão neste aparelho.'),
            onTap: sair,
            destructive: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    celularController.dispose();
    super.dispose();
  }
}
