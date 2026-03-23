import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/custos_fixos_helper.dart';
import '../../../core/theme/drive_profit_theme.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../core/utils/currency_scope.dart';
import '../../../models/lancamento_model.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double custoDiario = 0;
  double totalMensalCustosFixos = 0;
  int diasDoMesAtual = 30;

  double faturamentoHoje = 0;
  double lucroHoje = 0;
  double kmHoje = 0;
  int corridasHoje = 0;
  String horasHoje = '--:--';

  double metaDiaria = 0;
  double metaSemanal = 0;
  double metaMensal = 0;

  double faturamentoSemana = 0;
  double faturamentoMes = 0;
  double despesasMes = 0;
  double lucroMes = 0;

  double combustivelMes = 0;
  double extrasMes = 0;

  double custosFixosCobertosNoMes = 0;
  double custosFixosRestantesNoMes = 0;
  double lucroMedioDiarioNecessario = 0;

  List<LancamentoModel> ultimos7Dias = [];

  @override
  void initState() {
    super.initState();
    carregarDashboard();
  }

  Future<void> carregarDashboard() async {
    final prefs = await AppPreferences.load();

    final agora = DateTime.now();
    final diasDoMes = CustosFixosHelper.obterDiasNoMes(agora);
    final totalCustosFixos = CustosFixosHelper.obterTotalMensalDosPrefs(prefs);
    final dataHoje = DateFormat('yyyy-MM-dd').format(agora);

    final inicioSemana = agora.subtract(Duration(days: agora.weekday - 1));

    final metaDiariaSalva = prefs.getDouble('metaDiaria') ?? 0;
    final metaSemanalSalva = prefs.getDouble('metaSemanal') ?? 0;
    final metaMensalSalva = prefs.getDouble('metaMensal') ?? 0;

    final listaString = prefs.getStringList('lancamentos') ?? [];
    final lista = listaString
        .map((item) => LancamentoModel.fromJson(jsonDecode(item)))
        .toList();

    final lancamentoHojeLista = lista
        .where((item) => item.data == dataHoje)
        .toList();

    double somaSemana = 0;
    double somaMesFaturamento = 0;
    double somaMesCombustivel = 0;
    double somaMesExtras = 0;
    double somaMesLucro = 0;
    double somaMesCustoFixoAplicado = 0;

    for (final item in lista) {
      final dataItem = DateTime.parse(item.data);

      final mesmoMes =
          dataItem.year == agora.year && dataItem.month == agora.month;

      final dentroDaSemana =
          !dataItem.isBefore(
            DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day),
          ) &&
          !dataItem.isAfter(
            DateTime(agora.year, agora.month, agora.day, 23, 59, 59),
          );

      if (mesmoMes) {
        somaMesFaturamento += item.faturamento;
        somaMesCombustivel += item.combustivel;
        somaMesExtras += item.extras;
        somaMesLucro += item.lucro;
        somaMesCustoFixoAplicado += item.custoFixoAplicado;
      }

      if (dentroDaSemana) {
        somaSemana += item.faturamento;
      }
    }

    final custoFixoDiarioCalculado = CustosFixosHelper.obterCustoDiario(
      agora,
      totalCustosFixos,
    );
    final custosCobertosNoMes = somaMesCustoFixoAplicado > totalCustosFixos
        ? totalCustosFixos
        : somaMesCustoFixoAplicado;
    final custosRestantesNoMes = totalCustosFixos - custosCobertosNoMes;
    final lucroDiarioNecessario = CustosFixosHelper.obterCustoDiario(
      agora,
      custosRestantesNoMes,
    );

    final listaOrdenada = [...lista];
    listaOrdenada.sort((a, b) => a.data.compareTo(b.data));

    final hojeSemHora = DateTime(agora.year, agora.month, agora.day);
    final inicio7Dias = hojeSemHora.subtract(const Duration(days: 6));

    final ultimos7 = listaOrdenada.where((item) {
      final data = DateTime.parse(item.data);
      final dataSemHora = DateTime(data.year, data.month, data.day);
      return !dataSemHora.isBefore(inicio7Dias) &&
          !dataSemHora.isAfter(hojeSemHora);
    }).toList();

    setState(() {
      totalMensalCustosFixos = totalCustosFixos;
      custoDiario = custoFixoDiarioCalculado;
      diasDoMesAtual = diasDoMes;

      metaDiaria = metaDiariaSalva;
      metaSemanal = metaSemanalSalva;
      metaMensal = metaMensalSalva;

      faturamentoSemana = somaSemana;
      faturamentoMes = somaMesFaturamento;
      combustivelMes = somaMesCombustivel;
      extrasMes = somaMesExtras;

      despesasMes =
          somaMesCustoFixoAplicado + somaMesCombustivel + somaMesExtras;
      lucroMes = somaMesLucro;

      custosFixosCobertosNoMes = custosCobertosNoMes;
      custosFixosRestantesNoMes = custosRestantesNoMes;
      lucroMedioDiarioNecessario = lucroDiarioNecessario;

      ultimos7Dias = ultimos7;

      if (lancamentoHojeLista.isNotEmpty) {
        final hoje = lancamentoHojeLista.first;
        faturamentoHoje = hoje.faturamento;
        lucroHoje = hoje.lucro;
        kmHoje = hoje.km;
        corridasHoje = hoje.corridas;
        horasHoje = hoje.horas.isEmpty ? '--:--' : hoje.horas;
      } else {
        faturamentoHoje = 0;
        lucroHoje = 0;
        kmHoje = 0;
        corridasHoje = 0;
        horasHoje = '--:--';
      }
    });
  }

  double toDouble(String valor) {
    if (valor.isEmpty) return 0;
    return double.tryParse(valor.replaceAll(',', '.')) ?? 0;
  }

  String formatarMoeda(double valor) {
    return CurrencyScope.of(context).format(valor);
  }

  String abreviarDiaSemana(DateTime data) {
    final locale = AppLocalizations.dateLocaleOf(context);
    final abreviado = DateFormat(
      'EEE',
      locale,
    ).format(data).replaceAll('.', '');
    return capitalizar(abreviado);
  }

  String capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return '${texto[0].toUpperCase()}${texto.substring(1)}';
  }

  String formatarCabecalhoHoje() {
    final locale = AppLocalizations.dateLocaleOf(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final pattern = languageCode == 'en' ? 'EEEE, MMMM d' : "EEEE, d 'de' MMMM";
    return capitalizar(DateFormat(pattern, locale).format(DateTime.now()));
  }

  List<_GraficoDiaItem> gerarSerieUltimos7Dias() {
    final agora = DateTime.now();
    final hojeSemHora = DateTime(agora.year, agora.month, agora.day);
    final mapaPorData = <String, LancamentoModel>{};

    for (final item in ultimos7Dias) {
      mapaPorData[item.data] = item;
    }

    return List.generate(7, (index) {
      final data = hojeSemHora.subtract(Duration(days: 6 - index));
      final chave = DateFormat('yyyy-MM-dd').format(data);
      final lancamento = mapaPorData[chave];

      return _GraficoDiaItem(
        label: abreviarDiaSemana(data),
        valor: lancamento?.lucro ?? 0,
      );
    });
  }

  List<double> gerarEscalaEixoY(double maximo) {
    if (maximo <= 0) {
      return [0, 1, 2, 3];
    }

    return List.generate(4, (index) {
      final fator = (3 - index) / 3;
      return maximo * fator;
    });
  }

  double progressoMeta(double arrecadado, double meta) {
    if (meta <= 0) return 0;
    return arrecadado / meta;
  }

  double valorFaltante(double arrecadado, double meta) {
    final faltante = meta - arrecadado;
    return faltante > 0 ? faltante : 0;
  }

  bool bateuMeta(double arrecadado, double meta) {
    if (meta <= 0) return false;
    return arrecadado >= meta;
  }

  Widget secaoTitulo(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(titulo, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget cardMeta({
    required String titulo,
    required double meta,
    required double arrecadado,
  }) {
    final tr = AppLocalizations.of(context).text;
    final progresso = progressoMeta(arrecadado, meta);
    final faltante = valorFaltante(arrecadado, meta);
    final concluiu = bateuMeta(arrecadado, meta);
    final porcentagem = (progresso * 100).clamp(0, 999).toDouble();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: DriveProfitTheme.tintedCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Text(tr('Meta: {value}', params: {'value': formatarMoeda(meta)})),
          Text(
            tr(
              'Arrecadado: {value}',
              params: {'value': formatarMoeda(arrecadado)},
            ),
          ),
          Text(
            tr('Falta: {value}', params: {'value': formatarMoeda(faltante)}),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progresso > 1 ? 1 : progresso,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              '{value}% da meta',
              params: {'value': porcentagem.toStringAsFixed(1)},
            ),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            concluiu ? tr('Meta batida') : tr('Meta ainda não atingida'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: concluiu
                  ? context.driveProfitPalette.profit
                  : Colors.orange.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget cardDestaqueCustosFixos() {
    final tr = AppLocalizations.of(context).text;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: DriveProfitTheme.tintedCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Custos fixos restantes no mês'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            tr(
              '{covered} de {total} já cobertos',
              params: {
                'covered': formatarMoeda(custosFixosCobertosNoMes),
                'total': formatarMoeda(totalMensalCustosFixos),
              },
            ),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            formatarMoeda(custosFixosRestantesNoMes),
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            tr(
              'Média diária necessária neste mês: {value}',
              params: {'value': formatarMoeda(lucroMedioDiarioNecessario)},
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget cardResumoMensal({
    required String titulo,
    required String valor,
    required IconData icone,
  }) {
    return Expanded(
      child: Container(
        height: 110,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: DriveProfitTheme.cardDecoration(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icone, size: 26),
            const SizedBox(height: 8),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(
              valor,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget graficoUltimos7Dias() {
    final tr = AppLocalizations.of(context).text;

    if (ultimos7Dias.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: DriveProfitTheme.tintedCardDecoration(context),
        child: Text(
          tr('Ainda não há lançamentos suficientes para mostrar o gráfico.'),
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    final serie = gerarSerieUltimos7Dias();

    final maiorValor = serie
        .map((e) => e.valor.abs())
        .fold<double>(
          0,
          (anterior, atual) => atual > anterior ? atual : anterior,
        );

    final maximo = maiorValor == 0 ? 1.0 : maiorValor;
    final escalaY = gerarEscalaEixoY(maximo);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: DriveProfitTheme.tintedCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Lucro dos últimos 7 dias'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 260,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 56,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: escalaY
                        .map(
                          (valor) => Text(
                            formatarMoeda(valor),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: serie.map((item) {
                      final altura = (item.valor.abs() / maximo) * 150;
                      final positivo = item.valor >= 0;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                item.valor.toStringAsFixed(0),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: positivo
                                      ? context.driveProfitPalette.profit
                                      : context.driveProfitPalette.loss,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                height: 170,
                                alignment: Alignment.bottomCenter,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: context.driveProfitPalette.border,
                                    ),
                                    bottom: BorderSide(
                                      color: context.driveProfitPalette.border,
                                    ),
                                  ),
                                ),
                                child: Container(
                                  height: altura < 8 ? 8 : altura,
                                  decoration: BoxDecoration(
                                    color: positivo
                                        ? context.driveProfitPalette.profit
                                        : context.driveProfitPalette.loss,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.label,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context).text;
    final dataHojeFormatada = formatarCabecalhoHoje();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text(
          "DriveProfit",
          style: TextStyle(
            color: DriveProfitTheme.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: carregarDashboard,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              dataHojeFormatada,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Text(tr('Custo fixo diário'), style: TextStyle(fontSize: 16)),
            Text(
              formatarMoeda(custoDiario),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              tr(
                'Baseado em {days} dias no mês atual',
                params: {'days': diasDoMesAtual.toString()},
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                InfoBox(
                  title: tr('Faturamento'),
                  value: formatarMoeda(faturamentoHoje),
                ),
                InfoBox(title: tr('Lucro'), value: formatarMoeda(lucroHoje)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                InfoBox(
                  title: tr('KM rodados'),
                  value: kmHoje.toStringAsFixed(1),
                ),
                InfoBox(title: tr('Horas'), value: horasHoje),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                InfoBox(title: tr('Corridas'), value: corridasHoje.toString()),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 24),
            cardDestaqueCustosFixos(),
            secaoTitulo(tr('Metas')),
            cardMeta(
              titulo: tr('Meta diária'),
              meta: metaDiaria,
              arrecadado: faturamentoHoje,
            ),
            cardMeta(
              titulo: tr('Meta semanal'),
              meta: metaSemanal,
              arrecadado: faturamentoSemana,
            ),
            cardMeta(
              titulo: tr('Meta mensal'),
              meta: metaMensal,
              arrecadado: faturamentoMes,
            ),
            const SizedBox(height: 8),
            secaoTitulo(tr('Resumo mensal')),
            Row(
              children: [
                cardResumoMensal(
                  titulo: tr('Faturamento Mensal'),
                  valor: formatarMoeda(faturamentoMes),
                  icone: Icons.attach_money,
                ),
                cardResumoMensal(
                  titulo: tr('Despesas Mensais'),
                  valor: formatarMoeda(despesasMes),
                  icone: Icons.money_off,
                ),
                cardResumoMensal(
                  titulo: tr('Lucro Mensal'),
                  valor: formatarMoeda(lucroMes),
                  icone: Icons.trending_up,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                cardResumoMensal(
                  titulo: tr('Custo fixo diário'),
                  valor: formatarMoeda(custoDiario),
                  icone: Icons.calendar_view_day_outlined,
                ),
                cardResumoMensal(
                  titulo: tr('Lucro diário médio'),
                  valor: formatarMoeda(lucroMedioDiarioNecessario),
                  icone: Icons.insights_outlined,
                ),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 24),
            secaoTitulo(tr('Últimos 7 dias')),
            graficoUltimos7Dias(),
          ],
        ),
      ),
    );
  }
}

class _GraficoDiaItem {
  final String label;
  final double valor;

  const _GraficoDiaItem({required this.label, required this.valor});
}

class InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const InfoBox({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 95,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: DriveProfitTheme.cardDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
