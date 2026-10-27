import 'package:tabloide_core/src/responses/estrutura_response.dart';
import 'package:tabloide_core/src/responses/identidade_response.dart';
import 'package:tabloide_core/src/responses/panfleto_response.dart';

/// Tudo o que a seção Página precisa da filial em uso.
final class DadosPagina {
  const DadosPagina({
    required this.identidade,
    required this.estrutura,
    this.panfletoVigente,
  });

  final IdentidadeResponse identidade;

  final EstruturaResponse estrutura;

  final PanfletoResponse? panfletoVigente;

  /// plano.md §4.8.
  bool get exibePanfleto => identidade.sePanfleto && panfletoVigente != null;
}
