import 'package:tabloide_brands/src/mercado_exemplo/mercado_exemplo_brand.dart';
import 'package:tabloide_brands/src/tabloide/tabloide_brand.dart';
import 'package:tabloide_core/tabloide_core.dart';

const marcaPadrao = 'tabloide';

void registrarMarcas(BrandRegistry registry) {
  registry
    ..registrar(marcaPadrao, const TabloideBrand())
    ..registrar('mercado_exemplo', const MercadoExemploBrand());
}
