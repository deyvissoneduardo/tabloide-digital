import 'package:flutter/painting.dart';
import 'package:tabloide_core/src/theme/app_cores.dart';
import 'package:tabloide_core/src/theme/app_theme.dart';

final _hex = RegExp(r'^#[0-9A-F]{6}$');

const _branco = Color(0xFFFFFFFF);

/// Cores de texto da página do lojista (prévia), iguais às da página pública
/// React (plano §4.7). O contraste é sempre calculado contra `#FFFFFF`.
final class AppCoresPagina {
  const AppCoresPagina._(this.primaria, this.secundaria);

  factory AppCoresPagina.de({String? corPrimaria, String? corSecundaria}) =>
      AppCoresPagina._(
        corDeTexto(corPrimaria, AppCores.primaria),
        corDeTexto(corSecundaria, AppCores.secundaria),
      );

  /// Texto sobre a primária/secundária (cabeçalho e selo de desconto): o
  /// contraste ≥ 4,5 com branco já é garantido por [corDeTexto].
  static const sobreCor = _branco;

  /// Fundo da página, atrás dos cartões brancos.
  static const fundo = Color(0xFFF3F4F6);

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

  /// Sombra do bloco do logo no cabeçalho.
  static const sombraLogo = [
    BoxShadow(color: Color(0x2E000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  /// Brilho no canto superior direito do cabeçalho.
  static const brilhoCabecalho = RadialGradient(
    center: Alignment.topRight,
    radius: 1.1,
    colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
  );

  /// Nome do produto, preço e nome da categoria.
  final Color primaria;

  /// Quantidade, descrição, observação, "de R$ X" e "válido até dd/mm".
  final Color secundaria;

  /// `hex` em `#RRGGBB` maiúsculo (senão vale `padrao`), escurecida pelo L do
  /// HSL até ter contraste ≥ 4,5 com branco.
  static Color corDeTexto(String? hex, Color padrao) {
    var cor = hex != null && _hex.hasMatch(hex) ? _deHex(hex) : padrao;
    if (_legivel(cor)) return cor;
    final (h, s, l) = _paraHsl(cor);
    var luz = (l * 100).round();
    do {
      luz -= 1;
      cor = _deHsl(h, s, luz / 100);
    } while (!_legivel(cor) && luz > 0);
    return cor;
  }

  /// `#RRGGBB` maiúsculo da cor (canais de 0 a 255).
  static String paraHex(Color cor) =>
      '#${[cor.r, cor.g, cor.b].map((c) => _canal(c).toRadixString(16).padLeft(2, '0')).join().toUpperCase()}';

  static bool _legivel(Color cor) =>
      AppTheme.contraste(cor, _branco) >= AppTheme.contrasteMinimo;

  static int _canal(double valor) => (valor * 255).round();

  static Color _deHex(String hex) =>
      Color(0xFF000000 | int.parse(hex.substring(1), radix: 16));

  static Color _deRgb(int r, int g, int b) =>
      Color(0xFF000000 | (r << 16) | (g << 8) | b);

  static (double, double, double) _paraHsl(Color cor) {
    final r = _canal(cor.r) / 255;
    final g = _canal(cor.g) / 255;
    final b = _canal(cor.b) / 255;
    final maximo = [r, g, b].reduce((a, b) => a > b ? a : b);
    final minimo = [r, g, b].reduce((a, b) => a < b ? a : b);
    final l = (maximo + minimo) / 2;
    if (maximo == minimo) return (0, 0, l);
    final d = maximo - minimo;
    final s = l > 0.5 ? d / (2 - maximo - minimo) : d / (maximo + minimo);
    final double h;
    if (maximo == r) {
      h = (g - b) / d + (g < b ? 6 : 0);
    } else if (maximo == g) {
      h = (b - r) / d + 2;
    } else {
      h = (r - g) / d + 4;
    }
    return (h / 6, s, l);
  }

  static Color _deHsl(double h, double s, double l) {
    if (s == 0) {
      final c = (l * 255).round();
      return _deRgb(c, c, c);
    }
    final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    final p = 2 * l - q;
    return _deRgb(
      (_matiz(p, q, h + 1 / 3) * 255).round(),
      (_matiz(p, q, h) * 255).round(),
      (_matiz(p, q, h - 1 / 3) * 255).round(),
    );
  }

  static double _matiz(double p, double q, double t) {
    var x = t;
    if (x < 0) x += 1;
    if (x > 1) x -= 1;
    if (x < 1 / 6) return p + (q - p) * 6 * x;
    if (x < 1 / 2) return q;
    if (x < 2 / 3) return p + (q - p) * (2 / 3 - x) * 6;
    return p;
  }
}
