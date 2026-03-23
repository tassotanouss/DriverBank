import 'app_preferences.dart';
import 'form_validators.dart';

class CustosFixosHelper {
  static double obterTotalMensal({
    required double parcela,
    required double seguro,
    required double ipva,
    required double manutencao,
    required double outros,
  }) {
    return parcela + seguro + ipva + manutencao + outros;
  }

  static double obterTotalMensalDosPrefs(AppPreferences prefs) {
    final parcela =
        FormValidators.parseDecimal(prefs.getString('parcela') ?? '') ?? 0;
    final seguro =
        FormValidators.parseDecimal(prefs.getString('seguro') ?? '') ?? 0;
    final ipva =
        FormValidators.parseDecimal(prefs.getString('ipva') ?? '') ?? 0;
    final manutencao =
        FormValidators.parseDecimal(prefs.getString('manutencao') ?? '') ?? 0;
    final outros =
        FormValidators.parseDecimal(prefs.getString('outros') ?? '') ?? 0;

    return obterTotalMensal(
      parcela: parcela,
      seguro: seguro,
      ipva: ipva,
      manutencao: manutencao,
      outros: outros,
    );
  }

  static int obterDiasNoMes(DateTime data) {
    return DateTime(data.year, data.month + 1, 0).day;
  }

  static double obterCustoDiario(DateTime data, double totalMensal) {
    final diasNoMes = obterDiasNoMes(data);
    if (diasNoMes <= 0) return 0;
    return totalMensal / diasNoMes;
  }

  static double obterCustoAcumuladoNoPeriodo({
    required DateTime inicio,
    required DateTime fim,
    required double totalMensal,
  }) {
    final inicioSemHora = DateTime(inicio.year, inicio.month, inicio.day);
    final fimSemHora = DateTime(fim.year, fim.month, fim.day);

    if (fimSemHora.isBefore(inicioSemHora)) {
      return 0;
    }

    double total = 0;
    var cursor = inicioSemHora;

    while (!cursor.isAfter(fimSemHora)) {
      total += obterCustoDiario(cursor, totalMensal);
      cursor = cursor.add(const Duration(days: 1));
    }

    return total;
  }
}
