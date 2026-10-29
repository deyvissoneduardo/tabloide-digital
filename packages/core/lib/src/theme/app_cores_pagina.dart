import 'package:flutter/painting.dart';
import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';

final _hex = RegExp(r'^#[0-9A-F]{6}$');

/// As 10 cores da página do lojista (prévia), resolvidas como na API e na
/// página pública React (plano.md §4.4): cor escolhida usada **exatamente**
/// (U13, sem ajuste de contraste); ausente ou fora do formato `#RRGGBB`
/// maiúsculo = padrão; `fundoBanner` e `categoria` seguem a primária já
/// resolvida.
final class AppCoresPagina {
  const AppCoresPagina({
    required this.primaria,
    required this.secundaria,
    required this.texto,
    required this.textoSuave,
    required this.fundoCartao,
    required this.fundoPagina,
    required this.neutra,
    required this.sobreCor,
    required this.fundoBanner,
    required this.categoria,
  });

  factory AppCoresPagina.de([
    CoresPaginaResponse cores = const CoresPaginaResponse(),
  ]) {
    final primaria = _ou(cores.primaria, padraoPrimaria);
    return AppCoresPagina(
      primaria: primaria,
      secundaria: _ou(cores.secundaria, padraoSecundaria),
      texto: _ou(cores.texto, padraoTexto),
      textoSuave: _ou(cores.textoSuave, padraoTextoSuave),
      fundoCartao: _ou(cores.fundoCartao, padraoFundoCartao),
      fundoPagina: _ou(cores.fundoPagina, padraoFundoPagina),
      neutra: _ou(cores.neutra, padraoNeutra),
      sobreCor: _ou(cores.sobreCor, padraoSobreCor),
      fundoBanner: _ou(cores.fundoBanner, primaria),
      categoria: _ou(cores.categoria, primaria),
    );
  }

  /// Padrões = visual de hoje (U14, plano.md §4.4).
  static const padraoPrimaria = Color(0xFF1565C0);

  static const padraoSecundaria = Color(0xFF996B00);

  static const padraoTexto = Color(0xFF1F1F1F);

  static const padraoTextoSuave = Color(0xFF5C5C5C);

  static const padraoFundoCartao = Color(0xFFFFFFFF);

  static const padraoFundoPagina = Color(0xFFF3F4F6);

  static const padraoNeutra = Color(0xFFEEEEEE);

  static const padraoSobreCor = Color(0xFFFFFFFF);

  /// Sombra dos cartões de produto.
  static const sombraCartao = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  /// Sombra do panfleto.
  static const sombraPanfleto = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 6), blurRadius: 20),
  ];

  /// Sombra do bloco do logo no cabeçalho e no banner.
  static const sombraLogo = [
    BoxShadow(color: Color(0x2E000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  /// Brilho no canto superior direito do cabeçalho e do banner (branco 12% →
  /// 0%, fixo).
  static const brilhoCabecalho = RadialGradient(
    center: Alignment.topRight,
    radius: 1.1,
    colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
  );

  /// Fundo do cabeçalho; iniciais do logo; nome e preço do produto; botões.
  final Color primaria;

  /// Barra da categoria; selo "-N%"; descrição e observação; "Válido até" do
  /// panfleto.
  final Color secundaria;

  /// "Nenhuma oferta no momento."; chip "válido até dd/mm" do produto.
  final Color texto;

  /// Contador "N ofertas"; quantidade; "de R$ X"; ícone de produto sem foto.
  final Color textoSuave;

  /// Cartão do produto; caixa "Nenhuma oferta"; área e pílula do panfleto.
  final Color fundoCartao;

  /// Fundo da página.
  final Color fundoPagina;

  /// Fundo do "sem foto" e do chip "válido até dd/mm" do produto.
  final Color neutra;

  /// Textos e ícones do cabeçalho e do banner; caixa do logo; texto do selo e
  /// dos botões.
  final Color sobreCor;

  /// Fundo do banner.
  final Color fundoBanner;

  /// Nome da categoria.
  final Color categoria;

  /// `#RRGGBB` maiúsculo da cor (canais de 0 a 255).
  static String paraHex(Color cor) =>
      '#${[cor.r, cor.g, cor.b].map((c) => (c * 255).round().toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';

  static Color _ou(String? hex, Color padrao) =>
      hex != null && _hex.hasMatch(hex)
      ? Color(0xFF000000 | int.parse(hex.substring(1), radix: 16))
      : padrao;

  @override
  bool operator ==(Object other) =>
      other is AppCoresPagina &&
      other.primaria == primaria &&
      other.secundaria == secundaria &&
      other.texto == texto &&
      other.textoSuave == textoSuave &&
      other.fundoCartao == fundoCartao &&
      other.fundoPagina == fundoPagina &&
      other.neutra == neutra &&
      other.sobreCor == sobreCor &&
      other.fundoBanner == fundoBanner &&
      other.categoria == categoria;

  @override
  int get hashCode => Object.hash(
    primaria,
    secundaria,
    texto,
    textoSuave,
    fundoCartao,
    fundoPagina,
    neutra,
    sobreCor,
    fundoBanner,
    categoria,
  );
}
