import 'package:tabloide_core/tabloide_core.dart';

sealed class ProdutosEstado {
  const ProdutosEstado();
}

final class ProdutosCarregando extends ProdutosEstado {
  const ProdutosCarregando();
}

final class ProdutosCarregados extends ProdutosEstado {
  const ProdutosCarregados(this.produtos);

  final List<ProdutoResponse> produtos;
}

final class ProdutosComFalha extends ProdutosEstado {
  const ProdutosComFalha(this.falha);

  final Falha falha;
}
