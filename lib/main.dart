import 'package:flutter/widgets.dart';
import 'package:tabloide_brands/tabloide_brands.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_front/bootstrap/bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  const marcaId = String.fromEnvironment('MARCA', defaultValue: marcaPadrao);
  const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/v1',
  );

  runApp(bootstrap(marca: resolverMarca(marcaId), baseUrl: baseUrl));
}

BrandConfig resolverMarca(String id) {
  final registry = BrandRegistry();
  registrarMarcas(registry);
  return registry.resolver(id);
}
