import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tabloide_core/src/brand/brand_config.dart';

final class MarcaFake implements BrandConfig {
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

class LogoIniciais extends ImageProvider<LogoIniciais> {
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
