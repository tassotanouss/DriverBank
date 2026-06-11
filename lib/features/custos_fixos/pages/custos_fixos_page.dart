import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../core/utils/currency_scope.dart';
import '../../../core/utils/custos_fixos_helper.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/driverbank_visuals.dart';
import '../../../core/widgets/form_feedback_banner.dart';
import '../../../core/widgets/form_section_card.dart';
import '../../../core/widgets/summary_card.dart';

class CustosFixosPage extends StatefulWidget {
  const CustosFixosPage({super.key});

  @override
  State<CustosFixosPage> createState() => _CustosFixosPageState();
}

class _CustosFixosPageState extends State<CustosFixosPage> {
  final TextEditingController parcelaController = TextEditingController();
  final TextEditingController seguroController = TextEditingController();
  final TextEditingController ipvaController = TextEditingController();
  final TextEditingController manutencaoController = TextEditingController();
  final TextEditingController outrosController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double totalMensal = 0;
  double custoDiario = 0;
  int diasDoMes = 30;
  bool tentouSalvar = false;
  bool possuiCustosSalvos = false;
  FormFeedbackType? feedbackType;
  String? feedbackTitle;
  String? feedbackMessage;

  @override
  void initState() {
    super.initState();
    calcularDiasDoMes();
    carregarDados();
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

  void calcularDiasDoMes() {
    final agora = DateTime.now();
    final ultimoDia = DateTime(agora.year, agora.month + 1, 0);

    setState(() {
      diasDoMes = ultimoDia.day;
    });
  }

  double toDouble(String valor) {
    return FormValidators.parseDecimal(valor) ?? 0;
  }

  String formatarMoeda(double valor) {
    return CurrencyScope.of(context).format(valor);
  }

  Future<void> salvarDados() async {
    final prefs = await AppPreferences.load();

    await prefs.setString('parcela', parcelaController.text);
    await prefs.setString('seguro', seguroController.text);
    await prefs.setString('ipva', ipvaController.text);
    await prefs.setString('manutencao', manutencaoController.text);
    await prefs.setString('outros', outrosController.text);
  }

  Future<void> carregarDados() async {
    final prefs = await AppPreferences.load();

    parcelaController.text = prefs.getString('parcela') ?? '';
    seguroController.text = prefs.getString('seguro') ?? '';
    ipvaController.text = prefs.getString('ipva') ?? '';
    manutencaoController.text = prefs.getString('manutencao') ?? '';
    outrosController.text = prefs.getString('outros') ?? '';

    setState(() {
      possuiCustosSalvos = [
        parcelaController.text,
        seguroController.text,
        ipvaController.text,
        manutencaoController.text,
        outrosController.text,
      ].any((value) => value.trim().isNotEmpty);
    });

    calcularCustos();
  }

  void calcularCustos() {
    final parcela = toDouble(parcelaController.text);
    final seguro = toDouble(seguroController.text);
    final ipva = toDouble(ipvaController.text);
    final manutencao = toDouble(manutencaoController.text);
    final outros = toDouble(outrosController.text);

    final total = CustosFixosHelper.obterTotalMensal(
      parcela: parcela,
      seguro: seguro,
      ipva: ipva,
      manutencao: manutencao,
      outros: outros,
    );
    final diario = CustosFixosHelper.obterCustoDiario(DateTime.now(), total);

    setState(() {
      totalMensal = total;
      custoDiario = diario;
    });
  }

  Future<void> salvarCustos() async {
    final tr = AppLocalizations.of(context).text;

    setState(() {
      tentouSalvar = true;
    });

    final camposPreenchidos = [
      parcelaController.text,
      seguroController.text,
      ipvaController.text,
      manutencaoController.text,
      outrosController.text,
    ].any((value) => value.trim().isNotEmpty);

    if (!camposPreenchidos) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Nenhum custo informado'),
        message: tr('Preencha pelo menos um valor antes de salvar.'),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Existem campos para revisar'),
        message: tr(
          'Preencha ao menos um custo com valor válido para salvar sua configuração.',
        ),
      );
      return;
    }

    final jaPossuiaCustos = possuiCustosSalvos;
    calcularCustos();
    await salvarDados();

    if (!mounted) return;

    setState(() {
      possuiCustosSalvos = true;
    });

