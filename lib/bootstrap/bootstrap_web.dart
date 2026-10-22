import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:tabloide_web/tabloide_web.dart';

/// Monta o painel web com a injeção do core e a da web.
Widget bootstrap({required BrandConfig marca, required String baseUrl}) {
  usePathUrlStrategy();
  return MultiProvider(
    providers: providersCore(
      marca: marca,
      baseUrl: baseUrl,
      servicos: providersWeb(),
    ),
    child: const PainelWeb(),
  );
}
