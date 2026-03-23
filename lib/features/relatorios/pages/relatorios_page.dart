import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/drive_profit_theme.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../core/utils/currency_scope.dart';
import '../../../models/lancamento_model.dart';

class RelatoriosPage extends StatefulWidget {
  const RelatoriosPage({super.key});

  @override
  State<RelatoriosPage> createState() => _RelatoriosPageState();
}

class _RelatoriosPageState extends State<RelatoriosPage> {
  String filtroSelecionado = 'dia';

  DateTime dataSelecionada = DateTime.now();
  DateTime mesSelecionado = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime semanaSelecionada = DateTime.now();

  List<LancamentoModel> todosLancamentos = [];
  List<LancamentoModel> lancamentosFiltrados = [];

  double faturamento = 0;
  double despesasTotais = 0;
  double lucroLiquido = 0;
  double mediaPorDia = 0;
  double kmRodados = 0;
  double combustivel = 0;
  double porHora = 0;
  int diasTrabalhados = 0;
  String horasTotalFormatada = '00:00';

  @override
  void initState() {
    super.initState();
    carregarRelatorio();
  }

  double toDouble(String valor) {
    if (valor.isEmpty) return 0;
    return double.tryParse(valor.replaceAll(',', '.')) ?? 0;
  }

  String formatarMoeda(double valor) {
    return CurrencyScope.of(context).format(valor);
  }

