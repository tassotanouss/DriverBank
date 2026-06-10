import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../core/utils/currency_scope.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/driverbank_visuals.dart';
import '../../../core/widgets/form_feedback_banner.dart';
import '../../../core/widgets/form_section_card.dart';
import '../../../core/widgets/summary_card.dart';

class MetasPage extends StatefulWidget {
  const MetasPage({super.key});

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> {
  final diariaController = TextEditingController();
  final semanalController = TextEditingController();
  final mensalController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double metaDiaria = 0;
  double metaSemanal = 0;
  double metaMensal = 0;
  bool possuiMetasSalvas = false;
  bool tentouSalvar = false;
  FormFeedbackType? feedbackType;
  String? feedbackTitle;
  String? feedbackMessage;

  @override
  void initState() {
    super.initState();
    carregarMetas();
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

  double toDouble(String valor) {
    return FormValidators.parseDecimal(valor) ?? 0;
  }

  String formatarMoeda(double valor) {
    return CurrencyScope.of(context).format(valor);
  }

  int diasNoMesAtual() {
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month + 1, 0).day;
  }

  void calcularAPartirDaMetaMensal() {
    final tr = AppLocalizations.of(context).text;
    final mensal = toDouble(mensalController.text);
    final diasMes = diasNoMesAtual();

    setState(() {
      metaMensal = mensal;
      metaDiaria = mensal / diasMes;
      metaSemanal = mensal / 4;
      diariaController.text = metaDiaria.toStringAsFixed(2);
      semanalController.text = metaSemanal.toStringAsFixed(2);
    });

    mostrarFeedback(
      type: FormFeedbackType.info,
      title: tr('Metas recalculadas'),
      message: tr(
        'Usamos a meta mensal como base para estimar seus valores diários e semanais.',
      ),
    );
  }

  void calcularAPartirDaMetaSemanal() {
    final tr = AppLocalizations.of(context).text;
    final semanal = toDouble(semanalController.text);

    setState(() {
      metaSemanal = semanal;
      metaDiaria = semanal / 7;
      metaMensal = semanal * 4;
      diariaController.text = metaDiaria.toStringAsFixed(2);
      mensalController.text = metaMensal.toStringAsFixed(2);
    });

    mostrarFeedback(
      type: FormFeedbackType.info,
      title: tr('Metas recalculadas'),
      message: tr(
        'Usamos a meta semanal como referência para preencher os demais períodos.',
      ),
    );
  }

  void calcularAPartirDaMetaDiaria() {
    final tr = AppLocalizations.of(context).text;
    final diaria = toDouble(diariaController.text);
    final diasMes = diasNoMesAtual();

    setState(() {
      metaDiaria = diaria;
      metaSemanal = diaria * 7;
      metaMensal = diaria * diasMes;
      semanalController.text = metaSemanal.toStringAsFixed(2);
      mensalController.text = metaMensal.toStringAsFixed(2);
    });

    mostrarFeedback(
      type: FormFeedbackType.info,
      title: tr('Metas recalculadas'),
      message: tr(
        'Usamos a meta diária como base para projetar sua semana e seu mês.',
      ),
    );
  }

  Future<void> salvarMetas() async {
    final tr = AppLocalizations.of(context).text;

    setState(() {
      tentouSalvar = true;
    });

    if (!_formKey.currentState!.validate()) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Valor inválido'),
        message: tr(
          'Informe ao menos uma meta válida para salvar. Não use números negativos.',
        ),
      );
      return;
    }

