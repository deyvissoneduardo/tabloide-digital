import 'dart:typed_data';

import 'package:tabloide_core/tabloide_core.dart';

final _espacos = RegExp(r'\s+');

String? _textoOuNulo(String texto) {
  final limpo = texto.trim();
  return limpo.isEmpty ? null : limpo;
}

/// Imagem escolhida para o banner e ainda não enviada (T6).
final class ImagemPendente {
  const ImagemPendente({required this.bytes, required this.nomeArquivo});

  final Uint8List bytes;

  final String nomeArquivo;
}

/// Aparência da página em edição (aba "Aparência"): o que a prévia mostra e o
/// que "Publicar" envia (T6, T7). Imutável; cada `com*` devolve uma cópia.
final class EdicaoAparencia {
  const EdicaoAparencia({
    required this.exibirBanner,
    required this.tipoCampanha,
    required this.exibirNomeCategoria,
    required this.cores,
    this.nomeBanner,
    this.urlLogo,
    this.logo,
    this.urlFoto,
    this.foto,
    this.descricao,
  });

  factory EdicaoAparencia.de(ConfiguracaoPaginaResponse salva) {
    final banner = salva.banner;
    return EdicaoAparencia(
      exibirBanner: banner.exibir,
      nomeBanner: banner.nome,
      urlLogo: banner.urlLogo,
      tipoCampanha: switch (banner.campanha) {
        CampanhaFoto() => TipoCampanha.foto,
        CampanhaDescricao() => TipoCampanha.descricao,
        null => TipoCampanha.nenhuma,
      },
      urlFoto: switch (banner.campanha) {
        CampanhaFoto(:final urlFoto) => urlFoto,
        _ => null,
      },
      descricao: switch (banner.campanha) {
        CampanhaDescricao(:final descricao) => descricao,
        _ => null,
      },
      exibirNomeCategoria: salva.exibirNomeCategoria,
      cores: salva.cores,
    );
  }

  final bool exibirBanner;

  final String? nomeBanner;

  /// Logo do banner já salvo (`null` = sem logo ou removido).
  final String? urlLogo;

  /// Logo escolhido e ainda não enviado.
  final ImagemPendente? logo;

  final TipoCampanha tipoCampanha;

  /// Foto da campanha já salva (`null` = sem foto ou removida).
  final String? urlFoto;

  /// Foto escolhida e ainda não enviada.
  final ImagemPendente? foto;

  /// Descrição digitada; mantida ao trocar de tipo.
  final String? descricao;

  final bool exibirNomeCategoria;

  final CoresPaginaResponse cores;

  /// Configuração para a prévia e para o `PATCH`: campanha só com o que o
  /// tipo escolhido tem de fato.
  ConfiguracaoPaginaResponse get configuracao => ConfiguracaoPaginaResponse(
    banner: BannerResponse(
      exibir: exibirBanner,
      nome: nomeBanner,
      urlLogo: urlLogo,
      campanha: switch ((tipoCampanha, urlFoto, descricao)) {
        (TipoCampanha.foto, final url?, _) => CampanhaFoto(url),
        (TipoCampanha.descricao, _, final texto?) => CampanhaDescricao(texto),
        _ => null,
      },
    ),
    exibirNomeCategoria: exibirNomeCategoria,
    cores: cores,
  );

  /// Foto pendente que a prévia deve mostrar (só com o tipo Foto).
  Uint8List? get bytesFoto =>
      tipoCampanha == TipoCampanha.foto ? foto?.bytes : null;

  Uint8List? get bytesLogo => logo?.bytes;

  bool get enviaLogo => logo != null;

  bool removeLogo(ConfiguracaoPaginaResponse salva) =>
      logo == null && urlLogo == null && salva.banner.urlLogo != null;

  bool get enviaFoto => tipoCampanha == TipoCampanha.foto && foto != null;

  /// A foto salva sai quando a campanha fica sem nada. Trocar para descrição
  /// já substitui a foto pelo `PATCH` (plano.md §4.3).
  bool removeFoto(ConfiguracaoPaginaResponse salva) =>
      salva.banner.campanha is CampanhaFoto &&
      !enviaFoto &&
      configuracao.banner.campanha == null;

  ConfiguracaoPaginaRequest pedido(ConfiguracaoPaginaResponse salva) =>
      ConfiguracaoPaginaRequest.entre(salva, configuracao);

  bool mudouDesde(ConfiguracaoPaginaResponse salva) =>
      enviaLogo ||
      removeLogo(salva) ||
      enviaFoto ||
      removeFoto(salva) ||
      !pedido(salva).vazio;

  EdicaoAparencia _copiar({
    bool? exibirBanner,
    String? Function()? nomeBanner,
    String? Function()? urlLogo,
    ImagemPendente? Function()? logo,
    TipoCampanha? tipoCampanha,
    String? Function()? urlFoto,
    ImagemPendente? Function()? foto,
    String? Function()? descricao,
    bool? exibirNomeCategoria,
    CoresPaginaResponse? cores,
  }) => EdicaoAparencia(
    exibirBanner: exibirBanner ?? this.exibirBanner,
    nomeBanner: nomeBanner == null ? this.nomeBanner : nomeBanner(),
    urlLogo: urlLogo == null ? this.urlLogo : urlLogo(),
    logo: logo == null ? this.logo : logo(),
    tipoCampanha: tipoCampanha ?? this.tipoCampanha,
    urlFoto: urlFoto == null ? this.urlFoto : urlFoto(),
    foto: foto == null ? this.foto : foto(),
    descricao: descricao == null ? this.descricao : descricao(),
    exibirNomeCategoria: exibirNomeCategoria ?? this.exibirNomeCategoria,
    cores: cores ?? this.cores,
  );

  EdicaoAparencia comExibirBanner(bool exibir) => _copiar(exibirBanner: exibir);

  /// Espaços normalizados como na API; vazio = sem nome.
  EdicaoAparencia comNomeBanner(String nome) =>
      _copiar(nomeBanner: () => _textoOuNulo(nome.replaceAll(_espacos, ' ')));

  EdicaoAparencia comLogo(ImagemPendente logo) => _copiar(logo: () => logo);

  EdicaoAparencia semLogo() => _copiar(logo: () => null, urlLogo: () => null);

  /// Sair de Foto descarta a foto escolhida e ainda não enviada.
  EdicaoAparencia comTipoCampanha(TipoCampanha tipo) => _copiar(
    tipoCampanha: tipo,
    foto: tipo == TipoCampanha.foto ? null : () => null,
  );

  EdicaoAparencia comFoto(ImagemPendente foto) =>
      _copiar(tipoCampanha: TipoCampanha.foto, foto: () => foto);

  EdicaoAparencia semFoto() => _copiar(foto: () => null, urlFoto: () => null);

  EdicaoAparencia comDescricao(String descricao) =>
      _copiar(descricao: () => _textoOuNulo(descricao));

  EdicaoAparencia comExibirNomeCategoria(bool exibir) =>
      _copiar(exibirNomeCategoria: exibir);

  /// [hex] `#RRGGBB` (maiúsculo) ou `null` = padrão.
  EdicaoAparencia comCor(CorPagina cor, String? hex) =>
      _copiar(cores: cores.com(cor, hex?.toUpperCase()));

  /// Depois do envio do logo: a URL nova vira a salva.
  EdicaoAparencia comLogoEnviado(String? url) =>
      _copiar(logo: () => null, urlLogo: () => url);

  /// Depois do envio da foto: a URL nova vira a salva.
  EdicaoAparencia comFotoEnviada(String? url) =>
      _copiar(foto: () => null, urlFoto: () => url);
}
