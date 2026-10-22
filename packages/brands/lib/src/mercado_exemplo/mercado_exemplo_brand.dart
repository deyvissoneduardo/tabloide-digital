import 'package:flutter/widgets.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Cliente de exemplo, para estudo do white-label.
final class MercadoExemploBrand implements BrandConfig {
  const MercadoExemploBrand();

  @override
  String get nome => 'Mercado Exemplo';

  @override
  Color get corPrimaria => const Color(0xFFC62828);

  @override
  Color get corSecundaria => const Color(0xFFFFD600);

  @override
  ImageProvider get logo => const AssetImage(
    'assets/mercado_exemplo/logo.png',
    package: 'tabloide_brands',
  );

  @override
  String get cnpj => '11222333000181'; // fictício
}
