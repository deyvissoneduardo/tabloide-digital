import 'package:flutter/widgets.dart';

enum ClasseTamanho {
  compacto,

  medio,

  expandido;

  static ClasseTamanho daLargura(double largura) => largura < AppLayout.medio
      ? compacto
      : largura < AppLayout.expandido
      ? medio
      : expandido;

  static ClasseTamanho de(BuildContext context) =>
      daLargura(MediaQuery.sizeOf(context).width);
}

abstract final class AppLayout {
  static const medio = 600.0;

  static const expandido = 840.0;

  static const larguraMaximaConteudo = 1200.0;

  static const larguraMaximaFormulario = 600.0;

  static const larguraMenuLateral = 220.0;

  static const alvoMinimo = 48.0;

  static const alturaPreviaImagem = 320.0;

  /// Largura máxima da prévia da página (simula um celular).
  static const larguraPrevia = 420.0;

  /// Bloco branco do logo no cabeçalho da prévia.
  static const ladoLogoPrevia = 64.0;

  /// Cartão de produto no carrossel da prévia.
  static const larguraCartaoProdutoPrevia = 156.0;

  /// Colunas da grade única da prévia (sem nome da categoria, U10).
  static const colunasGradePrevia = 2;

  /// Proporção da foto da campanha do banner (U6).
  static const proporcaoFotoBanner = 16 / 9;

  /// Cartão de produto no editor da página.
  static const larguraCartaoProdutoEditor = 140.0;

  /// Altura da faixa horizontal de produtos no editor.
  static const alturaCarrosselEditor = 168.0;

  /// Lado do QR Code no card da filial.
  static const ladoQrCode = 160.0;
}
