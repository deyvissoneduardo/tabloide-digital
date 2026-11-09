import 'package:flutter/painting.dart';
import 'package:tabloide_core/src/responses/configuracao_pagina_response.dart';

final _hex = RegExp(r'^#[0-9A-F]{6}$');

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

  static const padraoPrimaria = Color(0xFF1565C0);

  static const padraoSecundaria = Color(0xFF996B00);

  static const padraoTexto = Color(0xFF1F1F1F);

  static const padraoTextoSuave = Color(0xFF5C5C5C);

  static const padraoFundoCartao = Color(0xFFFFFFFF);

  static const padraoFundoPagina = Color(0xFFF3F4F6);

  static const padraoNeutra = Color(0xFFEEEEEE);

  static const padraoSobreCor = Color(0xFFFFFFFF);

  static const sombraCartao = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  static const sombraPanfleto = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 6), blurRadius: 20),
  ];

  static const sombraLogo = [
    BoxShadow(color: Color(0x2E000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  static const brilhoCabecalho = RadialGradient(
    center: Alignment.topRight,
    radius: 1.1,
    colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
  );

  final Color primaria;

  final Color secundaria;

  final Color texto;

  final Color textoSuave;

  final Color fundoCartao;

  final Color fundoPagina;

  final Color neutra;

  final Color sobreCor;

  final Color fundoBanner;

  final Color categoria;

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
