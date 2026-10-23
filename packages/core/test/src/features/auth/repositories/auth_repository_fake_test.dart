import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

const _pedido = LoginRequest(email: 'a@b.com', senha: 'x');

void main() {
  group('Funcionalidade: login em memória para testes', () {
    test('Cenário: Dado o fake padrão, quando entro, então recebo a sessão fake e o pedido fica registrado', () async {
      final fake = AuthRepositoryFake();

      expect(
        await fake.entrar(_pedido),
        Success<Falha, LoginResponse>(sessaoFake),
      );
      expect(fake.pedidos, [_pedido]);
    });

    test(
      'Cenário: Dado uma falha simulada, quando entro, então recebo essa falha',
      () async {
        const falha = FalhaApi(codigo: 'X', mensagem: 'm');
        final fake = AuthRepositoryFake(falhaSimulada: falha);

        expect(
          await fake.entrar(_pedido),
          const Failure<Falha, LoginResponse>(falha),
        );
      },
    );
  });
}
