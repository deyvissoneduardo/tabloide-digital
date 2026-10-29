import 'package:tabloide_core/src/features/pagina/models/cor_pagina.dart';
import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';

String? _descricao(CampanhaResponse? campanha) => switch (campanha) {
  CampanhaDescricao(:final descricao) => descricao,
  _ => null,
};

/// `PATCH /painel/lojista/pagina` (plano.md §4.3): só as chaves que mudaram
/// entre o salvo e o em edição. Logo e foto do banner vão pelas rotas de
/// upload; aqui só entra a descrição (texto = campanha DESCRICAO; `null`
/// apaga a descrição).
final class ConfiguracaoPaginaRequest {
  const ConfiguracaoPaginaRequest._(this._campos);

  factory ConfiguracaoPaginaRequest.entre(
    ConfiguracaoPaginaResponse salvo,
    ConfiguracaoPaginaResponse novo,
  ) {
    final antes = salvo.banner;
    final depois = novo.banner;
    final descricaoAntes = _descricao(antes.campanha);
    final descricaoDepois = _descricao(depois.campanha);
    final banner = <String, Object?>{
      if (antes.exibir != depois.exibir) 'exibir': depois.exibir,
      if (antes.nome != depois.nome) 'nome': depois.nome,
      if (descricaoAntes != descricaoDepois) 'descricao': descricaoDepois,
    };
    final cores = <String, Object?>{
      for (final cor in CorPagina.values)
        if (salvo.cores[cor] != novo.cores[cor]) cor.name: novo.cores[cor],
    };
    return ConfiguracaoPaginaRequest._({
      if (banner.isNotEmpty) 'banner': banner,
      if (salvo.exibirNomeCategoria != novo.exibirNomeCategoria)
        'exibirNomeCategoria': novo.exibirNomeCategoria,
      if (cores.isNotEmpty) 'cores': cores,
    });
  }

  final Map<String, Object?> _campos;

  bool get vazio => _campos.isEmpty;

  Map<String, Object?> toJson() => {
    for (final MapEntry(:key, :value) in _campos.entries)
      key: value is Map<String, Object?> ? {...value} : value,
  };

  @override
  bool operator ==(Object other) =>
      other is ConfiguracaoPaginaRequest && other.toString() == toString();

  @override
  int get hashCode => toString().hashCode;

  @override
  String toString() => 'ConfiguracaoPaginaRequest($_campos)';
}
