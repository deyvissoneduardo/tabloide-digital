import 'package:tabloide_core/tabloide_core.dart';

sealed class PanfletosEstado {
  const PanfletosEstado();
}

final class PanfletosCarregando extends PanfletosEstado {
  const PanfletosCarregando();
}

final class PanfletosCarregados extends PanfletosEstado {
  const PanfletosCarregados(this.panfletos);

  final List<PanfletoResponse> panfletos;
}

final class PanfletosComFalha extends PanfletosEstado {
  const PanfletosComFalha(this.falha);

  final Falha falha;
}
