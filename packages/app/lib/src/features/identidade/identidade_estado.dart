import 'package:tabloide_core/tabloide_core.dart';

sealed class IdentidadeEstado {
  const IdentidadeEstado();
}

final class IdentidadeCarregando extends IdentidadeEstado {
  const IdentidadeCarregando();
}

final class IdentidadeCarregada extends IdentidadeEstado {
  const IdentidadeCarregada(this.identidade);

  final IdentidadeResponse identidade;
}

final class IdentidadeComFalha extends IdentidadeEstado {
  const IdentidadeComFalha(this.falha);

  final Falha falha;
}
