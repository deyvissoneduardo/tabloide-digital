import 'package:tabloide_core/tabloide_core.dart';

sealed class FiliaisEstado {
  const FiliaisEstado();
}

final class FiliaisCarregando extends FiliaisEstado {
  const FiliaisCarregando();
}

final class FiliaisCarregadas extends FiliaisEstado {
  const FiliaisCarregadas(this.filiais);

  final List<FilialResponse> filiais;
}

final class FiliaisComFalha extends FiliaisEstado {
  const FiliaisComFalha(this.falha);

  final Falha falha;
}
