import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

const _pedido = CadastroRequest(
  nomeFantasia: 'Loja',
  nomeResponsavel: 'Ana',
  email: 'a@b.com',
  senha: 'Teste1234',
  whatsapp: '11987654321',
  cnpj: '11222333000181',
);

void main() {
  group('Funcionalidade: cadastro em memória para testes', () {
    test('Cenário: Dado o fake padrão, quando cadastro, então recebo a conta fake e o pedido fica registrado', () async {
      final fake = CadastroRepositoryFake();

      expect(
        await fake.cadastrar(_pedido),
        Success<Falha, CadastroResponse>(cadastroFake),
      );
      expect(fake.pedidos, [_pedido]);
    });

    test('Cenário: Dado uma falha simulada, quando cadastro, então recebo essa falha', () async {
      const falha = FalhaApi(codigo: 'X', mensagem: 'm');

      expect(
        await CadastroRepositoryFake(falhaSimulada: falha).cadastrar(_pedido),
        const Failure<Falha, CadastroResponse>(falha),
      );
    });
  });
}
