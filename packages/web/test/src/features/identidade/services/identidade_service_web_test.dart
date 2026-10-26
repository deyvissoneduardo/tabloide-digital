import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_web/tabloide_web.dart';
import 'package:tabloide_core/testing.dart';

class _IdentidadeRepositoryMock extends Mock implements IdentidadeRepository {}

const _pedido = IdentidadeRequest(nomeFantasia: 'Mercado Bom Preço');

void main() {
  group('Funcionalidade: service de identidade visual na web', () {
    test('Cenário: Dado o repository respondendo, quando obtenho, edito e envio o logo, então devolvo o mesmo resultado de cada chamada', () async {
      final repository = _IdentidadeRepositoryMock();
      final service = IdentidadeServiceWeb(repository);
      when(repository.obter)
          .thenAnswer((_) async => const Success(identidadeFake));
      when(() => repository.editar(_pedido))
          .thenAnswer((_) async => const Success(identidadeFake));
      when(() => repository.enviarLogo(bytes: [1], nomeArquivo: 'logo.png'))
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));

      expect(
        await service.obter(),
        const Success<Falha, IdentidadeResponse>(identidadeFake),
      );
      expect(
        await service.editar(_pedido),
        const Success<Falha, IdentidadeResponse>(identidadeFake),
      );
      expect(
        await service.enviarLogo(bytes: [1], nomeArquivo: 'logo.png'),
        const Failure<Falha, IdentidadeResponse>(FalhaSemConexao()),
      );
    });
  });
}