    mostrarFeedback(
      type: FormFeedbackType.success,
      title: jaPossuiaCustos ? tr('Custos atualizados') : tr('Custos salvos'),
      message: tr(
        'Seus custos fixos foram registrados e já podem ser usados nos cálculos diários.',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          jaPossuiaCustos
              ? tr('Custos fixos atualizados com sucesso.')
              : tr('Custos fixos salvos com sucesso.'),
        ),
      ),
    );
  }

  String? validarValorMonetario(String? value, {bool obrigatorio = false}) {
    return FormValidators.validateNonNegativeNumber(
      value,
      required: obrigatorio,
      requiredMessage: 'Informe um valor para este campo.',
      translate: AppLocalizations.of(context).text,
    );
  }

  @override
  void dispose() {
    parcelaController.dispose();
    seguroController.dispose();
    ipvaController.dispose();
    manutencaoController.dispose();
    outrosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context).text;
    final acaoPrincipal = possuiCustosSalvos
        ? tr('Atualizar custos fixos')
        : tr('Salvar custos fixos');
    final currency = CurrencyScope.of(context);
    final parcelaHint = currency.inputExample(1450);
    final seguroHint = currency.inputExample(320);
    final ipvaHint = currency.inputExample(180);
    final manutencaoHint = currency.inputExample(250);
    final outrosHint = currency.inputExample(90);

    return Scaffold(
      appBar: AppBar(title: Text(tr('Custos fixos')), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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
                label: tr('Custo fixo mensal'),
                value: formatarMoeda(totalMensal),
                icon: Icons.account_balance_wallet_outlined,
                description: tr(
                  'Equivale a {value} por dia neste mês, mesmo em dias sem trabalho.',
                  params: {'value': formatarMoeda(custoDiario)},
                ),
              ),
              const SizedBox(height: 18),
              FormSectionCard(
                title: tr('Resumo mensal'),
                subtitle: tr(
                  'Veja quanto seus custos recorrentes representam no mês e no dia.',
                ),
                icon: Icons.pie_chart_outline,
                child: Row(
                  children: [
                    SummaryCard(
                      title: tr('TOTAL MENSAL'),
                      value: formatarMoeda(totalMensal),
                      compact: true,
                      expanded: true,
                    ),
                    SummaryCard(
                      title: tr('CUSTO DIÁRIO'),
                      value: formatarMoeda(custoDiario),
                      compact: true,
                      expanded: true,
                    ),
                    SummaryCard(
                      title: tr('DIAS DO MÊS'),
                      value: diasDoMes.toString(),
                      compact: true,
                      expanded: true,
                    ),
                  ],
                ),
              ),
              FormSectionCard(
                title: tr('Despesas recorrentes'),
                subtitle: tr(
                  'Preencha apenas o que realmente faz parte da sua rotina mensal. Os totais são atualizados em tempo real.',
                ),
                icon: Icons.receipt_long_outlined,
                child: Column(
                  children: [
                    AppTextField(
                      label: tr('Parcela do carro'),
                      hint: parcelaHint,
                      controller: parcelaController,
                      helperText: tr(
                        'Inclua aqui financiamentos ou leasing do veículo.',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: currency.inputPrefix,
                      isFormField: true,
                      autovalidateMode: tentouSalvar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (_) => calcularCustos(),
                      validator: validarValorMonetario,
                    ),
                    AppTextField(
                      label: tr('Seguro do veículo'),
                      hint: seguroHint,
                      controller: seguroController,
                      helperText: tr('Valor médio mensal do seguro.'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: currency.inputPrefix,
                      isFormField: true,
                      autovalidateMode: tentouSalvar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (_) => calcularCustos(),
                      validator: validarValorMonetario,
                    ),
                    AppTextField(
                      label: tr('IPVA provisionado'),
                      hint: ipvaHint,
                      controller: ipvaController,
                      helperText: tr(
                        'Use o valor mensal reservado para o imposto.',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: currency.inputPrefix,
                      isFormField: true,
                      autovalidateMode: tentouSalvar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (_) => calcularCustos(),
                      validator: validarValorMonetario,
                    ),
                    AppTextField(
                      label: tr('Reserva para manutenção'),
                      hint: manutencaoHint,
                      controller: manutencaoController,
                      helperText: tr(
                        'Considere revisões, pneus e pequenos reparos.',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: currency.inputPrefix,
                      isFormField: true,
                      autovalidateMode: tentouSalvar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (_) => calcularCustos(),
                      validator: validarValorMonetario,
                    ),
                    AppTextField(
                      label: tr('Outros'),
                      hint: outrosHint,
                      controller: outrosController,
                      helperText: tr(
                        'Inclua qualquer outro gasto mensal recorrente que não se encaixe nas categorias acima.',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefixText: currency.inputPrefix,
                      isFormField: true,
                      autovalidateMode: tentouSalvar
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      onChanged: (_) => calcularCustos(),
                      validator: validarValorMonetario,
                    ),
                    const SizedBox(height: 8),
                    AppButton(label: acaoPrincipal, onPressed: salvarCustos),
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
