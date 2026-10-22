import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_app/tabloide_app.dart';

/// Monta o painel mobile com a injeção do core e a do app.
Widget bootstrap({required BrandConfig marca, required String baseUrl}) =>
    MultiProvider(
      providers: providersCore(
        marca: marca,
        baseUrl: baseUrl,
        servicos: providersApp(),
      ),
      child: const PainelApp(),
    );
