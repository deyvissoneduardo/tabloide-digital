import 'package:flutter/widgets.dart';

/// Identidade de um cliente white-label.
///
/// Cada cliente implementa esta interface no pacote `tabloide_brands` e se
/// registra no `BrandRegistry`.
abstract interface class BrandConfig {
  /// Nome exibido no painel e no título da janela/aba.
  String get nome;

  /// Cor base do tema; o esquema de cores é derivado dela.
  Color get corPrimaria;

  /// Cor de destaque do tema.
  Color get corSecundaria;

  /// `AssetImage` no pacote brands; `ImageProvider` deixa trocar por imagem
  /// de rede no futuro sem mudar a interface.
  ImageProvider get logo;

  /// Só dígitos/letras, sem máscara (14 caracteres).
  String get cnpj;
}
