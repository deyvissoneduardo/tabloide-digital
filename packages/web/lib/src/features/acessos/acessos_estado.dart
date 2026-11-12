import 'package:tabloide_core/tabloide_core.dart';

sealed class ResumoAcessosEstado {
  const ResumoAcessosEstado();
}

final class ResumoAcessosCarregando extends ResumoAcessosEstado {
  const ResumoAcessosCarregando();
}

final class ResumoAcessosCarregado extends ResumoAcessosEstado {
  const ResumoAcessosCarregado(this.resumo, this.periodo);

  final ResumoAcessosResponse resumo;

  final PeriodoAcessos periodo;
}

final class ResumoAcessosComFalha extends ResumoAcessosEstado {
  const ResumoAcessosComFalha(this.falha);

  final Falha falha;
}

sealed class PanfletosAcessosEstado {
  const PanfletosAcessosEstado();
}

final class PanfletosAcessosOcioso extends PanfletosAcessosEstado {
  const PanfletosAcessosOcioso();
}

final class PanfletosAcessosCarregando extends PanfletosAcessosEstado {
  const PanfletosAcessosCarregando();
}

final class PanfletosAcessosCarregados extends PanfletosAcessosEstado {
  const PanfletosAcessosCarregados(this.itens);

  final List<AcessosPanfletoResponse> itens;
}

final class PanfletosAcessosComFalha extends PanfletosAcessosEstado {
  const PanfletosAcessosComFalha(this.falha);

  final Falha falha;
}
