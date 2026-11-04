import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';
import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/responses/identidade_response.dart';
import 'package:tabloide_core/src/responses/panfleto_response.dart';

/// Tudo o que a seção Página precisa da filial em uso.
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

  /// Aparência salva da página (por lojista, plano.md §4.2).
  final ConfiguracaoPaginaResponse configuracao;

  /// RN44: a chave da filial em uso (não a da identidade do lojista).
  final bool sePanfleto;

  /// plano.md §4.8.
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