    if (metaDiaria == 0 && metaSemanal == 0 && metaMensal == 0) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Nenhuma meta definida'),
        message: tr('Preencha um valor de meta antes de salvar.'),
      );
      return;
    }

    final jaPossuiaMetas = possuiMetasSalvas;
    final prefs = await AppPreferences.load();
    await prefs.setDouble('metaDiaria', metaDiaria);
    await prefs.setDouble('metaSemanal', metaSemanal);
    await prefs.setDouble('metaMensal', metaMensal);

    if (!mounted) return;

    setState(() {
      possuiMetasSalvas = true;
    });

    mostrarFeedback(
      type: FormFeedbackType.success,
      title: jaPossuiaMetas ? tr('Metas atualizadas') : tr('Metas salvas'),
      message: tr('Seus objetivos financeiros foram registrados com sucesso.'),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          jaPossuiaMetas
              ? tr('Metas atualizadas com sucesso.')
              : tr('Metas salvas com sucesso.'),
        ),
      ),
    );
  }

  Future<void> carregarMetas() async {
    final prefs = await AppPreferences.load();

    setState(() {
      metaDiaria = prefs.getDouble('metaDiaria') ?? 0;
      metaSemanal = prefs.getDouble('metaSemanal') ?? 0;
      metaMensal = prefs.getDouble('metaMensal') ?? 0;
      possuiMetasSalvas = metaDiaria > 0 || metaSemanal > 0 || metaMensal > 0;

      diariaController.text = metaDiaria == 0
          ? ''
          : metaDiaria.toStringAsFixed(2);
      semanalController.text = metaSemanal == 0
          ? ''
          : metaSemanal.toStringAsFixed(2);
      mensalController.text = metaMensal == 0
          ? ''
          : metaMensal.toStringAsFixed(2);
    });
  }

  String? validarMeta(String? value) {
    return FormValidators.validateNonNegativeNumber(
      value,
      translate: AppLocalizations.of(context).text,
    );
  }

  Widget buildResumoMetas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final larguraCard = constraints.maxWidth >= 720
            ? (constraints.maxWidth - 16) / 3
            : constraints.maxWidth;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SizedBox(
              width: larguraCard,
              child: SummaryCard(
                title: 'Meta diária',
                value: formatarMoeda(metaDiaria),
                compact: true,
              ),
            ),
            SizedBox(
              width: larguraCard,
              child: SummaryCard(
                title: 'Meta semanal',
                value: formatarMoeda(metaSemanal),
                compact: true,
              ),
            ),
            SizedBox(
              width: larguraCard,
              child: SummaryCard(
                title: 'Meta mensal',
                value: formatarMoeda(metaMensal),
                compact: true,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    diariaController.dispose();
    semanalController.dispose();
    mensalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context).text;
    final acaoPrincipal = possuiMetasSalvas
        ? tr('Atualizar metas')
        : tr('Salvar metas');
    final currency = CurrencyScope.of(context);
    final metaDiariaHint = currency.inputExample(250);
    final metaSemanalHint = currency.inputExample(1750);
    final metaMensalHint = currency.inputExample(8000);

    return Scaffold(
      appBar: AppBar(title: Text(tr('Metas')), centerTitle: true),
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
                label: tr('Meta mensal planejada'),
                value: formatarMoeda(metaMensal),
                icon: Icons.flag_rounded,
                description: tr(
                  'O app calcula automaticamente uma meta diária e semanal a partir do valor base.',
                ),
              ),
              const SizedBox(height: 18),
              FormSectionCard(
                title: tr('Planejamento de ganhos'),
                subtitle: tr(
                  'Preencha apenas uma meta base. O app recalcula os outros períodos automaticamente.',
                ),
                icon: Icons.flag_outlined,
                child: Column(
                  children: [
                    AppTextField(
                      label: tr('Meta diária'),
                      hint: metaDiariaHint,
                      controller: diariaController,
                      autovalidateMode: tentouSalvar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: currency.inputPrefix,
                      isFormField: true,
                      validator: validarMeta,
                      onChanged: (_) => calcularAPartirDaMetaDiaria(),
                    ),
                    AppTextField(
                      label: tr('Meta semanal'),
                      hint: metaSemanalHint,
                      controller: semanalController,
                      autovalidateMode: tentouSalvar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: currency.inputPrefix,
                      isFormField: true,
                      validator: validarMeta,
                      onChanged: (_) => calcularAPartirDaMetaSemanal(),
                    ),
                    AppTextField(
                      label: tr('Meta mensal'),
                      hint: metaMensalHint,
                      controller: mensalController,
                      autovalidateMode: tentouSalvar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: currency.inputPrefix,
                      isFormField: true,
                      validator: validarMeta,
                      onChanged: (_) => calcularAPartirDaMetaMensal(),
                    ),
                  ],
                ),
              ),
              FormSectionCard(
                title: tr('Resumo das metas'),
                subtitle: tr(
                  'Os valores abaixo mostram como suas metas ficaram distribuídas.',
                ),
                icon: Icons.insights_outlined,
                child: Column(
                  children: [
                    Row(
                      children: [
                        SummaryCard(
                          title: tr('Meta diária'),
                          value: formatarMoeda(metaDiaria),
                          compact: true,
                          expanded: true,
                        ),
                        SummaryCard(
                          title: tr('Meta semanal'),
                          value: formatarMoeda(metaSemanal),
                          compact: true,
                          expanded: true,
                        ),
                        SummaryCard(
                          title: tr('Meta mensal'),
                          value: formatarMoeda(metaMensal),
                          compact: true,
                          expanded: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppButton(label: acaoPrincipal, onPressed: salvarMetas),
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
