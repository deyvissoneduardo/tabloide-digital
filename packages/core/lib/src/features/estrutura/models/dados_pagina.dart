import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/responses/identidade_response.dart';
import 'package:tabloide_core/src/responses/panfleto_response.dart';

final class DadosPagina {
  const DadosPagina({
    required this.identidade,
    required this.estrutura,
    this.panfletoVigente,
    this.configuracao = ConfiguracaoPaginaResponse.padrao,
    this.sePanfleto = false,
  });

  final IdentidadeResponse identidade;

  final EstruturaResponse estrutura;

  final PanfletoResponse? panfletoVigente;

  final ConfiguracaoPaginaResponse configuracao;

  final bool sePanfleto;

  bool get exibePanfleto => sePanfleto && panfletoVigente != null;

  DadosPagina copiar({
    EstruturaResponse? estrutura,
    ConfiguracaoPaginaResponse? configuracao,
    bool? sePanfleto,
  }) => DadosPagina(
    identidade: identidade,
    estrutura: estrutura ?? this.estrutura,
    panfletoVigente: panfletoVigente,
    configuracao: configuracao ?? this.configuracao,
    sePanfleto: sePanfleto ?? this.sePanfleto,
  );
}
