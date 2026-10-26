import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

class _LojistaRepositoryMock extends Mock implements LojistaRepository {}

class _IdentidadeRepositoryMock extends Mock implements IdentidadeRepository {}

const _pedidoLojista = LojistaRequest(
  nomeFantasia: 'Mercado Bom Preço',
  nomeResponsavel: 'Ana Souza',
  whatsapp: '11987654321',
  cnpj: '77343168000124',
);

const _pedidoIdentidade = IdentidadeRequest(nomeFantasia: 'Mercado Bom Preço');

void main() {
  group('Funcionalidade: service de perfil no app', () {
    test('Cenário: Dado os repositories respondendo, quando chamo cada operação, então devolvo o mesmo resultado de cada chamada', () async {
      final lojista = _LojistaRepositoryMock();
      final identidade = _IdentidadeRepositoryMock();
      final service = PerfilServiceApp(lojista, identidade);
      when(lojista.obter).thenAnswer((_) async => Success(lojistaFake));
      when(() => lojista.editar(_pedidoLojista))
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));
      when(identidade.obter)
          .thenAnswer((_) async => const Success(identidadeFake));
      when(() => identidade.editar(_pedidoIdentidade))
          .thenAnswer((_) async => const Success(identidadeFake));
      when(() => identidade.enviarLogo(bytes: [1], nomeArquivo: 'logo.png'))
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));

      expect(
        await service.obterLojista(),
        Success<Falha, LojistaResponse>(lojistaFake),
      );
      expect(
        await service.editarLojista(_pedidoLojista),
        const Failure<Falha, LojistaResponse>(FalhaSemConexao()),
      );
      expect(
        await service.obterIdentidade(),
        const Success<Falha, IdentidadeResponse>(identidadeFake),
      );
      expect(
        await service.editarIdentidade(_pedidoIdentidade),
        const Success<Falha, IdentidadeResponse>(identidadeFake),
      );
      expect(
        await service.enviarLogo(bytes: [1], nomeArquivo: 'logo.png'),
        const Failure<Falha, IdentidadeResponse>(FalhaSemConexao()),
      );
    });
  });
}
