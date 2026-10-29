import 'package:tabloide_core/src/features/pagina/models/cor_pagina.dart';

/// Aparência da página pública do lojista (plano.md §4.2): banner, nome da
/// categoria e as 10 cores (`null` = padrão, resolvido por `AppCoresPagina`).
final class ConfiguracaoPaginaResponse {
  const ConfiguracaoPaginaResponse({
    this.banner = const BannerResponse(),
    this.exibirNomeCategoria = true,
    this.cores = const CoresPaginaResponse(),
  });

  factory ConfiguracaoPaginaResponse.fromJson(Object? json) => switch (json) {
    {
      'banner': final Object banner,
      'exibirNomeCategoria': final bool exibirNomeCategoria,
      'cores': final Object cores,
    } =>
      ConfiguracaoPaginaResponse(
        banner: BannerResponse.fromJson(banner),
        exibirNomeCategoria: exibirNomeCategoria,
        cores: CoresPaginaResponse.fromJson(cores),
      ),
    _ => throw const FormatException(
      'Configuração da página fora do formato esperado',
    ),
  };

  /// Sem nada configurado: banner desligado, nome da categoria visível e
  /// todas as cores no padrão (U14).
  static const padrao = ConfiguracaoPaginaResponse();

  final BannerResponse banner;

  final bool exibirNomeCategoria;

  final CoresPaginaResponse cores;

  ConfiguracaoPaginaResponse copiar({
    BannerResponse? banner,
    bool? exibirNomeCategoria,
    CoresPaginaResponse? cores,
  }) => ConfiguracaoPaginaResponse(
    banner: banner ?? this.banner,
    exibirNomeCategoria: exibirNomeCategoria ?? this.exibirNomeCategoria,
    cores: cores ?? this.cores,
  );

  @override
  bool operator ==(Object other) =>
      other is ConfiguracaoPaginaResponse &&
      other.banner == banner &&
      other.exibirNomeCategoria == exibirNomeCategoria &&
      other.cores == cores;

  @override
  int get hashCode => Object.hash(banner, exibirNomeCategoria, cores);

  @override
  String toString() =>
      'ConfiguracaoPaginaResponse(banner: $banner, '
      'exibirNomeCategoria: $exibirNomeCategoria, cores: $cores)';
}

final class BannerResponse {
  const BannerResponse({
    this.exibir = false,
    this.nome,
    this.urlLogo,
    this.campanha,
  });

  factory BannerResponse.fromJson(Object? json) => switch (json) {
    {
      'exibir': final bool exibir,
      'nome': final String? nome,
      'urlLogo': final String? urlLogo,
      'campanha': final Object? campanha,
    } =>
      BannerResponse(
        exibir: exibir,
        nome: nome,
        urlLogo: urlLogo,
        campanha: campanha == null ? null : CampanhaResponse.fromJson(campanha),
      ),
    _ => throw const FormatException('Banner fora do formato esperado'),
  };

  final bool exibir;

  /// Nome próprio do banner (até 120); ausente = não mostra (U4).
  final String? nome;

  /// Logo próprio do banner; ausente = não mostra (U4).
  final String? urlLogo;

  /// Foto 16:9 ou descrição; `null` = sem campanha (U5).
  final CampanhaResponse? campanha;

  @override
  bool operator ==(Object other) =>
      other is BannerResponse &&
      other.exibir == exibir &&
      other.nome == nome &&
      other.urlLogo == urlLogo &&
      other.campanha == campanha;

  @override
  int get hashCode => Object.hash(exibir, nome, urlLogo, campanha);

  @override
  String toString() =>
      'BannerResponse(exibir: $exibir, nome: $nome, urlLogo: $urlLogo, '
      'campanha: $campanha)';
}

sealed class CampanhaResponse {
  const CampanhaResponse();

  factory CampanhaResponse.fromJson(Object? json) => switch (json) {
    {'tipo': 'FOTO', 'urlFoto': final String urlFoto} => CampanhaFoto(urlFoto),
    {'tipo': 'DESCRICAO', 'descricao': final String descricao} =>
      CampanhaDescricao(descricao),
    _ => throw const FormatException('Campanha fora do formato esperado'),
  };
}

