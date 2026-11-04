import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

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
            identidade: identidadeFake,
            estrutura: estruturaFake,
            panfletoVigente: vigente ? panfletoFake : null,
            sePanfleto: sePanfleto,
          );

          expect(dados.exibePanfleto, exibePanfleto);
        },
      );
    }

    test('Cenário: Dado a identidade com sePanfleto e a filial sem a chave, então exibePanfleto é false', () {
      final dados = DadosPagina(
        identidade: IdentidadeResponse(
          nomeFantasia: identidadeFake.nomeFantasia,
          sePanfleto: true,
        ),
        estrutura: estruturaFake,
        panfletoVigente: panfletoFake,
      );

      expect(dados.exibePanfleto, isFalse);
    });

    test('Cenário: Dado a chave ligada, quando copio, então a cópia mantém a chave', () {
      final dados = DadosPagina(
        identidade: identidadeFake,
        estrutura: estruturaFake,
        panfletoVigente: panfletoFake,
        sePanfleto: true,
      );

      expect(dados.copiar(estrutura: estruturaFake).exibePanfleto, isTrue);
    });

    test('Cenário: Dado a chave da filial, quando copio com sePanfleto, então a cópia usa a chave nova', () {
      final dados = DadosPagina(
        identidade: identidadeFake,
        estrutura: estruturaFake,
        panfletoVigente: panfletoFake,
      );

      expect(dados.copiar(sePanfleto: true).exibePanfleto, isTrue);
      expect(dados.exibePanfleto, isFalse);
    });
  });
}
