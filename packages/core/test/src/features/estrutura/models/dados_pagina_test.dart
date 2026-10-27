import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

IdentidadeResponse _identidade({required bool sePanfleto}) =>
    IdentidadeResponse(
      nomeFantasia: identidadeFake.nomeFantasia,
      sePanfleto: sePanfleto,
    );

void main() {
  group('Funcionalidade: regra de exibição da página (plano §4.8, RN44)', () {
    for (final (sePanfleto, vigente, exibePanfleto) in [
      (true, true, true),
      (true, false, false),
      (false, true, false),
      (false, false, false),
    ]) {
      test(
        'Cenário: Dado sePanfleto $sePanfleto e panfleto vigente $vigente, então exibePanfleto é $exibePanfleto',
        () {
          final dados = DadosPagina(
            identidade: _identidade(sePanfleto: sePanfleto),
            estrutura: estruturaFake,
            panfletoVigente: vigente ? panfletoFake : null,
          );

          expect(dados.exibePanfleto, exibePanfleto);
        },
      );
    }
  });
}
