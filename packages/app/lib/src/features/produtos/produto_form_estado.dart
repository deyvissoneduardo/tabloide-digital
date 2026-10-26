import 'package:tabloide_core/tabloide_core.dart';

sealed class ProdutoFormEstado {
  const ProdutoFormEstado();
}

final class ProdutoFormOcioso extends ProdutoFormEstado {
  const ProdutoFormOcioso();
}

final class ProdutoFormEnviando extends ProdutoFormEstado {
  const ProdutoFormEnviando();
}

final class ProdutoFormComFalha extends ProdutoFormEstado {
  const ProdutoFormComFalha(this.falha, {this.atualizado});

  final Falha falha;

  final ProdutoResponse? atualizado;
}

final class ProdutoFormConcluido extends ProdutoFormEstado {
  const ProdutoFormConcluido(this.produto);

  final ProdutoResponse produto;
}
