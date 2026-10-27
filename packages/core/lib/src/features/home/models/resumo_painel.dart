import 'package:flutter/foundation.dart';
import 'package:tabloide_core/src/features/home/models/resumo_filial.dart';

final class ResumoPainel {
  const ResumoPainel({
    required this.panfletosVigentes,
    required this.produtosVigentes,
    this.porFilial = const [],
  });

  final int panfletosVigentes;

  final int produtosVigentes;

  /// Contagens de cada filial, na ordem pedida.
  final List<ResumoFilial> porFilial;

  ResumoFilial? daFilial(String filialId) =>
      porFilial.where((r) => r.filialId == filialId).firstOrNull;

  @override
  bool operator ==(Object other) =>
      other is ResumoPainel &&
      other.panfletosVigentes == panfletosVigentes &&
      other.produtosVigentes == produtosVigentes &&
      listEquals(other.porFilial, porFilial);

  @override
  int get hashCode => Object.hash(
    panfletosVigentes,
    produtosVigentes,
    Object.hashAll(porFilial),
  );

  @override
  String toString() =>
      'ResumoPainel(panfletos: $panfletosVigentes, produtos: $produtosVigentes)';
}