  String formatarData(DateTime data) {
    final locale = AppLocalizations.dateLocaleOf(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final pattern = languageCode == 'en' ? 'MM/dd/yyyy' : 'dd/MM/yyyy';
    return DateFormat(pattern, locale).format(data);
  }

  String formatarMesAno(DateTime data) {
    final locale = AppLocalizations.dateLocaleOf(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final pattern = languageCode == 'en' ? 'MMMM yyyy' : "MMMM 'de' yyyy";
    return DateFormat(pattern, locale).format(data);
  }

  String formatarDataCurta(DateTime data) {
    final locale = AppLocalizations.dateLocaleOf(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final pattern = languageCode == 'en' ? 'MM/dd' : 'dd/MM';
    return DateFormat(pattern, locale).format(data);
  }

  String formatarHoras(double horasDecimais) {
    final totalMinutos = (horasDecimais * 60).round();
    final horas = totalMinutos ~/ 60;
    final minutos = totalMinutos % 60;
    return '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}';
  }

  double converterHoraTextoParaDecimal(String valor) {
    if (valor.trim().isEmpty) return 0;

    if (valor.contains(':')) {
      final partes = valor.split(':');
      if (partes.length == 2) {
        final horas = int.tryParse(partes[0]) ?? 0;
        final minutos = int.tryParse(partes[1]) ?? 0;
        return horas + (minutos / 60);
      }
    }

    return double.tryParse(valor.replaceAll(',', '.')) ?? 0;
  }

  Future<void> carregarRelatorio() async {
    final prefs = await AppPreferences.load();

    final listaString = prefs.getStringList('lancamentos') ?? [];
    final lista = listaString
        .map((item) => LancamentoModel.fromJson(jsonDecode(item)))
        .toList();

    lista.sort((a, b) => a.data.compareTo(b.data));

    todosLancamentos = lista;

    aplicarFiltro();
  }

  void aplicarFiltro() {
    List<LancamentoModel> filtrados = [];

    if (filtroSelecionado == 'dia') {
      filtrados = todosLancamentos.where((item) {
        final data = DateTime.parse(item.data);
        return data.year == dataSelecionada.year &&
            data.month == dataSelecionada.month &&
            data.day == dataSelecionada.day;
      }).toList();
    }

    if (filtroSelecionado == 'semana') {
      final inicioSemana = semanaSelecionada.subtract(
        Duration(days: semanaSelecionada.weekday - 1),
      );
      final fimSemana = inicioSemana.add(const Duration(days: 6));

      filtrados = todosLancamentos.where((item) {
        final data = DateTime.parse(item.data);
        final dataLimpa = DateTime(data.year, data.month, data.day);
        return !dataLimpa.isBefore(
              DateTime(inicioSemana.year, inicioSemana.month, inicioSemana.day),
            ) &&
            !dataLimpa.isAfter(
              DateTime(fimSemana.year, fimSemana.month, fimSemana.day),
            );
      }).toList();
    }

    if (filtroSelecionado == 'mes') {
      filtrados = todosLancamentos.where((item) {
        final data = DateTime.parse(item.data);
        return data.year == mesSelecionado.year &&
            data.month == mesSelecionado.month;
      }).toList();
    }

    double somaFaturamento = 0;
    double somaDespesas = 0;
    double somaLucro = 0;
    double somaKm = 0;
    double somaCombustivel = 0;
    double somaHoras = 0;

    for (final item in filtrados) {
      somaFaturamento += item.faturamento;
      somaDespesas += item.custoFixoAplicado + item.combustivel + item.extras;
      somaLucro += item.lucro;
      somaKm += item.km;
      somaCombustivel += item.combustivel;
      somaHoras += converterHoraTextoParaDecimal(item.horas);
    }

    final int dias = filtrados.length;
    final double media = dias > 0 ? somaFaturamento / dias : 0.0;
    final double ganhoPorHora = somaHoras > 0 ? somaLucro / somaHoras : 0.0;

    setState(() {
      lancamentosFiltrados = filtrados;
      faturamento = somaFaturamento;
      despesasTotais = somaDespesas;
      lucroLiquido = somaLucro;
      mediaPorDia = media;
      kmRodados = somaKm;
      combustivel = somaCombustivel;
      porHora = ganhoPorHora;
      diasTrabalhados = dias;
      horasTotalFormatada = formatarHoras(somaHoras);
    });
  }

  Widget botaoFiltro(String valor, String texto) {
    final selecionado = filtroSelecionado == valor;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            filtroSelecionado = valor;
          });
          aplicarFiltro();
        },
        child: Container(
          height: 46,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selecionado
                ? Theme.of(context).colorScheme.primary
                : context.driveProfitPalette.cardTint,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.driveProfitPalette.border),
          ),
          child: Center(
            child: Text(
              texto,
              style: TextStyle(
                color: selecionado
                    ? Colors.white
                    : context.driveProfitPalette.title,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget cardIndicador(String titulo, String valor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: DriveProfitTheme.tintedCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(
            valor,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget seletorPeriodo() {
    final tr = AppLocalizations.of(context).text;

    if (filtroSelecionado == 'dia') {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ElevatedButton(
          onPressed: () async {
            final data = await showDatePicker(
              context: context,
              initialDate: dataSelecionada,
              firstDate: DateTime(2025),
              lastDate: DateTime(2100),
            );

            if (data != null) {
              setState(() {
                dataSelecionada = data;
              });
              aplicarFiltro();
            }
          },
          child: Text(
            tr(
              'Selecionar dia: {date}',
              params: {'date': formatarData(dataSelecionada)},
            ),
          ),
        ),
      );
    }

    if (filtroSelecionado == 'semana') {
      final inicioSemana = semanaSelecionada.subtract(
        Duration(days: semanaSelecionada.weekday - 1),
      );
      final fimSemana = inicioSemana.add(const Duration(days: 6));

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: ElevatedButton(
          onPressed: () async {
            final data = await showDatePicker(
              context: context,
              initialDate: semanaSelecionada,
              firstDate: DateTime(2025),
              lastDate: DateTime(2100),
            );

            if (data != null) {
              setState(() {
                semanaSelecionada = data;
              });
              aplicarFiltro();
            }
          },
          child: Text(
            tr(
              'Semana: {start} até {end}',
              params: {
                'start': formatarData(inicioSemana),
                'end': formatarData(fimSemana),
              },
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton(
        onPressed: () async {
          final data = await showDatePicker(
            context: context,
            initialDate: mesSelecionado,
            firstDate: DateTime(2025),
            lastDate: DateTime(2100),
            initialDatePickerMode: DatePickerMode.year,
          );

          if (data != null) {
            setState(() {
              mesSelecionado = DateTime(data.year, data.month);
            });
            aplicarFiltro();
          }
        },
        child: Text(
          tr(
            'Selecionar mês: {month}',
            params: {'month': formatarMesAno(mesSelecionado)},
          ),
        ),
      ),
    );
  }

  Widget graficoLucroAcumulado() {
    final tr = AppLocalizations.of(context).text;

    if (lancamentosFiltrados.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: DriveProfitTheme.tintedCardDecoration(context),
        child: Text(tr('Ainda não há dados suficientes para o gráfico.')),
      );
    }

    final listaOrdenada = [...lancamentosFiltrados];
    listaOrdenada.sort((a, b) => a.data.compareTo(b.data));

    double acumulado = 0;
    final acumulados = <double>[];

    for (final item in listaOrdenada) {
      acumulado += item.lucro;
      acumulados.add(acumulado);
    }

    final maiorValor = acumulados
        .map((e) => e.abs())
        .fold<double>(
          0,
          (anterior, atual) => atual > anterior ? atual : anterior,
        );

    final maximo = maiorValor == 0 ? 1.0 : maiorValor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: DriveProfitTheme.tintedCardDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr('Lucro acumulado'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(listaOrdenada.length, (index) {
                final valor = acumulados[index];
                final altura = (valor.abs() / maximo) * 140;
                final positivo = valor >= 0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formatarMoeda(valor),
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
                          height: altura < 8 ? 8 : altura,
                          decoration: BoxDecoration(
                            color: positivo
                                ? context.driveProfitPalette.profit
                                : context.driveProfitPalette.loss,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatarDataCurta(
                            DateTime.parse(listaOrdenada[index].data),
                          ),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context).text;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Relatórios')), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: carregarRelatorio,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              tr('Acompanhe seu desempenho'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                botaoFiltro('dia', tr('DIA')),
                botaoFiltro('semana', tr('SEMANA')),
                botaoFiltro('mes', tr('MÊS')),
              ],
            ),
            const SizedBox(height: 16),
            seletorPeriodo(),
            cardIndicador(tr('FATURAMENTO'), formatarMoeda(faturamento)),
            cardIndicador(tr('DESPESAS TOTAIS'), formatarMoeda(despesasTotais)),
            cardIndicador(tr('LUCRO LÍQUIDO'), formatarMoeda(lucroLiquido)),
            cardIndicador(tr('MÉDIA/DIA'), formatarMoeda(mediaPorDia)),
            cardIndicador(
              tr('KM rodados'),
              '${kmRodados.toStringAsFixed(1)} km',
            ),
            cardIndicador(tr('HORAS'), horasTotalFormatada),
            cardIndicador(tr('COMBUSTÍVEL'), formatarMoeda(combustivel)),
            cardIndicador(tr('POR HORA'), formatarMoeda(porHora)),
            cardIndicador(tr('DIAS TRABALHADOS'), diasTrabalhados.toString()),
            const SizedBox(height: 18),
            graficoLucroAcumulado(),
          ],
        ),
      ),
    );
  }
}
