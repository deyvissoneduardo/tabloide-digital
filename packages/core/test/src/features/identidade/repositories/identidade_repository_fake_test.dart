import 'package:flutter_test/flutter_test.dart';
import 'package:tabloide_core/tabloide_core.dart';
import 'package:tabloide_core/testing.dart';

void main() {
  group('Funcionalidade: identidade visual em memória para testes', () {
    test('Cenário: Dado o fake, quando edito e troco o logo, então a identidade acompanha e registro os pedidos', () async {
      final fake = IdentidadeRepositoryFake();
      const pedido = IdentidadeRequest(
        nomeFantasia: 'Mercado Novo',
        sePanfleto: true,
        corPrimaria: '#00ff00',
      );

      await fake.editar(pedido);
      await fake.enviarLogo(bytes: [1], nomeArquivo: 'novo.png');

      expect(
        (await fake.obter()).fold((_) => null, (i) => i),
        const IdentidadeResponse(
          nomeFantasia: 'Mercado Novo',
          corPrimaria: '#00FF00',
          urlLogo: 'https://midia.fake/logo/novo.png',
          sePanfleto: true,
        ),
      );
      expect(fake.pedidos, [pedido]);
      expect(fake.logosEnviados, ['novo.png']);
    });

    test('Cenário: Dado uma falha simulada, quando chamo qualquer operação, então recebo a falha', () async {
      final fake = IdentidadeRepositoryFake(
        falhaSimulada: const FalhaSemConexao(),
      );

      expect(
        await fake.obter(),
        const Failure<Falha, IdentidadeResponse>(FalhaSemConexao()),
      );
      expect(
        (await fake.editar(
          const IdentidadeRequest(nomeFantasia: 'x', sePanfleto: false),
        )).isFailure,
        isTrue,
      );
      expect(
        (await fake.enviarLogo(bytes: [1], nomeArquivo: 'a.png')).isFailure,
        isTrue,
      );
    });
  });
}
