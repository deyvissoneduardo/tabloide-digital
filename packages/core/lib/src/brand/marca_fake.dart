import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tabloide_core/src/brand/brand_config.dart';

/// Marca de teste com valores padrão válidos.
///
/// A logo padrão é [LogoIniciais]: sem arquivo, o `MarcaLogo` mostra as
/// iniciais, que aparecem nos goldens.
final class MarcaFake implements BrandConfig {
  /// Cria a marca de teste; todo campo pode ser sobrescrito.
  const MarcaFake({
    this.nome = 'Marca Teste',
    this.corPrimaria = const Color(0xFF1565C0),
    this.corSecundaria = const Color(0xFFFFB300),
    this.cnpj = '11222333000181',
    this.logo = const LogoIniciais(),
  });

  @override
  final String nome;

  @override
  final Color corPrimaria;

  @override
  final Color corSecundaria;

  @override
  final String cnpj;

  @override
  final ImageProvider logo;
}

/// Logo que nunca carrega, para o `MarcaLogo` cair nas iniciais do nome.
class LogoIniciais extends ImageProvider<LogoIniciais> {
  /// Cria a logo sem imagem.
  const LogoIniciais();

  @override
  Future<LogoIniciais> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    LogoIniciais key,
    ImageDecoderCallback decode,
  ) => OneFrameImageStreamCompleter(
    Future.error(StateError('MarcaFake não tem imagem de logo')),
  );
}
