import 'package:flutter/widgets.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Marca padrão: a do próprio produto.
final class TabloideBrand implements BrandConfig {
  const TabloideBrand();

  @override
  String get nome => 'Tabloide Digital';

  @override
  Color get corPrimaria => const Color(0xFF1565C0);

  @override
  Color get corSecundaria => const Color(0xFFFFB300);

  @override
  ImageProvider get logo =>
      const AssetImage('assets/tabloide/logo.png', package: 'tabloide_brands');

  @override
  String get cnpj => '11444777000161'; // fictício até ter o real
}
