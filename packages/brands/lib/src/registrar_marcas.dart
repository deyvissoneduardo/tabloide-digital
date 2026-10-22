import 'package:tabloide_brands/src/mercado_exemplo/mercado_exemplo_brand.dart';
import 'package:tabloide_brands/src/tabloide/tabloide_brand.dart';
import 'package:tabloide_core/tabloide_core.dart';

/// Id da marca usada quando o build não informa `MARCA`.
const marcaPadrao = 'tabloide';

/// Registra todos os clientes white-label em [registry].
void registrarMarcas(BrandRegistry registry) {
  registry
    ..registrar(marcaPadrao, const TabloideBrand())
    ..registrar('mercado_exemplo', const MercadoExemploBrand());
}
