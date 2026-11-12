import 'package:tabloide_core/src/features/vigencia/models/data_dia.dart';

final class ResumoAcessosResponse {
  const ResumoAcessosResponse({
    required this.inicio,
    required this.fim,
    required this.total,
    required this.porFilial,
    required this.porDia,
    required this.iniciosPanfleto,
    required this.pico,
  });

  factory ResumoAcessosResponse.fromJson(Object? json) => switch (json) {
    {
      'intervalo': {'inicio': final String inicio, 'fim': final String fim},
      'total': final int total,
      'porFilial': final List<dynamic> porFilial,
      'porDia': final List<dynamic> porDia,
      'iniciosPanfleto': final List<dynamic> iniciosPanfleto,
      'pico': final Object pico,
    } =>
      ResumoAcessosResponse(
        inicio: DataDia.ler(inicio),
        fim: DataDia.ler(fim),
        total: total,
        porFilial: List.unmodifiable(
          porFilial.map(AcessosFilialResponse.fromJson),
        ),
        porDia: List.unmodifiable(porDia.map(AcessosDiaResponse.fromJson)),
        iniciosPanfleto: List.unmodifiable(
          iniciosPanfleto.map(InicioPanfletoResponse.fromJson),
        ),
        pico: PicoAcessosResponse.fromJson(pico),
      ),
    _ => throw const FormatException('Resumo de acessos fora do formato'),
  };

  final DateTime inicio;

  final DateTime fim;

  final int total;

  final List<AcessosFilialResponse> porFilial;

  final List<AcessosDiaResponse> porDia;

  final List<InicioPanfletoResponse> iniciosPanfleto;

  final PicoAcessosResponse pico;
}

final class AcessosFilialResponse {
  const AcessosFilialResponse({
    required this.filialId,
    required this.nome,
    required this.excluida,
    required this.total,
  });

  factory AcessosFilialResponse.fromJson(Object? json) => switch (json) {
    {
      'filialId': final String filialId,
      'nome': final String nome,
      'excluida': final bool excluida,
      'total': final int total,
    } =>
      AcessosFilialResponse(
        filialId: filialId,
        nome: nome,
        excluida: excluida,
        total: total,
      ),
    _ => throw const FormatException('Acessos da filial fora do formato'),
  };

  final String filialId;

  final String nome;

  final bool excluida;

  final int total;
}

final class AcessosDiaResponse {
  const AcessosDiaResponse({required this.data, required this.total});

  factory AcessosDiaResponse.fromJson(Object? json) => switch (json) {
    {'data': final String data, 'total': final int total} => AcessosDiaResponse(
      data: DataDia.ler(data),
      total: total,
    ),
    _ => throw const FormatException('Acessos do dia fora do formato'),
  };

  final DateTime data;

  final int total;
}

final class InicioPanfletoResponse {
  const InicioPanfletoResponse({required this.data, required this.filialId});

  factory InicioPanfletoResponse.fromJson(Object? json) => switch (json) {
    {'data': final String data, 'filialId': final String filialId} =>
      InicioPanfletoResponse(data: DataDia.ler(data), filialId: filialId),
    _ => throw const FormatException('Início de panfleto fora do formato'),
  };

  final DateTime data;

  final String filialId;
}

final class PicoAcessosResponse {
  const PicoAcessosResponse({
    required this.disponivel,
    required this.minimo,
    this.porHora,
    this.porDiaSemana,
  });

  factory PicoAcessosResponse.fromJson(Object? json) => switch (json) {
    {
      'disponivel': final bool disponivel,
      'minimo': final int minimo,
      'porHora': final List<dynamic>? porHora,
      'porDiaSemana': final List<dynamic>? porDiaSemana,
    } =>
      PicoAcessosResponse(
        disponivel: disponivel,
        minimo: minimo,
        porHora: porHora == null ? null : _inteiros(porHora, 24),
        porDiaSemana: porDiaSemana == null ? null : _inteiros(porDiaSemana, 7),
      ),
    _ => throw const FormatException('Pico de acessos fora do formato'),
  };

  final bool disponivel;

  final int minimo;

  final List<int>? porHora;

  final List<int>? porDiaSemana;
}

List<int> _inteiros(List<dynamic> valores, int tamanho) {
  if (valores.length != tamanho) {
    throw FormatException('Esperava $tamanho posições', valores);
  }
  return List.unmodifiable([
    for (final valor in valores)
      if (valor is int)
        valor
      else
        throw FormatException('Valor não inteiro', valor),
  ]);
}
