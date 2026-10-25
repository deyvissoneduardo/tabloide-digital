import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

FilialRequest _pedido(String nome) => FilialRequest(
  nome: nome,
  endereco: filialFake.endereco,
  fusoHorario: 'America/Sao_Paulo',
);

void main() {
  group('Funcionalidade: filiais em memória para testes', () {
    test('Cenário: Dado o fake com uma filial, quando crio, edito e excluo, então a lista acompanha', () async {
      final fake = FilialRepositoryFake(filiais: [filialFake]);

      final criada = (await fake.criar(_pedido('Norte')))
          .fold((_) => null, (f) => f)!;
      await fake.editar(filialFake.id, _pedido('Centro Novo'));
      await fake.excluir(criada.id);

      final lista = (await fake.listar()).fold((_) => null, (l) => l)!;
      expect(lista.map((f) => f.nome), ['Centro Novo']);
      expect(fake.pedidos, [_pedido('Norte'), _pedido('Centro Novo')]);
      expect(fake.excluidas, [criada.id]);
      expect(
        await fake.obter(filialFake.id),
        isA<Success<Falha, FilialResponse>>(),
      );
      expect(await fake.obter('nada'), isA<Failure<Falha, FilialResponse>>());
    });

    test('Cenário: Dado uma falha simulada, quando chamo qualquer operação, então recebo a falha', () async {
      final fake = FilialRepositoryFake(falhaSimulada: const FalhaSemConexao());

      expect(
        await fake.listar(),
        const Failure<Falha, List<FilialResponse>>(FalhaSemConexao()),
      );
      expect(await fake.obter('x'), isA<Failure<Falha, FilialResponse>>());
      expect((await fake.excluir('x')).isFailure, isTrue);
    });
  });
}
