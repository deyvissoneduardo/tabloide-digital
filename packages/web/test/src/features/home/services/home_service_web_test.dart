import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_web/tabloide_web.dart';

class _HomeRepositoryMock extends Mock implements HomeRepository {}

const _resumo = ResumoPainel(
  filiais: 4,
  panfletosVigentes: 1,
  produtosVigentes: 20,
);

void main() {
  group('Funcionalidade: service da home no app', () {
    late _HomeRepositoryMock repository;
    late HomeService service;
    setUp(() {
      repository = _HomeRepositoryMock();
      service = HomeServiceWeb(repository);
    });

    test('Cenário: Dado que o repository responde Success, quando busco o resumo, então devolvo o mesmo Success', () async {
      when(() => repository.buscarResumo())
          .thenAnswer((_) async => const Success(_resumo));

      expect(
        await service.buscarResumo(),
        const Success<Falha, ResumoPainel>(_resumo),
      );
      verify(() => repository.buscarResumo()).called(1);
    });

    test('Cenário: Dado que o repository responde Failure, quando busco o resumo, então devolvo a mesma Failure', () async {
      when(() => repository.buscarResumo())
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));

      expect(
        await service.buscarResumo(),
        const Failure<Falha, ResumoPainel>(FalhaSemConexao()),
      );
    });

    test('Cenário: Dado o repository fake (sem mock), quando busco, então o service funciona com qualquer implementação do contrato', () async {
      final resultado = await const HomeServiceWeb(
        HomeRepositoryFake(atraso: Duration.zero),
      ).buscarResumo();

      expect(resultado.isSuccess, isTrue);
    });
  });
}
