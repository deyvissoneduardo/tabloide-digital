import 'package:tabloide_core/tabloide_core.dart';

sealed class CategoriaFormEstado {
  const CategoriaFormEstado();
}

final class CategoriaFormOcioso extends CategoriaFormEstado {
  const CategoriaFormOcioso();
}

final class CategoriaFormEnviando extends CategoriaFormEstado {
  const CategoriaFormEnviando();
}

final class CategoriaFormComFalha extends CategoriaFormEstado {
  const CategoriaFormComFalha(this.falha);

  final Falha falha;
}

final class CategoriaFormConcluido extends CategoriaFormEstado {
  const CategoriaFormConcluido(this.categoria);

  final CategoriaResponse categoria;
}
