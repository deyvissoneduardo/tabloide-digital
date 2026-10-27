import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: estrutura em memória para testes', () {
    test('Cenário: Dado o fake, quando salvo outra ordem, então a estrutura guardada segue o pedido', () async {
      final fake = EstruturaRepositoryFake();
      final [hortifruti, mercearia] = estruturaFake.categorias;

      final resultado = await fake.salvar(
        'f1',
        EstruturaRequest([
          CategoriaOrdenada(id: mercearia.id, produtos: const []),
          CategoriaOrdenada(
            id: hortifruti.id,
            produtos: [produtoEstruturaFakeMaca.id],
          ),
        ]),
      );

      final categorias = resultado.fold((_) => null, (e) => e.categorias)!;
      expect(categorias.map((c) => c.id), [mercearia.id, hortifruti.id]);
      expect(categorias.last.produtos, [
        produtoEstruturaFakeMaca,
        produtoEstruturaFakeBanana,
      ]);
      expect(
        (await fake.obter('f1')).fold((_) => null, (e) => e.categorias),
        categorias,
      );
    });

    test('Cenário: Dado uma falha ao salvar, quando salvo, então recebo a falha e a estrutura não muda', () async {
      final fake = EstruturaRepositoryFake(
        falhaAoSalvar: const FalhaSemConexao(),
      );

      expect(
        await fake.salvar('f1', const EstruturaRequest([])),
        const Failure<Falha, EstruturaResponse>(FalhaSemConexao()),
      );
      expect(fake.estrutura, estruturaFake);
    });
  });
}
