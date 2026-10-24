import 'package:flutter/widgets.dart';

abstract interface class BrandConfig {
  String get nome;

  Color get corPrimaria;

  Color get corSecundaria;

  ImageProvider get logo;

  String get cnpj;
}
