import 'dart:typed_data';

import 'package:tabloide_core/tabloide_core.dart';

final _espacos = RegExp(r'\s+');

String? _textoOuNulo(String texto) {
  final limpo = texto.trim();
  return limpo.isEmpty ? null : limpo;
}

final class ImagemPendente {
  const ImagemPendente({required this.bytes, required this.nomeArquivo});

  final Uint8List bytes;

  final String nomeArquivo;
}

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

  final String? urlLogo;

  final ImagemPendente? logo;

  final TipoCampanha tipoCampanha;

  final String? urlFoto;

  final ImagemPendente? foto;

  final String? descricao;

  final bool exibirNomeCategoria;

  final CoresPaginaResponse cores;

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

  Uint8List? get bytesFoto =>
      tipoCampanha == TipoCampanha.foto ? foto?.bytes : null;

  Uint8List? get bytesLogo => logo?.bytes;

  bool get enviaLogo => logo != null;

  bool removeLogo(ConfiguracaoPaginaResponse salva) =>
      logo == null && urlLogo == null && salva.banner.urlLogo != null;

  bool get enviaFoto => tipoCampanha == TipoCampanha.foto && foto != null;

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

  EdicaoAparencia comNomeBanner(String nome) =>
      _copiar(nomeBanner: () => _textoOuNulo(nome.replaceAll(_espacos, ' ')));

  EdicaoAparencia comLogo(ImagemPendente logo) => _copiar(logo: () => logo);

  EdicaoAparencia semLogo() => _copiar(logo: () => null, urlLogo: () => null);

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

  EdicaoAparencia comCor(CorPagina cor, String? hex) =>
      _copiar(cores: cores.com(cor, hex?.toUpperCase()));

  EdicaoAparencia comLogoEnviado(String? url) =>
      _copiar(logo: () => null, urlLogo: () => url);

  EdicaoAparencia comFotoEnviada(String? url) =>
      _copiar(foto: () => null, urlFoto: () => url);
}
