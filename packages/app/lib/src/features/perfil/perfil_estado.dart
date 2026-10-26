import 'package:tabloide_core/tabloide_core.dart';

sealed class PerfilEstado {
  const PerfilEstado();
}

final class PerfilCarregando extends PerfilEstado {
  const PerfilCarregando();
}

final class PerfilCarregado extends PerfilEstado {
  const PerfilCarregado({required this.lojista, required this.identidade});

  final LojistaResponse lojista;

  final IdentidadeResponse identidade;
}

final class PerfilComFalha extends PerfilEstado {
  const PerfilComFalha(this.falha);

  final Falha falha;
}
