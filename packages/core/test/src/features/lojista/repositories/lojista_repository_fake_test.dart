import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: dados do lojista em memória para testes', () {
    test('Cenário: Dado o fake, quando edito, então o lojista acompanha e registro o pedido', () async {
      final fake = LojistaRepositoryFake();
      const pedido = LojistaRequest(
        nomeFantasia: 'Mercado Novo',
        nomeResponsavel: 'Bia',
        whatsapp: '11912345678',
        cnpj: '11222333000181',
      );

      await fake.editar(pedido);
      final lojista = (await fake.obter()).fold((_) => null, (l) => l)!;

      expect(lojista.nomeFantasia, 'Mercado Novo');
      expect(lojista.whatsapp, '+5511912345678');
      expect(lojista.email, lojistaFake.email);
      expect(fake.pedidos, [pedido]);
    });

    test(
      'Cenário: Dado uma falha simulada, quando obtenho, então recebo a falha',
      () async {
        final fake = LojistaRepositoryFake(
          falhaSimulada: const FalhaSemConexao(),
        );

        expect(
          await fake.obter(),
          const Failure<Falha, LojistaResponse>(FalhaSemConexao()),
        );
      },
    );
  });
}
