import 'package:tabloide_core/tabloide_core.dart';

sealed class CategoriasEstado {
  const CategoriasEstado();
}

final class CategoriasCarregando extends CategoriasEstado {
  const CategoriasCarregando();
}

final class CategoriasCarregadas extends CategoriasEstado {
  const CategoriasCarregadas(this.categorias);

  final List<CategoriaResponse> categorias;
}

final class CategoriasComFalha extends CategoriasEstado {
  const CategoriasComFalha(this.falha);

  final Falha falha;
}