final class CampanhaFoto extends CampanhaResponse {
  const CampanhaFoto(this.urlFoto);

  final String urlFoto;

  @override
  bool operator ==(Object other) =>
      other is CampanhaFoto && other.urlFoto == urlFoto;

  @override
  int get hashCode => Object.hash(CampanhaFoto, urlFoto);

  @override
  String toString() => 'CampanhaFoto($urlFoto)';
}

final class CampanhaDescricao extends CampanhaResponse {
  const CampanhaDescricao(this.descricao);

  final String descricao;

  @override
  bool operator ==(Object other) =>
      other is CampanhaDescricao && other.descricao == descricao;

  @override
  int get hashCode => Object.hash(CampanhaDescricao, descricao);

  @override
  String toString() => 'CampanhaDescricao($descricao)';
}

/// As 10 cores em `#RRGGBB` ou `null` (= padrão, plano.md §4.4).
final class CoresPaginaResponse {
  const CoresPaginaResponse({
    this.primaria,
    this.secundaria,
    this.texto,
    this.textoSuave,
    this.fundoCartao,
    this.fundoPagina,
    this.neutra,
    this.sobreCor,
    this.fundoBanner,
    this.categoria,
  });

  factory CoresPaginaResponse.fromJson(Object? json) => switch (json) {
    {
      'primaria': final String? primaria,
      'secundaria': final String? secundaria,
      'texto': final String? texto,
      'textoSuave': final String? textoSuave,
      'fundoCartao': final String? fundoCartao,
      'fundoPagina': final String? fundoPagina,
      'neutra': final String? neutra,
      'sobreCor': final String? sobreCor,
      'fundoBanner': final String? fundoBanner,
      'categoria': final String? categoria,
    } =>
      CoresPaginaResponse(
        primaria: primaria,
        secundaria: secundaria,
        texto: texto,
        textoSuave: textoSuave,
        fundoCartao: fundoCartao,
        fundoPagina: fundoPagina,
        neutra: neutra,
        sobreCor: sobreCor,
        fundoBanner: fundoBanner,
        categoria: categoria,
      ),
    _ => throw const FormatException(
      'Cores da página fora do formato esperado',
    ),
  };

  final String? primaria;

  final String? secundaria;

  final String? texto;

  final String? textoSuave;

  final String? fundoCartao;

  final String? fundoPagina;

  final String? neutra;

  final String? sobreCor;

  final String? fundoBanner;

  final String? categoria;

  String? operator [](CorPagina cor) => switch (cor) {
    CorPagina.primaria => primaria,
    CorPagina.secundaria => secundaria,
    CorPagina.texto => texto,
    CorPagina.textoSuave => textoSuave,
    CorPagina.fundoCartao => fundoCartao,
    CorPagina.fundoPagina => fundoPagina,
    CorPagina.neutra => neutra,
    CorPagina.sobreCor => sobreCor,
    CorPagina.fundoBanner => fundoBanner,
    CorPagina.categoria => categoria,
  };

  /// Cópia com [cor] trocada por [valor] (`null` = padrão).
  CoresPaginaResponse com(CorPagina cor, String? valor) {
    String? v(CorPagina c) => c == cor ? valor : this[c];
    return CoresPaginaResponse(
      primaria: v(CorPagina.primaria),
      secundaria: v(CorPagina.secundaria),
      texto: v(CorPagina.texto),
      textoSuave: v(CorPagina.textoSuave),
      fundoCartao: v(CorPagina.fundoCartao),
      fundoPagina: v(CorPagina.fundoPagina),
      neutra: v(CorPagina.neutra),
      sobreCor: v(CorPagina.sobreCor),
      fundoBanner: v(CorPagina.fundoBanner),
      categoria: v(CorPagina.categoria),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CoresPaginaResponse &&
      CorPagina.values.every((c) => other[c] == this[c]);

  @override
  int get hashCode =>
      Object.hashAll([for (final c in CorPagina.values) this[c]]);

  @override
  String toString() =>
      'CoresPaginaResponse(${[for (final c in CorPagina.values) '${c.name}: ${this[c]}'].join(', ')})';
}
