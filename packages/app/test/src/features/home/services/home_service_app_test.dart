import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tabloide_app/tabloide_app.dart';
import 'package:tabloide_core/testing.dart';

class _HomeRepositoryMock extends Mock implements HomeRepository {}

const _resumo = ResumoPainel(panfletosVigentes: 1, produtosVigentes: 20);

void main() {
  group('Funcionalidade: service da home no app', () {
    late _HomeRepositoryMock repository;
    late HomeService service;
    setUp(() {
      repository = _HomeRepositoryMock();
      service = HomeServiceApp(repository);
    });

    test('Cenário: Dado que o repository responde Success, quando busco o resumo, então devolvo o mesmo Success', () async {
      when(() => repository.buscarResumo(const ['f1']))
          .thenAnswer((_) async => const Success(_resumo));

      expect(
        await service.buscarResumo(const ['f1']),
        const Success<Falha, ResumoPainel>(_resumo),
      );
      verify(() => repository.buscarResumo(const ['f1'])).called(1);
    });

    test('Cenário: Dado que o repository responde Failure, quando busco o resumo, então devolvo a mesma Failure', () async {
      when(() => repository.buscarResumo(const ['f1']))
          .thenAnswer((_) async => const Failure(FalhaSemConexao()));

      expect(
        await service.buscarResumo(const ['f1']),
        const Failure<Falha, ResumoPainel>(FalhaSemConexao()),
      );
    });

    test('Cenário: Dado o repository fake (sem mock), quando busco, então o service funciona com qualquer implementação do contrato', () async {
      final resultado = await const HomeServiceApp(
        HomeRepositoryFake(atraso: Duration.zero),
      ).buscarResumo(const ['f1']);

      expect(resultado.isSuccess, isTrue);
    });
  });
}
