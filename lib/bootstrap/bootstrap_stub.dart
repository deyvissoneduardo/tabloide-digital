import 'package:flutter/widgets.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Plataforma sem `dart:io` nem `dart:js_interop`.
Widget bootstrap({required BrandConfig marca, required String baseUrl}) =>
    throw UnsupportedError('Plataforma não suportada pelo painel.');
