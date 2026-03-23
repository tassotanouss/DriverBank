import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/drive_profit_theme.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../core/utils/currency_scope.dart';
import '../../../core/utils/custos_fixos_helper.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/widgets/form_feedback_banner.dart';
import '../../../core/widgets/form_section_card.dart';
import '../../../models/lancamento_model.dart';

class LancamentosPage extends StatefulWidget {
  const LancamentosPage({super.key});

  @override
  State<LancamentosPage> createState() => _LancamentosPageState();
}

class _LancamentosPageState extends State<LancamentosPage> {
  final faturamentoController = TextEditingController();
  final kmInicialController = TextEditingController();
  final kmFinalController = TextEditingController();
  final corridasController = TextEditingController();
  final horasController = TextEditingController();
  final combustivelController = TextEditingController();
  final extrasController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  double lucro = 0;
  double kmRodado = 0;
  double custoDiario = 0;
  double custoFixoAplicadoHoje = 0;
  bool tentouSalvar = false;
  bool existeLancamentoHoje = false;
  FormFeedbackType? feedbackType;
  String? feedbackTitle;
  String? feedbackMessage;
  LancamentoModel? lancamentoEmEdicao;

  List<LancamentoModel> historico = [];

  DateTime dataInicioUso = DateTime.now();

  @override
  void initState() {
    super.initState();
    carregarCustoDiario();
    carregarHistorico();
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

  int toInt(String valor) {
    return FormValidators.parseInteger(valor) ?? 0;
  }

  double? toNullableDouble(String valor) {
    return FormValidators.parseDecimal(valor);
  }

  String formatarMoeda(double valor) {
    return CurrencyScope.of(context).format(valor);
  }

  String formatarData(String data) {
    final dataConvertida = DateTime.parse(data);
    final locale = AppLocalizations.dateLocaleOf(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final pattern = languageCode == 'en' ? 'MM/dd/yyyy' : 'dd/MM/yyyy';
    return DateFormat(pattern, locale).format(dataConvertida);
  }

  String get hojeFormatado => DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool get editandoLancamento => lancamentoEmEdicao != null;

  bool get editandoOutroDia =>
      lancamentoEmEdicao != null && lancamentoEmEdicao!.data != hojeFormatado;

  Future<void> carregarCustoDiario() async {
    final prefs = await AppPreferences.load();
    final totalMensal = CustosFixosHelper.obterTotalMensalDosPrefs(prefs);

    final agora = DateTime.now();

    setState(() {
      custoDiario = CustosFixosHelper.obterCustoDiario(agora, totalMensal);
    });
  }

  Future<void> carregarHistorico() async {
    final prefs = await AppPreferences.load();
    final dataInicioSalva = prefs.getString('userStartDate');

    dataInicioUso = DateTime.tryParse(dataInicioSalva ?? '') ?? DateTime.now();

    final listaString = prefs.getStringList('lancamentos') ?? [];

    final lista = listaString
        .map((item) => LancamentoModel.fromJson(jsonDecode(item)))
        .toList();

    lista.sort((a, b) => b.data.compareTo(a.data));

    setState(() {
      historico = lista;
      existeLancamentoHoje = lista.any((item) => item.data == hojeFormatado);
    });
  }

  void preencherFormulario(LancamentoModel item) {
    faturamentoController.text = item.faturamento == 0
        ? ''
        : item.faturamento.toStringAsFixed(2);
    kmInicialController.text = item.kmInicial?.toStringAsFixed(1) ?? '';
    kmFinalController.text = item.kmFinal?.toStringAsFixed(1) ?? '';
    corridasController.text = item.corridas == 0
        ? ''
        : item.corridas.toString();
    horasController.text = item.horas;
    combustivelController.text = item.combustivel == 0
        ? ''
        : item.combustivel.toStringAsFixed(2);
    extrasController.text = item.extras == 0
        ? ''
        : item.extras.toStringAsFixed(2);

    setState(() {
      lancamentoEmEdicao = item;
      kmRodado = item.km;
      custoFixoAplicadoHoje = item.custoFixoAplicado;
      lucro = item.lucro;
      tentouSalvar = false;
    });
  }

  void limparFormulario({bool limparResumo = false}) {
    faturamentoController.clear();
    kmInicialController.clear();
    kmFinalController.clear();
    corridasController.clear();
    horasController.clear();
    combustivelController.clear();
    extrasController.clear();

    setState(() {
      lancamentoEmEdicao = null;
      tentouSalvar = false;
      if (limparResumo) {
        kmRodado = 0;
        custoFixoAplicadoHoje = 0;
        lucro = 0;
      }
    });
  }

  DateTime limparHora(DateTime data) {
    return DateTime(data.year, data.month, data.day);
  }

  DateTime? calcularDataInicialPendencia(List<LancamentoModel> lista) {
    final hoje = limparHora(DateTime.now());

    if (hoje.isBefore(limparHora(dataInicioUso))) {
      return null;
    }

    if (lista.isEmpty) {
      return limparHora(dataInicioUso);
    }

    final listaOrdenada = [...lista]..sort((a, b) => b.data.compareTo(a.data));

    final ultimoLancamento = limparHora(
      DateTime.parse(listaOrdenada.first.data),
    );
    final existeLancamentoHojeNaLista = ultimoLancamento == hoje;

    if (existeLancamentoHojeNaLista) {
      return hoje;
    }

    return ultimoLancamento.add(const Duration(days: 1));
  }

  Future<void> salvarLancamento({
    required String dataReferencia,
    required double custoFixoAplicado,
    required double lucroCalculado,
    required double kmCalculado,
    required bool parcial,
  }) async {
    final prefs = await AppPreferences.load();

    final faturamento = toDouble(faturamentoController.text);
    final kmInicial = toNullableDouble(kmInicialController.text);
    final kmFinal = toNullableDouble(kmFinalController.text);
    final combustivel = toDouble(combustivelController.text);
    final extras = toDouble(extrasController.text);
    final corridas = toInt(corridasController.text);
    final horas = horasController.text.trim();

    final listaString = prefs.getStringList('lancamentos') ?? [];

    final lista = listaString
        .map((item) => LancamentoModel.fromJson(jsonDecode(item)))
        .toList();

    final lancamento = LancamentoModel(
      data: dataReferencia,
      faturamento: faturamento,
      km: kmCalculado,
      kmInicial: kmInicial,
      kmFinal: kmFinal,
      combustivel: combustivel,
      extras: extras,
      lucro: lucroCalculado,
      corridas: corridas,
      horas: horas,
      custoFixoAplicado: custoFixoAplicado,
      parcial: parcial,
    );

    final indexExistente = lista.indexWhere(
      (item) => item.data == lancamento.data,
    );

    if (indexExistente >= 0) {
      lista[indexExistente] = lancamento;
    } else {
      lista.add(lancamento);
    }

    final novaLista = lista.map((item) => jsonEncode(item.toJson())).toList();

    await prefs.setStringList('lancamentos', novaLista);
  }

  Future<void> calcular() async {
    final tr = AppLocalizations.of(context).text;

    setState(() {
      tentouSalvar = true;
    });

    if (!_formKey.currentState!.validate()) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Existem dados para revisar'),
        message: tr(
          'Confira os campos destacados. Corrija os formatos inválidos antes de salvar.',
        ),
      );
      return;
    }

    final prefs = await AppPreferences.load();
    final listaString = prefs.getStringList('lancamentos') ?? [];

    final lista = listaString
        .map((item) => LancamentoModel.fromJson(jsonDecode(item)))
        .toList();
    final totalMensalCustosFixos = CustosFixosHelper.obterTotalMensalDosPrefs(
      prefs,
    );

    final faturamento = toDouble(faturamentoController.text);
    final kmInicial = toNullableDouble(kmInicialController.text);
    final kmFinal = toNullableDouble(kmFinalController.text);
    final corridas = toInt(corridasController.text);
    final horasInformadas = horasController.text.trim();
    final minutosTrabalhados =
        FormValidators.parseDurationInMinutes(horasInformadas) ?? 0;
    final combustivel = toDouble(combustivelController.text);
    final extras = toDouble(extrasController.text);

    final salvandoParcial = podeSalvarSomenteKmInicial(
      kmInicial: kmInicial,
      kmFinal: kmFinal,
      faturamento: faturamento,
      corridas: corridas,
      horas: horasInformadas,
      combustivel: combustivel,
      extras: extras,
    );

    final km = kmInicial != null && kmFinal != null ? kmFinal - kmInicial : 0.0;

    final erroIncoerencia = salvandoParcial
        ? null
        : validarCoerenciaLancamento(
            faturamento: faturamento,
            kmInicialInformado: kmInicial != null,
            kmFinalInformado: kmFinal != null,
            kmRodado: km,
            corridas: corridas,
            minutosTrabalhados: minutosTrabalhados,
            combustivel: combustivel,
            extras: extras,
          );

    if (erroIncoerencia != null) {
      mostrarFeedback(
        type: FormFeedbackType.error,
        title: tr('Dados incoerentes no lançamento'),
        message: erroIncoerencia,
      );
      return;
    }

    final dataInicialPendencia = calcularDataInicialPendencia(lista);
    final hoje = limparHora(DateTime.now());
    final custoFixoAplicado = salvandoParcial
        ? 0.0
        : editandoOutroDia
        ? (lancamentoEmEdicao?.custoFixoAplicado ?? 0)
        : dataInicialPendencia == null
        ? 0.0
        : CustosFixosHelper.obterCustoAcumuladoNoPeriodo(
            inicio: dataInicialPendencia,
            fim: hoje,
            totalMensal: totalMensalCustosFixos,
          );
    final resultado = salvandoParcial
        ? 0.0
        : faturamento - (custoFixoAplicado + combustivel + extras);
    final dataReferencia = lancamentoEmEdicao?.data ?? hojeFormatado;
    final jaExistia = lista.any((item) => item.data == dataReferencia);

    setState(() {
      kmRodado = km;
      custoFixoAplicadoHoje = custoFixoAplicado;
      lucro = resultado;
    });

    await salvarLancamento(
      dataReferencia: dataReferencia,
      custoFixoAplicado: custoFixoAplicado,
      lucroCalculado: resultado,
      kmCalculado: km,
      parcial: salvandoParcial,
    );
    await carregarHistorico();

    if (!mounted) return;

    final titulo = salvandoParcial
        ? tr('KM inicial salvo')
        : jaExistia
        ? tr('Lançamento atualizado')
        : tr('Lançamento salvo');
    final mensagemFeedback = salvandoParcial
        ? tr(
            'O KM inicial de {date} foi registrado. Você pode voltar depois para completar o restante do dia.',
            params: {'date': formatarData(dataReferencia)},
          )
        : editandoOutroDia
        ? tr(
            'O lançamento de {date} foi atualizado.',
            params: {'date': formatarData(dataReferencia)},
          )
        : tr(
            'O resultado de hoje foi registrado. Custo fixo aplicado: {value}.',
            params: {'value': formatarMoeda(custoFixoAplicadoHoje)},
          );

    mostrarFeedback(
      type: FormFeedbackType.success,
      title: titulo,
      message: mensagemFeedback,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          editandoOutroDia
              ? tr(
                  'Lançamento de {date} atualizado com sucesso.',
                  params: {'date': formatarData(dataReferencia)},
                )
              : salvandoParcial
              ? tr('KM inicial salvo com sucesso.')
              : jaExistia
              ? tr('Lançamento atualizado com sucesso.')
              : tr('Lançamento salvo com sucesso.'),
        ),
      ),
    );

    if (editandoOutroDia) {
      limparFormulario();
    }
  }

  Future<void> confirmarExclusao(LancamentoModel item) async {
    final tr = AppLocalizations.of(context).text;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tr('Excluir lançamento')),
          content: Text(
            tr(
              'Deseja excluir o lançamento de {date}? Essa ação não poderá ser desfeita.',
              params: {'date': formatarData(item.data)},
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(tr('Cancelar')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(tr('Excluir')),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    final prefs = await AppPreferences.load();
    final listaString = prefs.getStringList('lancamentos') ?? [];

    final lista = listaString
        .map((registro) => LancamentoModel.fromJson(jsonDecode(registro)))
        .where((registro) => registro.data != item.data)
        .toList();

    await prefs.setStringList(
      'lancamentos',
      lista.map((registro) => jsonEncode(registro.toJson())).toList(),
    );

    if (!mounted) return;

    if (lancamentoEmEdicao?.data == item.data) {
      limparFormulario(limparResumo: true);
    }

    await carregarHistorico();

    if (!mounted) return;

    mostrarFeedback(
      type: FormFeedbackType.success,
      title: tr('Lançamento excluído'),
      message: tr(
        'O lançamento de {date} foi removido do histórico.',
        params: {'date': formatarData(item.data)},
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            'Lançamento de {date} excluído com sucesso.',
            params: {'date': formatarData(item.data)},
          ),
        ),
      ),
    );
  }

  bool possuiTexto(String value) {
    return value.trim().isNotEmpty;
  }

  bool podeSalvarSomenteKmInicial({
    required double? kmInicial,
    required double? kmFinal,
    required double faturamento,
    required int corridas,
    required String horas,
    required double combustivel,
    required double extras,
  }) {
    return kmInicial != null &&
        kmFinal == null &&
        faturamento == 0 &&
        corridas == 0 &&
        horas.isEmpty &&
        combustivel == 0 &&
        extras == 0;
  }

  String? validarMoedaOpcional(String? value) {
    return FormValidators.validateNonNegativeNumber(
      value,
      translate: AppLocalizations.of(context).text,
    );
  }

  String? validarNumeroOpcional(String? value) {
    return FormValidators.validateNonNegativeNumber(
      value,
      translate: AppLocalizations.of(context).text,
    );
  }

  String? validarInteiroOpcional(String? value) {
    return FormValidators.validateNonNegativeInteger(
      value,
      translate: AppLocalizations.of(context).text,
    );
  }

  String? validarKmFinal(String? value) {
    final tr = AppLocalizations.of(context).text;
    final erroBase = validarNumeroOpcional(value);
    if (erroBase != null) return erroBase;

    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return null;

    final kmInicial = toNullableDouble(kmInicialController.text);
    if (kmInicial == null) {
      return tr('Informe o KM inicial antes do KM final.');
    }

    final kmFinal = toDouble(texto);

    if (kmFinal < kmInicial) {
      return tr('O KM final não pode ser menor que o KM inicial.');
    }

    return null;
  }

  String? validarHoras(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) {
      return null;
    }
    return FormValidators.validateDuration(
      value,
      translate: AppLocalizations.of(context).text,
    );
  }

  String? validarCoerenciaLancamento({
    required double faturamento,
    required bool kmInicialInformado,
    required bool kmFinalInformado,
    required double kmRodado,
    required int corridas,
    required int minutosTrabalhados,
    required double combustivel,
    required double extras,
  }) {
    final tr = AppLocalizations.of(context).text;
    final houveAtividade =
        faturamento > 0 ||
        corridas > 0 ||
        kmRodado > 0 ||
        combustivel > 0 ||
        extras > 0 ||
        minutosTrabalhados > 0;

    if (!houveAtividade) {
      if (kmInicialInformado && !kmFinalInformado) {
        return tr(
          'Preencha o restante do dia ou salve apenas o KM inicial sem informar outros campos.',
        );
      }
      return tr(
        'Informe o KM inicial do dia ou registre uma movimentação válida antes de salvar.',
      );
    }
    if (kmFinalInformado && !kmInicialInformado) {
      return tr('Informe o KM inicial antes de salvar o KM final.');
    }
    if (faturamento > 0 && corridas == 0) {
      return tr('Se houve faturamento no dia, informe ao menos uma corrida.');
    }
    if (corridas > 0 && faturamento == 0) {
      return tr(
        'Corridas registradas precisam ter faturamento correspondente.',
      );
    }
    if (corridas > 0 && kmRodado == 0) {
      return tr('Se houve corridas, o KM rodado precisa ser maior que zero.');
    }
    if (houveAtividade && minutosTrabalhados == 0) {
      return tr(
        'Se houve movimentação no dia, informe um tempo trabalhado maior que 00:00.',
      );
    }
    return null;
  }

  Widget campoTexto({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
    String? prefixText,
    String? helperText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        autovalidateMode: tentouSalvar
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          prefixIcon: Icon(icon),
          prefixText: prefixText,
        ),
      ),
    );
  }

  Widget cardResumo({
    required String titulo,
    required String valor,
    required IconData icone,
    Color? corValor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DriveProfitTheme.tintedCardDecoration(context),
      child: Row(
        children: [
          Icon(icone, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: corValor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget cardHistorico(LancamentoModel item) {
    final tr = AppLocalizations.of(context).text;
    final bool positivo = item.lucro >= 0;
    final bool temDetalheKm = item.kmInicial != null && item.kmFinal != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: DriveProfitTheme.cardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatarData(item.data),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (item.parcial)
            Text(
              tr('Registro parcial salvo com o KM inicial.'),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          if (item.parcial) const SizedBox(height: 8),
          Text(
            tr(
              'Faturamento: {value}',
              params: {'value': formatarMoeda(item.faturamento)},
            ),
          ),
          Text(
            tr(
              'KM rodado: {value} km',
              params: {'value': item.km.toStringAsFixed(1)},
            ),
          ),
          if (temDetalheKm)
            Text(
              tr(
                'Odômetro: {start} até {end}',
                params: {
                  'start': item.kmInicial!.toStringAsFixed(1),
                  'end': item.kmFinal!.toStringAsFixed(1),
                },
              ),
            ),
          Text(
            tr(
              'Corridas: {value}',
              params: {'value': item.corridas.toString()},
            ),
          ),
          Text(
            tr(
              'Horas trabalhadas: {value}',
              params: {'value': item.horas.isEmpty ? '--:--' : item.horas},
            ),
          ),
          Text(
            tr(
              'Combustível: {value}',
              params: {'value': formatarMoeda(item.combustivel)},
            ),
          ),
          Text(
            tr(
              'Extras: {value}',
              params: {'value': formatarMoeda(item.extras)},
            ),
          ),
          Text(
            tr(
              'Custo fixo aplicado: {value}',
              params: {'value': formatarMoeda(item.custoFixoAplicado)},
            ),
          ),
          const SizedBox(height: 6),
          Text(
            positivo
                ? tr(
                    'Lucro: {value}',
                    params: {'value': formatarMoeda(item.lucro)},
                  )
                : tr(
                    'Prejuízo: {value}',
                    params: {'value': formatarMoeda(item.lucro)},
                  ),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: positivo
                  ? context.driveProfitPalette.profit
                  : context.driveProfitPalette.loss,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  preencherFormulario(item);
                  final mensagem = temDetalheKm
                      ? tr(
                          'Você está editando o lançamento de {date}. Salve novamente para aplicar as alterações.',
                          params: {'date': formatarData(item.data)},
                        )
                      : tr(
                          'Você está editando o lançamento de {date}. Revise os campos de KM antes de salvar, porque registros antigos não guardavam o odômetro inicial e final.',
                          params: {'date': formatarData(item.data)},
                        );

                  mostrarFeedback(
                    type: FormFeedbackType.info,
                    title: tr('Modo de edição'),
                    message: mensagem,
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(tr('Editar')),
              ),
              OutlinedButton.icon(
                onPressed: () => confirmarExclusao(item),
                icon: const Icon(Icons.delete_outline),
                label: Text(tr('Excluir')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    faturamentoController.dispose();
    kmInicialController.dispose();
    kmFinalController.dispose();
    corridasController.dispose();
    horasController.dispose();
    combustivelController.dispose();
    extrasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context).text;
    final bool lucroPositivo = lucro >= 0;
    final currency = CurrencyScope.of(context);
    final faturamentoHint = currency.inputExample(400);
    final combustivelHint = currency.inputExample(120.5);
    final extrasHint = currency.inputExample(15);
    final acaoPrincipal = editandoLancamento
        ? tr(
            'Salvar alterações de {date}',
            params: {'date': formatarData(lancamentoEmEdicao!.data)},
          )
        : existeLancamentoHoje
        ? tr('Atualizar lançamento de hoje')
        : tr('Salvar lançamento de hoje');
    final tituloSecaoFormulario = editandoLancamento
        ? tr('Editar lançamento')
        : tr('Resultado do dia');
    final subtituloFormulario = editandoOutroDia
        ? tr(
            'Ajuste um lançamento antigo sem perder a data original do registro.',
          )
        : tr(
            'Preencha os dados do turno para salvar o desempenho do dia com mais contexto.',
          );

    return Scaffold(
      appBar: AppBar(title: Text(tr('Lançamentos')), centerTitle: true),
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
              FormSectionCard(
                title: tituloSecaoFormulario,
                subtitle: subtituloFormulario,
                icon: editandoLancamento
                    ? Icons.edit_calendar_outlined
                    : Icons.today_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (editandoLancamento)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                tr(
                                  'Editando: {date}',
                                  params: {
                                    'date': formatarData(
                                      lancamentoEmEdicao!.data,
                                    ),
                                  },
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  limparFormulario(limparResumo: true),
                              child: Text(tr('Cancelar edição')),
                            ),
                          ],
                        ),
                      ),
                    campoTexto(
                      label: tr('Faturamento bruto do dia'),
                      hint: faturamentoHint,
                      controller: faturamentoController,
                      icon: Icons.attach_money,
                      prefixText: currency.inputPrefix,
                      helperText: tr(
                        'Valor total recebido antes de descontar custos.',
                      ),
                      validator: validarMoedaOpcional,
                    ),
                    campoTexto(
                      label: tr('KM inicial do veículo'),
                      hint: tr('Ex.: 45.000'),
                      controller: kmInicialController,
                      icon: Icons.speed_outlined,
                      helperText: tr(
                        'Você pode salvar só este campo no início do dia e completar o restante depois.',
                      ),
                      validator: validarNumeroOpcional,
                    ),
                    campoTexto(
                      label: tr('KM final do veículo'),
                      hint: tr('Ex.: 45.120'),
                      controller: kmFinalController,
                      icon: Icons.pin_outlined,
                      helperText: tr('Odômetro ao encerrar o dia.'),
                      validator: validarKmFinal,
                    ),
                    campoTexto(
                      label: tr('Quantidade de corridas'),
                      hint: tr('Ex.: 15'),
                      controller: corridasController,
                      icon: Icons.local_taxi_outlined,
                      keyboardType: TextInputType.number,
                      helperText: tr(
                        'Informe o total de viagens concluídas no dia.',
                      ),
                      validator: validarInteiroOpcional,
                    ),
                    campoTexto(
                      label: tr('Tempo trabalhado'),
                      hint: tr('Ex.: 08:30'),
                      controller: horasController,
                      icon: Icons.schedule_outlined,
                      keyboardType: TextInputType.datetime,
                      helperText: tr('Use o formato hh:mm.'),
                      validator: validarHoras,
                    ),
                    campoTexto(
                      label: tr('Combustível gasto no dia'),
                      hint: combustivelHint,
                      controller: combustivelController,
                      icon: Icons.local_gas_station_outlined,
                      prefixText: currency.inputPrefix,
                      helperText: tr('Some os abastecimentos do período.'),
                      validator: validarMoedaOpcional,
                    ),
                    campoTexto(
                      label: tr('Despesas extras do dia'),
                      hint: extrasHint,
                      controller: extrasController,
                      icon: Icons.receipt_long_outlined,
                      prefixText: currency.inputPrefix,
                      helperText: tr(
                        'Inclua pedágio, lavagem ou outras despesas variáveis.',
                      ),
                      validator: (value) {
                        return FormValidators.validateNonNegativeNumber(
                          value,
                          translate: tr,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: calcular,
                        child: Text(
                          acaoPrincipal,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FormSectionCard(
                title: tr('Resumo calculado'),
                subtitle: tr(
                  'Depois de salvar, você vê imediatamente o impacto no lucro do dia.',
                ),
                icon: Icons.analytics_outlined,
                child: Column(
                  children: [
                    cardResumo(
                      titulo: tr('Custo fixo diário base'),
                      valor: formatarMoeda(custoDiario),
                      icone: Icons.account_balance_wallet_outlined,
                    ),
                    cardResumo(
                      titulo: tr('Custo fixo aplicado'),
                      valor: formatarMoeda(custoFixoAplicadoHoje),
                      icone: Icons.request_page_outlined,
                    ),
                    cardResumo(
                      titulo: tr('KM rodado no dia'),
                      valor: '${kmRodado.toStringAsFixed(1)} km',
                      icone: Icons.route_outlined,
                    ),
                    cardResumo(
                      titulo: lucroPositivo
                          ? tr('Lucro do dia')
                          : tr('Prejuízo do dia'),
                      valor: formatarMoeda(lucro),
                      icone: lucroPositivo
                          ? Icons.trending_up
                          : Icons.trending_down,
                      corValor: lucroPositivo
                          ? context.driveProfitPalette.profit
                          : context.driveProfitPalette.loss,
                    ),
                  ],
                ),
              ),
              FormSectionCard(
                title: tr('Histórico de lançamentos'),
                subtitle: tr(
                  'Consulte os dias anteriores, edite registros antigos e exclua o que não fizer mais sentido.',
                ),
                icon: Icons.history_outlined,
                child: historico.isEmpty
                    ? Text(tr('Nenhum lançamento salvo ainda.'))
                    : Column(
                        children: historico
                            .map((item) => cardHistorico(item))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
