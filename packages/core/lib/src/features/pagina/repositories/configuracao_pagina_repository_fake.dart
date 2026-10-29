import 'package:tabloide_core/src/either/either.dart';
import 'package:tabloide_core/src/either/falha.dart';
import 'package:tabloide_core/src/features/pagina/models/cor_pagina.dart';
import 'package:tabloide_core/src/features/pagina/repositories/configuracao_pagina_repository.dart';
import 'package:tabloide_core/src/requests/configuracao_pagina_request.dart';
import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';

/// Exemplo do plano.md §4.2: banner ligado com nome, logo e foto.
const configuracaoPaginaFake = ConfiguracaoPaginaResponse(
  banner: BannerResponse(
    exibir: true,
    nome: 'Semana do Hortifrúti',
    urlLogo: 'https://midia.fake/logo/banner.webp',
    campanha: CampanhaFoto('https://midia.fake/banner/foto.webp'),
  ),
  exibirNomeCategoria: false,
  cores: CoresPaginaResponse(primaria: '#C8102E', fundoBanner: '#0B3D91'),
);

/// Simula a API em memória, aplicando as regras do plano.md §4.3.
final class ConfiguracaoPaginaRepositoryFake
    implements ConfiguracaoPaginaRepository {
  ConfiguracaoPaginaRepositoryFake({
    this.configuracao = ConfiguracaoPaginaResponse.padrao,
    this.falha,
    this.falhaAoEditar,
    this.falhaAoEnviar,
    this.atraso = Duration.zero,
  });

  ConfiguracaoPaginaResponse configuracao;

  /// Falha de todas as chamadas.
  Falha? falha;

  /// Falha só do PATCH.
  Falha? falhaAoEditar;

  /// Falha só dos uploads e remoções do banner.
  Falha? falhaAoEnviar;

  Duration atraso;

  var obtidas = 0;

  final pedidos = <ConfiguracaoPaginaRequest>[];

  /// Ordem das chamadas de escrita: `PATCH`, `PUT logo`, `DELETE logo`,
  /// `PUT foto` e `DELETE foto`.
  final chamadas = <String>[];

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> obter() {
    obtidas++;
    return _responder(null, () => configuracao);
  }

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> editar(
    ConfiguracaoPaginaRequest request,
  ) {
    chamadas.add('PATCH');
    pedidos.add(request);
    return _responder(falhaAoEditar, () => configuracao = _aplicar(request));
  }

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> enviarLogoBanner({
    required List<int> bytes,
    required String nomeArquivo,
  }) {
    chamadas.add('PUT logo');
    return _responder(
      falhaAoEnviar,
      () => configuracao = _comBanner(
        urlLogo: 'https://midia.fake/logo/$nomeArquivo',
      ),
    );
  }

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> removerLogoBanner() {
    chamadas.add('DELETE logo');
    return _responder(
      falhaAoEnviar,
      () => configuracao = _comBanner(semLogo: true),
    );
  }

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> enviarFotoBanner({
    required List<int> bytes,
    required String nomeArquivo,
  }) {
    chamadas.add('PUT foto');
    return _responder(
      falhaAoEnviar,
      () => configuracao = _comBanner(
        campanha: CampanhaFoto('https://midia.fake/banner/$nomeArquivo'),
      ),
    );
  }

  @override
  Future<Either<Falha, ConfiguracaoPaginaResponse>> removerFotoBanner() {
    chamadas.add('DELETE foto');
    return _responder(
      falhaAoEnviar,
      () => configuracao = configuracao.banner.campanha is CampanhaFoto
          ? _comBanner(semCampanha: true)
          : configuracao,
    );
  }

  ConfiguracaoPaginaResponse _comBanner({
    String? urlLogo,
    bool semLogo = false,
    CampanhaResponse? campanha,
    bool semCampanha = false,
  }) {
    final banner = configuracao.banner;
    return configuracao.copiar(
      banner: BannerResponse(
        exibir: banner.exibir,
        nome: banner.nome,
        urlLogo: semLogo ? null : urlLogo ?? banner.urlLogo,
        campanha: semCampanha ? null : campanha ?? banner.campanha,
      ),
    );
  }

  ConfiguracaoPaginaResponse _aplicar(ConfiguracaoPaginaRequest request) {
    final json = request.toJson();
    var nova = configuracao;
    if (json['banner'] case final Map<String, Object?> banner) {
      final descricao = banner['descricao'];
      final atual = nova.banner;
      nova = nova.copiar(
        banner: BannerResponse(
          exibir: banner['exibir'] as bool? ?? atual.exibir,
          nome: banner.containsKey('nome')
              ? banner['nome'] as String?
              : atual.nome,
          urlLogo: atual.urlLogo,
          campanha: switch (descricao) {
            _ when !banner.containsKey('descricao') => atual.campanha,
            final String texto => CampanhaDescricao(texto),
            _ => atual.campanha is CampanhaDescricao ? null : atual.campanha,
          },
        ),
      );
    }
    if (json['exibirNomeCategoria'] case final bool exibir) {
      nova = nova.copiar(exibirNomeCategoria: exibir);
    }
    if (json['cores'] case final Map<String, Object?> cores) {
      var resultado = nova.cores;
      for (final cor in CorPagina.values) {
        if (cores.containsKey(cor.name)) {
          resultado = resultado.com(
            cor,
            (cores[cor.name] as String?)?.toUpperCase(),
          );
        }
      }
      nova = nova.copiar(cores: resultado);
    }
    return nova;
  }

  Future<Either<Falha, T>> _responder<T>(
    Falha? falhaDaChamada,
    T Function() acao,
  ) async {
    await Future<void>.delayed(atraso);
    return switch (falhaDaChamada ?? falha) {
      final falha? => Failure(falha),
      null => Success(acao()),
    };
  }
}
