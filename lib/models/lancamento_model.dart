class LancamentoModel {
  final String data;
  final double faturamento;
  final double km;
  final double? kmInicial;
  final double? kmFinal;
  final double combustivel;
  final double extras;
  final double lucro;
  final int corridas;
  final String horas;
  final double custoFixoAplicado;
  final bool parcial;

  LancamentoModel({
    required this.data,
    required this.faturamento,
    required this.km,
    this.kmInicial,
    this.kmFinal,
    required this.combustivel,
    required this.extras,
    required this.lucro,
    required this.corridas,
    required this.horas,
    required this.custoFixoAplicado,
    this.parcial = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'faturamento': faturamento,
      'km': km,
      'kmInicial': kmInicial,
      'kmFinal': kmFinal,
      'combustivel': combustivel,
      'extras': extras,
      'lucro': lucro,
      'corridas': corridas,
      'horas': horas,
      'custoFixoAplicado': custoFixoAplicado,
      'parcial': parcial,
    };
  }

  factory LancamentoModel.fromJson(Map<String, dynamic> json) {
    return LancamentoModel(
      data: json['data'],
      faturamento: (json['faturamento'] ?? 0).toDouble(),
      km: (json['km'] ?? 0).toDouble(),
      kmInicial: json['kmInicial'] != null
          ? (json['kmInicial'] as num).toDouble()
          : null,
      kmFinal: json['kmFinal'] != null
          ? (json['kmFinal'] as num).toDouble()
          : null,
      combustivel: (json['combustivel'] ?? 0).toDouble(),
      extras: (json['extras'] ?? 0).toDouble(),
      lucro: (json['lucro'] ?? 0).toDouble(),
      corridas: json['corridas'] ?? 0,
      horas: json['horas'] ?? '',
      custoFixoAplicado: (json['custoFixoAplicado'] ?? 0).toDouble(),
      parcial: json['parcial'] ?? false,
    );
  }
}
