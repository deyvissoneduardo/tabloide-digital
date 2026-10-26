import 'package:tabloide_core/tabloide_core.dart';

sealed class PanfletoFormEstado {
  const PanfletoFormEstado();
}

final class PanfletoFormOcioso extends PanfletoFormEstado {
  const PanfletoFormOcioso();
}

final class PanfletoFormEnviando extends PanfletoFormEstado {
  const PanfletoFormEnviando();
}

final class PanfletoFormComFalha extends PanfletoFormEstado {
  const PanfletoFormComFalha(this.falha, {this.atualizado});

  final Falha falha;

  final PanfletoResponse? atualizado;
}

final class PanfletoFormConcluido extends PanfletoFormEstado {
  const PanfletoFormConcluido(this.panfleto);

  final PanfletoResponse panfleto;
}
